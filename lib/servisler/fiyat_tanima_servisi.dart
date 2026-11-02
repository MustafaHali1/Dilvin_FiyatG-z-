import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../modeller/fiyat_tanima_sonucu.dart';
import '../modeller/metin_satir_kutusu.dart';

/// Market etiketlerinden fiyat ve ürün bilgisini çıkaran akıllı ve mekânsal OCR servisi (Singleton)
class FiyatTanimaServisi {
  static final FiyatTanimaServisi _ornek = FiyatTanimaServisi._dahili();
  factory FiyatTanimaServisi() => _ornek;
  FiyatTanimaServisi._dahili();

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Verilen görsel dosyasını ML Kit ile okuyup mekânsal analizden geçirir
  Future<FiyatTanimaSonucu> resmiTara(
    String resimYolu, {
    bool merkezOdakli = false,
    String? hedefUrun,
  }) async {
    try {
      final dosya = File(resimYolu);
      if (!await dosya.exists()) {
        return FiyatTanimaSonucu.bos(hata: 'Görsel dosyası bulunamadı.');
      }

      final inputImage = InputImage.fromFilePath(resimYolu);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);

      if (recognizedText.text.trim().isEmpty) {
        return FiyatTanimaSonucu.bos(hata: 'Görselde herhangi bir metin okunamadı.');
      }

      // RecognizedText nesnesini saf MetinSatirKutusu listesine dönüştür
      final satirlar = <MetinSatirKutusu>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final metin = line.text.trim();
          if (metin.isNotEmpty) {
            satirlar.add(
              MetinSatirKutusu(
                metin: metin,
                kutu: line.boundingBox,
              ),
            );
          }
        }
      }

      return satirlardanFiyatVeUrunCikar(
        satirlar,
        merkezOdakli: merkezOdakli,
        hedefUrun: hedefUrun,
      );
    } catch (e) {
      return FiyatTanimaSonucu.bos(hata: 'OCR işlemi sırasında hata oluştu: $e');
    }
  }

  /// Saf koordinat ve metin kutularını analiz eden kural ve mekan tabanlı motor
  /// (Birim testlerde donanımsız çalıştırılabilir)
  FiyatTanimaSonucu satirlardanFiyatVeUrunCikar(
    List<MetinSatirKutusu> satirlar, {
    double? goruntuGenisligi,
    double? goruntuYuksekligi,
    bool merkezOdakli = false,
    String? hedefUrun,
  }) {
    if (satirlar.isEmpty) {
      return FiyatTanimaSonucu.bos(hata: 'Analiz edilecek metin satırı yok.');
    }

    final tumSatirlarMetin = satirlar.map((s) => s.metin).toList();

    // 1. Ekran / Görsel sınırlarının hesaplanması
    final minX = goruntuGenisligi != null ? 0.0 : satirlar.map((s) => s.kutu.left).reduce((a, b) => a < b ? a : b);
    final maxX = goruntuGenisligi ?? satirlar.map((s) => s.kutu.right).reduce((a, b) => a > b ? a : b);
    final genislik = maxX - minX;

    // 2. Kenar Alanları Filtresi (Örn: Sol %15'teki kitap veya sağ %15'teki yabancı nesneler)
    final gecerliSatirlar = <MetinSatirKutusu>[];
    for (final satir in satirlar) {
      if (genislik > 200 && merkezOdakli) {
        final solKenarPayi = minX + (genislik * 0.15);
        final sagKenarPayi = maxX - (genislik * 0.15);
        if (satir.merkezX < solKenarPayi || satir.merkezX > sagKenarPayi) {
          // Kenarda kalan alakasız nesneleri merkez odak modunda atla
          continue;
        }
      }
      gecerliSatirlar.add(satir);
    }

    final islenecekSatirlar = gecerliSatirlar.isNotEmpty ? gecerliSatirlar : satirlar;

    // 3. Etiketteki en büyük yazı yüksekliğini bul (Punto dominansı)
    double maxYukseklik = 1.0;
    for (final s in islenecekSatirlar) {
      if (s.yukseklik > maxYukseklik) maxYukseklik = s.yukseklik;
    }

    // 4. Fiyat Adaylarını Ayıkla ve Puanla
    final adaylar = <_AkilliFiyatAdayi>[];

    // Önce yatayda birbirine bitişik [Büyük Tamsayı] + [Küçük Kuruş (örn: 299 ve 00 TL)] kutularını birleştir
    _bitisikKuruslariBirlestirVeEkle(islenecekSatirlar, maxYukseklik, adaylar);

    // Ardından tek satırda geçen fiyatları analiz et
    for (final satir in islenecekSatirlar) {
      _satirdanAkilliFiyatCikar(satir, maxYukseklik, adaylar);
    }

    if (adaylar.isEmpty) {
      final urunAdi = _akilliUrunAdiTahminEt(islenecekSatirlar, null, hedefUrun);
      return FiyatTanimaSonucu(
        tespitEdilenFiyat: null,
        adayFiyatlar: const [],
        tespitEdilenUrunAdi: urunAdi,
        guvenSkoru: 0.0,
        tumSatirlar: tumSatirlarMetin,
        basarili: false,
        hataMesaji: 'Etikette geçerli satış fiyatı tespit edilemedi.',
      );
    }

    // Adayları sezgisel skorlarına göre büyükten küçüğe sırala
    adaylar.sort((a, b) => b.skor.compareTo(a.skor));

    // Tekrarlanan fiyatları filtrele
    final tekilFiyatlar = <double>{};
    final siraliFiyatlar = <double>[];
    _AkilliFiyatAdayi? enIyiAday;

    for (final aday in adaylar) {
      final yuvarlanmis = double.parse(aday.fiyat.toStringAsFixed(2));
      if (!tekilFiyatlar.contains(yuvarlanmis)) {
        tekilFiyatlar.add(yuvarlanmis);
        siraliFiyatlar.add(yuvarlanmis);
        enIyiAday ??= aday;
      }
    }

    // 5. Ürün Adını En İyi Fiyat Kutusunun Konumuna Göre Akıllıca Bul
    final enIyiFiyat = siraliFiyatlar.isNotEmpty ? siraliFiyatlar.first : null;
    final urunAdi = _akilliUrunAdiTahminEt(islenecekSatirlar, enIyiAday?.kutu, hedefUrun);
    final guvenSkoru = enIyiAday != null ? (enIyiAday.skor / 100.0).clamp(0.2, 0.99) : 0.0;

    return FiyatTanimaSonucu(
      tespitEdilenFiyat: enIyiFiyat,
      adayFiyatlar: siraliFiyatlar,
      tespitEdilenUrunAdi: urunAdi,
      guvenSkoru: guvenSkoru,
      tumSatirlar: tumSatirlarMetin,
      basarili: enIyiFiyat != null,
    );
  }

  /// Satır içerisindeki sayıları ölçü birimleri (M, KG, vb.) ve tarihlerden arındırarak fiyat olarak puanlar
  void _satirdanAkilliFiyatCikar(
    MetinSatirKutusu satirKutusu,
    double maxYukseklik,
    List<_AkilliFiyatAdayi> adaylar,
  ) {
    final satir = satirKutusu.metin;
    final kucukSatir = satir.toLowerCase();

    // 1. Tarih ve Saat Kalıplarını Tamamen Ele
    if (RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b').hasMatch(satir)) return;

    // 2. Ölçü Birimlerine Yapışık Sayıları Tespit Et (KARA LİSTE)
    // Örnek: "20 M", "20M", "1.5 KG", "500 GR", "1 LT", "2 ADET", "3 PARÇA", "%20", "20 KAT"
    final olcuRegex = RegExp(
      r'\b(\d+(?:[.,]\d+)?)\s*(?:m|mt|metre|cm|mm|kg|kilo|gr|gram|g|lt|l|litre|ml|ad|adet|pk|paket|koli|parca|parça|kat|x|%)\b',
      caseSensitive: false,
    );
    final elenecekSayilar = <String>{};
    for (final m in olcuRegex.allMatches(satir)) {
      final sayiGrubu = m.group(1);
      if (sayiGrubu != null) {
        elenecekSayilar.add(sayiGrubu.trim());
      }
    }

    // 3. Fiyat Regex Eşleştirmesi (Örn: "299,00 TL", "299.00", "299 TL", "₺299")
    final fiyatRegex = RegExp(
      r'(?:₺|TL)?\s*(\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{1,2})|\d{1,4})\s*(?:₺|TL|kr)?',
      caseSensitive: false,
    );

    final eslesmeler = fiyatRegex.allMatches(satir);

    for (final eslesme in eslesmeler) {
      final hamMetin = eslesme.group(1);
      if (hamMetin == null) continue;

      final temizHam = hamMetin.trim();

      // Ölçü birimi olarak elenen sayıyı fiyat yapma! (Örn: "20 M" deki 20)
      if (elenecekSayilar.contains(temizHam)) continue;

      final fiyat = _fiyatNormalizeEt(temizHam);
      if (fiyat == null || fiyat <= 0.0 || fiyat > 50000.0) continue;

      // Barkod veya çok uzun tamsayıları ele (Örn: 00077038)
      if (!temizHam.contains(',') && !temizHam.contains('.') && temizHam.length > 4) {
        continue;
      }

      // Yıl sayılarını (2024, 2025, 2026) TL içermiyorsa ele
      if ((fiyat >= 2023 && fiyat <= 2030) && !satir.contains('₺') && !kucukSatir.contains('tl')) {
        continue;
      }

      // Skor Hesaplama (Maksimum 100 üzerinden)
      double skor = 40.0;

      // A) Punto / Yazı Büyüklüğü (Satış fiyatı etiketteki en devasa yazıdır!)
      final puntoOrani = (satirKutusu.yukseklik / maxYukseklik).clamp(0.1, 1.0);
      skor += puntoOrani * 45.0; // En büyük yazıysa +45 puan

      // B) Para Birimi Vurgusu (₺ veya TL)
      if (satir.contains('₺') || kucukSatir.contains('tl')) {
        skor += 25.0;
      }

      // C) Satış Fiyatı İpuçları
      if (kucukSatir.contains('fiyat') || kucukSatir.contains('indirim') || kucukSatir.contains('tutar')) {
        skor += 10.0;
      }

      // D) Negatif İpuçları (Birim Fiyat, KDV, Barkod satırları satış fiyatı değildir)
      if (kucukSatir.contains('tl/ad') ||
          kucukSatir.contains('tl/kg') ||
          kucukSatir.contains('tl/lt') ||
          kucukSatir.contains('birim fiyat') ||
          kucukSatir.contains('kdv')) {
        skor -= 35.0;
      }

      adaylar.add(_AkilliFiyatAdayi(fiyat: fiyat, skor: skor, kutu: satirKutusu.kutu));
    }
  }

  /// Türkiye etiketlerindeki yaygın [Büyük Tamsayı: 299] ve [Bitişik Küçük Kuruş: ,00 TL] bloklarını birleştirir
  void _bitisikKuruslariBirlestirVeEkle(
    List<MetinSatirKutusu> satirlar,
    double maxYukseklik,
    List<_AkilliFiyatAdayi> adaylar,
  ) {
    for (int i = 0; i < satirlar.length; i++) {
      final s1 = satirlar[i];
      final metin1 = s1.metin.trim();

      // Sadece 1 ile 4 basamaklı saf tamsayıları ara (Örn: "299")
      if (!RegExp(r'^\d{1,4}$').hasMatch(metin1)) continue;
      final tamKisim = int.tryParse(metin1);
      if (tamKisim == null || tamKisim <= 0) continue;

      // Bu tamsayının sağında hemen bitişik duran kuruş bloğu var mı?
      for (int j = 0; j < satirlar.length; j++) {
        if (i == j) continue;
        final s2 = satirlar[j];
        final metin2 = s2.metin.trim();

        // Kuruş formatı ara: ",00", ".00", "00", ",95 TL", ",00 TL", "TL"
        final kurusMatch = RegExp(r'^[.,]?(\d{2})\s*(?:₺|TL)?', caseSensitive: false).firstMatch(metin2);
        if (kurusMatch == null) continue;

        final kurusStr = kurusMatch.group(1);
        if (kurusStr == null) continue;

        // Geometrik Mesafe Kontrolü:
        // s2, s1'in sağında olmalı ve yatay boşluk makul bir seviyede olmalı
        final yatayBosluk = s2.kutu.left - s1.kutu.right;
        final dikeyFark = (s1.merkezY - s2.merkezY).abs();

        final maxIzinVerilenBosluk = s1.yukseklik * 1.5;
        final maxIzinVerilenDikeyFark = s1.yukseklik * 0.8;

        if (yatayBosluk >= -10 && yatayBosluk <= maxIzinVerilenBosluk && dikeyFark <= maxIzinVerilenDikeyFark) {
          final birlestirilmisFiyatStr = '$tamKisim.$kurusStr';
          final birlesmisFiyat = double.tryParse(birlestirilmisFiyatStr);
          if (birlesmisFiyat != null) {
            // Birleşik kutu oluştur
            final birlesikKutu = Rect.fromLTRB(
              s1.kutu.left,
              s1.kutu.top < s2.kutu.top ? s1.kutu.top : s2.kutu.top,
              s2.kutu.right,
              s1.kutu.bottom > s2.kutu.bottom ? s1.kutu.bottom : s2.kutu.bottom,
            );

            double skor = 50.0;
            // Punto oranı en büyük sayıdan hesaplanır
            final puntoOrani = (s1.yukseklik / maxYukseklik).clamp(0.1, 1.0);
            skor += puntoOrani * 45.0; // Devasa punto

            if (metin2.toLowerCase().contains('tl') || metin2.contains('₺')) {
              skor += 25.0;
            }

            adaylar.add(_AkilliFiyatAdayi(fiyat: birlesmisFiyat, skor: skor, kutu: birlesikKutu));
          }
        }
      }
    }
  }

  /// Ürün adını fiyat kutusunun hemen üstündeki satırlardan akıllıca tespit eder
  String? _akilliUrunAdiTahminEt(
    List<MetinSatirKutusu> satirlar,
    Rect? fiyatKutusu,
    String? hedefUrun,
  ) {
    // 1. Eğer aranan belirli bir hedef ürün varsa (örn: "süt", "hortum"), onu içeren satıra öncelik ver
    if (hedefUrun != null && hedefUrun.trim().isNotEmpty) {
      final hedefKucuk = hedefUrun.toLowerCase().trim();
      for (final s in satirlar) {
        if (s.metin.toLowerCase().contains(hedefKucuk)) {
          return s.metin.trim();
        }
      }
    }

    final temizAdaylar = <_UrunAdiAdayi>[];

    for (final s in satirlar) {
      final metin = s.metin.trim();
      if (metin.length < 3) continue;

      final kucuk = metin.toLowerCase();

      // Market adı, logolar ve fiş üst bilgilerini filtrele
      if (kucuk.contains('şok market') ||
          kucuk.contains('a101') ||
          kucuk.contains('bim') ||
          kucuk.contains('migros') ||
          kucuk.contains('carrefour') ||
          kucuk.contains('şikayetvar') ||
          kucuk.contains('tarih') ||
          kucuk.contains('kasiyer') ||
          kucuk.contains('üretim') ||
          kucuk.contains('menşei') ||
          kucuk.contains('kdv') ||
          kucuk.contains('barkod') ||
          kucuk.contains('birim fiyat')) {
        continue;
      }

      // Sadece sayılardan veya sembollerden oluşanları ele
      if (!RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ]').hasMatch(metin)) continue;

      // Çok kısa harf kodlarını (örn: tek başına "T") ele
      if (metin.length <= 2) continue;

      // Geometrik Konum Puanlaması (Fiyat Kutusunun Hemen Üstünde mi?)
      double konumSkoru = 50.0;

      if (fiyatKutusu != null) {
        final dikeyMesafe = fiyatKutusu.top - s.kutu.bottom;

        if (dikeyMesafe >= -20 && dikeyMesafe <= 300) {
          // Fiyatın yukarısında ve yakınında: Çok yüksek puan
          konumSkoru += (300 - dikeyMesafe) / 5.0; // +10 ile +60 puan

          // Yatayda hizalı mı?
          final yatayOrtusme = (s.merkezX - (fiyatKutusu.left + fiyatKutusu.width / 2)).abs();
          if (yatayOrtusme < 300) {
            konumSkoru += 30.0;
          }
        } else if (s.kutu.top > fiyatKutusu.bottom) {
          // Fiyatın altındaki satırlar genellikle barkod veya kural metinleridir
          konumSkoru -= 30.0;
        }
      }

      temizAdaylar.add(_UrunAdiAdayi(metin: metin, skor: konumSkoru));
    }

    if (temizAdaylar.isEmpty) return null;

    // En yüksek konumsal puana sahip olan satırı seç
    temizAdaylar.sort((a, b) => b.skor.compareTo(a.skor));
    return temizAdaylar.first.metin;
  }

  /// "299,00" -> 299.00, "1.249,50" -> 1249.50, "299" -> 299.0
  double? _fiyatNormalizeEt(String ham) {
    try {
      String temiz = ham.trim();
      if (temiz.contains('.') && temiz.contains(',')) {
        temiz = temiz.replaceAll('.', '').replaceAll(',', '.');
      } else if (temiz.contains(',')) {
        temiz = temiz.replaceAll(',', '.');
      }
      return double.tryParse(temiz);
    } catch (_) {
      return null;
    }
  }

  /// OCR kaynaklarını serbest bırakır
  Future<void> kapat() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}

class _AkilliFiyatAdayi {
  final double fiyat;
  final double skor;
  final Rect kutu;
  const _AkilliFiyatAdayi({
    required this.fiyat,
    required this.skor,
    required this.kutu,
  });
}

class _UrunAdiAdayi {
  final String metin;
  final double skor;
  const _UrunAdiAdayi({required this.metin, required this.skor});
}
