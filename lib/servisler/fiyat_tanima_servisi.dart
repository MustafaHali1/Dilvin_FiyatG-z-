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
    bool merkezOdakli = true,
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

      final oncedenKirpilmis = resimYolu.contains('_kirpilmis');
      return satirlardanFiyatVeUrunCikar(
        satirlar,
        merkezOdakli: oncedenKirpilmis ? false : merkezOdakli,
        hedefUrun: hedefUrun,
      );
    } catch (e) {
      return FiyatTanimaSonucu.bos(hata: 'OCR işlemi sırasında hata oluştu: $e');
    }
  }

  /// Saf koordinat ve metin kutularını analiz eden kural ve mekan tabanlı motor
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

    // 1. Ekran / Görsel sınırlarının hesaplanması (X ve Y eksenleri)
    final minX = goruntuGenisligi != null ? 0.0 : satirlar.map((s) => s.kutu.left).reduce((a, b) => a < b ? a : b);
    final maxX = goruntuGenisligi ?? satirlar.map((s) => s.kutu.right).reduce((a, b) => a > b ? a : b);
    final genislik = maxX - minX;

    final minY = goruntuYuksekligi != null ? 0.0 : satirlar.map((s) => s.kutu.top).reduce((a, b) => a < b ? a : b);
    final maxY = goruntuYuksekligi ?? satirlar.map((s) => s.kutu.bottom).reduce((a, b) => a > b ? a : b);
    final toplamYukseklik = maxY - minY;

    // 2. Kenar Alanları Filtresi (Merkez Odaklı Kırpma: Sol, Sağ, Üst ve Alt marjinler)
    final gecerliSatirlar = <MetinSatirKutusu>[];
    for (final satir in satirlar) {
      if (merkezOdakli) {
        if (genislik > 200) {
          final solKenarPayi = minX + (genislik * 0.12);
          final sagKenarPayi = maxX - (genislik * 0.12);
          if (satir.merkezX < solKenarPayi || satir.merkezX > sagKenarPayi) {
            continue;
          }
        }
        if (toplamYukseklik > 200) {
          // Hedef çerçevesi dışındaki alt ve üst marjinleri kes
          final ustKenarPayi = minY + (toplamYukseklik * 0.10);
          final altKenarPayi = maxY - (toplamYukseklik * 0.15);
          if (satir.merkezY < ustKenarPayi || satir.merkezY > altKenarPayi) {
            continue;
          }
        }
      }
      gecerliSatirlar.add(satir);
    }

    final islenecekSatirlar = gecerliSatirlar.isNotEmpty ? gecerliSatirlar : satirlar;

    // 3. Etiketteki en büyük YATAY yazı yüksekliğini bul (Dikey sütunlar elenir!)
    double maxYatayYukseklik = 1.0;
    for (final s in islenecekSatirlar) {
      // Dikey / döndürülmüş metinleri (height > width * 1.5) font hesabı için baz alma
      if (s.genislik >= s.yukseklik * 0.8) {
        if (s.yukseklik > maxYatayYukseklik) {
          maxYatayYukseklik = s.yukseklik;
        }
      }
    }

    // 4. Fiyat Adaylarını Ayıkla ve Puanla
    final adaylar = <_AkilliFiyatAdayi>[];

    // Etikette "Birim Fiyatı: 299.00 TL/AD" gibi yasal referans fiyat var mı tespit et
    double? referansFiyat;
    for (final s in islenecekSatirlar) {
      if (s.metin.toLowerCase().contains('birim fiyat')) {
        final m = RegExp(r'(\d{1,4}(?:[.,]\d{1,2}))').firstMatch(s.metin);
        if (m != null) {
          referansFiyat = _fiyatNormalizeEt(m.group(1)!);
        }
      }
    }

    // Önce yatayda birbirine bitişik [Büyük Tamsayı: 299] + [Küçük Kuruş: ,00 TL] kutularını birleştir
    _bitisikKuruslariBirlestirVeEkle(islenecekSatirlar, maxYatayYukseklik, adaylar);

    // Ardından tek satırda geçen fiyatları analiz et
    for (final satir in islenecekSatirlar) {
      _satirdanAkilliFiyatCikar(satir, islenecekSatirlar, maxYatayYukseklik, adaylar);
    }

    // Referans birim fiyatla eşleşen adaya süper onay puanı (+80) ver
    if (referansFiyat != null) {
      for (int i = 0; i < adaylar.length; i++) {
        final a = adaylar[i];
        if ((a.fiyat - referansFiyat).abs() < 0.05) {
          adaylar[i] = _AkilliFiyatAdayi(fiyat: a.fiyat, skor: a.skor + 80.0, kutu: a.kutu);
        }
      }
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
    List<MetinSatirKutusu> tumSatirlar,
    double maxYatayYukseklik,
    List<_AkilliFiyatAdayi> adaylar,
  ) {
    final satir = satirKutusu.metin;
    final kucukSatir = satir.toLowerCase();

    // 1. Tarih ve Saat Kalıplarını Tamamen Ele (Örn: 01-05-2024)
    if (RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b').hasMatch(satir)) return;

    // 2. Barkod ve Stok Kodu Satırlarını Ele (Örn: "8 699037 130518", "00077038", "GA7A")
    if (RegExp(r'^\s*\d{1,2}\s+\d{4,8}\s+\d{4,8}\s*$').hasMatch(satir) ||
        RegExp(r'^\s*0{2,}\d+\s*$').hasMatch(satir) ||
        kucukSatir.contains('barkod')) {
      return;
    }

    // 3. Ölçü Birimlerine Yapışık Sayıları Tespit Et (KARA LİSTE - Örn: "20 M")
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

      // Barkod veya çok uzun tamsayıları ele (Örn: 00077038, 869037130518)
      if (!temizHam.contains(',') && !temizHam.contains('.') && temizHam.length > 4) {
        continue;
      }

      // Yıl sayılarını (2024, 2025, 2026) TL içermiyorsa ele
      if ((fiyat >= 2023 && fiyat <= 2030) && !satir.contains('₺') && !kucukSatir.contains('tl')) {
        continue;
      }

      // Para birimi olmayan ve kuruşsuz rastgele sayıları (örn: barkod parçaları 37, 18, 77) ele
      final paraBirimiVar = satir.contains('₺') || kucukSatir.contains('tl') || _komsuKutudaParaBirimiVarMi(satirKutusu.kutu, tumSatirlar);
      if (!temizHam.contains(',') && !temizHam.contains('.') && !paraBirimiVar) {
        continue;
      }

      // Skor Hesaplama (Maksimum 150 üzerinden)
      double skor = 20.0;

      // A) Punto / Yazı Büyüklüğü (Satış fiyatı etiketteki en devasa yazıdır - MUTLAK ÜSTÜNLÜK)
      final puntoOrani = (satirKutusu.yukseklik / maxYatayYukseklik).clamp(0.05, 1.0);
      skor += puntoOrani * 70.0; // En büyük yazıysa doğrudan +70 puan!

      if (satirKutusu.yukseklik >= 40) {
        skor += 30.0; // 40 pikselden büyükse devasa fiyattır: +30 ekstra puan!
      }

      // B) Para Birimi Vurgusu (Satırda veya komşu kutularda ₺ veya TL var mı?)
      if (paraBirimiVar) {
        skor += 35.0; // Para birimi eşleşmesine +35 puan
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
          kucukSatir.contains('kdv') ||
          kucukSatir.contains('f. değ') ||
          kucukSatir.contains('fiyat değ')) {
        skor -= 50.0;
      }

      // E) Etiket Yoğunluk Skoru (Gerçek market etiketinde fiyata komşu birçok satır vardır: barkod, kdv, ürün adı)
      int komsuKutuSayisi = 0;
      for (final komsu in tumSatirlar) {
        if (komsu == satirKutusu) continue;
        final dX = (komsu.merkezX - satirKutusu.merkezX).abs();
        final dY = (komsu.merkezY - satirKutusu.merkezY).abs();
        if (dX < 300 && dY < 200) {
          komsuKutuSayisi++;
        }
      }
      skor += (komsuKutuSayisi * 5.0).clamp(0.0, 35.0);

      // Perakende market ürünleri genellikle 1 TL ile 2000 TL arasındadır
      if (fiyat > 5000.0) {
        skor -= 30.0; // Web sitesi toptan paket/koli fiyatlarını aşağı çek
      }

      // Küçük rastgele tamsayıları (4, 6, 7 gibi) cezalandır
      if (!temizHam.contains(',') && !temizHam.contains('.') && fiyat < 10 && !paraBirimiVar) {
        skor -= 30.0;
      }

      adaylar.add(_AkilliFiyatAdayi(fiyat: fiyat, skor: skor, kutu: satirKutusu.kutu));

      // OCR Düzeltmesi 1: Eğer tamsayı 4 basamaklıysa ve 9 ile bitiyorsa (örn: 2999.00)
      // Bu, etiketteki virgülün yuvarlak başlığının '9' sanılmasından kaynaklanır (299, -> 2999)!
      if (fiyat >= 1000.0 && fiyat < 10000.0) {
        final tam = fiyat.truncate();
        final kurus = ((fiyat - tam) * 100).round();
        if (tam % 10 == 9) {
          final duzeltilmisTam = tam ~/ 10;
          final duzeltilmisFiyat = duzeltilmisTam + (kurus / 100.0);
          adaylar.add(_AkilliFiyatAdayi(fiyat: duzeltilmisFiyat, skor: skor + 40.0, kutu: satirKutusu.kutu));
        }
        // OCR Düzeltmesi 2: Sol kenar çerçevesi '|' 1 sanıldıysa (örn: 1299.00 -> 299.00)
        if (tam.toString().startsWith('1')) {
          final kirpilmisTam = int.tryParse(tam.toString().substring(1));
          if (kirpilmisTam != null && kirpilmisTam > 10) {
            final duzeltilmisFiyat = kirpilmisTam + (kurus / 100.0);
            adaylar.add(_AkilliFiyatAdayi(fiyat: duzeltilmisFiyat, skor: skor + 35.0, kutu: satirKutusu.kutu));
          }
        }
      }
    }
  }

  /// Kutunun hemen altında veya sağında 'TL' veya '₺' simgesi olup olmadığını denetler
  bool _komsuKutudaParaBirimiVarMi(Rect anaKutu, List<MetinSatirKutusu> satirlar) {
    for (final s in satirlar) {
      final k = s.metin.toLowerCase().trim();
      if (k == 'tl' || k == '₺' || k.startsWith(',00 tl') || k.startsWith('00 tl')) {
        // Yatay mesafe veya dikey mesafe yakın mı?
        final yatayFark = (s.merkezX - (anaKutu.left + anaKutu.width / 2)).abs();
        final dikeyFark = s.kutu.top - anaKutu.bottom;

        if (dikeyFark >= -20 && dikeyFark <= anaKutu.height * 1.5 && yatayFark < anaKutu.width * 1.2) {
          return true;
        }

        final yatayUzaklik = s.kutu.left - anaKutu.right;
        if (yatayUzaklik >= -10 && yatayUzaklik <= anaKutu.width * 0.8) {
          return true;
        }
      }
    }
    return false;
  }

  /// Türkiye etiketlerindeki yaygın [Büyük Tamsayı: 299] ve [Bitişik Küçük Kuruş: ,00 TL] bloklarını birleştirir
  void _bitisikKuruslariBirlestirVeEkle(
    List<MetinSatirKutusu> satirlar,
    double maxYatayYukseklik,
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
        final yatayBosluk = s2.kutu.left - s1.kutu.right;
        final dikeyFark = (s1.merkezY - s2.merkezY).abs();

        final maxIzinVerilenBosluk = s1.yukseklik * 1.5;
        final maxIzinVerilenDikeyFark = s1.yukseklik * 0.8;

        if (yatayBosluk >= -10 && yatayBosluk <= maxIzinVerilenBosluk && dikeyFark <= maxIzinVerilenDikeyFark) {
          final birlestirilmisFiyatStr = '$tamKisim.$kurusStr';
          final birlesmisFiyat = double.tryParse(birlestirilmisFiyatStr);
          if (birlesmisFiyat != null) {
            final birlesikKutu = Rect.fromLTRB(
              s1.kutu.left,
              s1.kutu.top < s2.kutu.top ? s1.kutu.top : s2.kutu.top,
              s2.kutu.right,
              s1.kutu.bottom > s2.kutu.bottom ? s1.kutu.bottom : s2.kutu.bottom,
            );

            double skor = 50.0;
            final puntoOrani = (s1.yukseklik / maxYatayYukseklik).clamp(0.1, 1.0);
            skor += puntoOrani * 70.0; // Büyük puntoya devasa puan!
            if (s1.yukseklik >= 40) skor += 30.0;

            if (metin2.toLowerCase().contains('tl') || metin2.contains('₺')) {
              skor += 35.0;
            }

            adaylar.add(_AkilliFiyatAdayi(fiyat: birlesmisFiyat, skor: skor, kutu: birlesikKutu));

            // OCR Düzeltmesi 1: Eğer tamsayı 4 basamaklıysa ve 9 ile bitiyorsa (örn: 2999 ve ,00)
            if (tamKisim >= 1000 && tamKisim % 10 == 9) {
              final duzeltilmisTam = tamKisim ~/ 10;
              final duzeltilmisFiyat = double.tryParse('$duzeltilmisTam.$kurusStr');
              if (duzeltilmisFiyat != null) {
                adaylar.add(_AkilliFiyatAdayi(fiyat: duzeltilmisFiyat, skor: skor + 40.0, kutu: birlesikKutu));
              }
            }

            // OCR Düzeltmesi 2: Sol kenar çerçevesi '|' 1 sanıldıysa (örn: 1299 ve ,00 -> 299.00)
            if (tamKisim >= 1000 && tamKisim.toString().startsWith('1')) {
              final kirpilmisTam = int.tryParse(tamKisim.toString().substring(1));
              if (kirpilmisTam != null && kirpilmisTam > 10) {
                final duzeltilmisFiyat = double.tryParse('$kirpilmisTam.$kurusStr');
                if (duzeltilmisFiyat != null) {
                  adaylar.add(_AkilliFiyatAdayi(fiyat: duzeltilmisFiyat, skor: skor + 35.0, kutu: birlesikKutu));
                }
              }
            }
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
    if (hedefUrun != null && hedefUrun.trim().isNotEmpty) {
      final hedefKucuk = hedefUrun.toLowerCase().trim();
      for (final s in satirlar) {
        if (s.metin.toLowerCase().contains(hedefKucuk)) {
          return s.metin.trim();
        }
      }
    }

    // Yasaklı anahtar kelimeler listesi (Kesinlikle ürün adı olamaz!)
    final yasakliKelimeler = {
      'market', 'marketler', 'şok', 'a101', 'bim', 'migros', 'carrefour',
      'etiket', 'etiketi', 'fiyat', 'fiyatı', 'yanlışlığı', 'şikayet', 'şikayetvar',
      'kartı', 'karti', 'kart', 'kartları', 'damga', 'san', 'rulo', 'baskılı',
      'ikaz', 'takılabilir', 'takilabilir', 'rafa',
      'üretim', 'menşei', 'türkiye', 'kdv', 'dahildir', 'barkod',
      'birim', 'tarih', 'kasiyer', 'yerli', 'gaza', 't'
    };

    final temizAdaylar = <_UrunAdiAdayi>[];

    for (final s in satirlar) {
      final metin = s.metin.trim();
      if (metin.length < 3) continue;

      final kucuk = metin.toLowerCase();

      // Kelimeleri parçala ve yasaklı kontrolü yap
      final kelimeler = kucuk.split(RegExp(r'\s+'));

      // Eğer satır sadece yasaklı kelimelerden oluşuyorsa (Örn: "Market" veya "Şok Marketler") doğrudan ele!
      final faydaliKelimeler = kelimeler.where((k) => !yasakliKelimeler.contains(k)).toList();
      if (faydaliKelimeler.isEmpty) {
        continue;
      }

      // Üretim menşei, tarih ve KDV gibi yasal etiket detayları ürün adı olamaz!
      if (kucuk.contains('üretim') ||
          kucuk.contains('menşei') ||
          kucuk.contains('türkiye') ||
          kucuk.contains('yerli') ||
          kucuk.contains('barkod') ||
          kucuk.contains('tarih')) {
        continue;
      }

      // Birim fiyat satırları veya fiş detayları kesinlikle ürün adı olamaz!
      if (kucuk.contains('birim fiyat') ||
          kucuk.contains('tl/ad') ||
          kucuk.contains('tl/kg') ||
          kucuk.contains('tl/lt') ||
          kucuk.contains('fiyat değ') ||
          kucuk.contains('f. değ') ||
          kucuk.contains('kdv')) {
        continue;
      }

      // "Şok Marketler Şok Market..." gibi başlıkları ele
      if (kucuk.contains('şikayet') ||
          kucuk.contains('yanlışlığı') ||
          kucuk.contains('etiket fiyat') ||
          kucuk.contains('etiket kart') ||
          kucuk.contains('damga market') ||
          kucuk.contains('ikaz etiket') ||
          kucuk.contains('fiyat ikaz') ||
          kucuk.contains('rafa takıl') ||
          kucuk.contains('fiyat etiket')) {
        continue;
      }

      // Fiyat içeren satırlar (örn: "299,00 TL" veya "299 TL") kesinlikle ürün adı olamaz!
      if (metin.contains('₺') || kucuk.contains('tl') || RegExp(r'\b\d+[,.]\d{2}\b').hasMatch(metin)) {
        continue;
      }

      // Sadece sayılardan veya sembollerden oluşanları ele
      if (!RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ]').hasMatch(metin)) continue;

      // Geometrik Konum Puanlaması (Fiyat Kutusunun Hemen Üstünde mi?)
      double konumSkoru = 50.0 + (s.yukseklik * 2.5); // Başlık fontu her zaman büyüktür!

      if (fiyatKutusu != null) {
        final dikeyMesafe = fiyatKutusu.top - s.kutu.bottom;

        if (dikeyMesafe >= -20 && dikeyMesafe <= 350) {
          // Fiyatın yukarısında ve yakınında: Çok yüksek puan
          konumSkoru += (350 - dikeyMesafe) / 4.0;

          // Yatayda fiyatla aynı sütunda mı?
          final yatayFark = (s.merkezX - (fiyatKutusu.left + fiyatKutusu.width / 2)).abs();
          if (yatayFark < 250) {
            konumSkoru += 40.0;
          }
        } else if (s.kutu.top > fiyatKutusu.bottom) {
          // Fiyatın altındaki satırlar
          konumSkoru -= 40.0;
        }
      }

      temizAdaylar.add(_UrunAdiAdayi(metin: metin, skor: konumSkoru));
    }

    if (temizAdaylar.isEmpty) return null;

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
