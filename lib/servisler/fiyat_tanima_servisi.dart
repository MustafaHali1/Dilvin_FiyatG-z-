import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../modeller/fiyat_tanima_sonucu.dart';

/// Market etiketlerinden fiyat ve ürün bilgisini çıkaran akıllı OCR servisi (Singleton)
class FiyatTanimaServisi {
  static final FiyatTanimaServisi _ornek = FiyatTanimaServisi._dahili();
  factory FiyatTanimaServisi() => _ornek;
  FiyatTanimaServisi._dahili();

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Verilen görsel dosyasını OCR işleminden geçirip akıllı fiyat & ürün adaylarını döner
  Future<FiyatTanimaSonucu> resmiTara(String resimYolu) async {
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

      final tumSatirlar = <String>[];
      final List<_FiyatAdayi> adaylar = [];
      final List<String> metinSatirlari = [];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final satirMetni = line.text.trim();
          if (satirMetni.isNotEmpty) {
            tumSatirlar.add(satirMetni);
            metinSatirlari.add(satirMetni);
          }

          final kutuYuksekligi = line.boundingBox.height;
          _satirdanFiyatAdaylariniCikar(line.text, kutuYuksekligi, adaylar);
        }
      }

      // Ürün adını metin bloklarından tahmin et
      final urunAdi = _urunAdiTahminEt(metinSatirlari);

      if (adaylar.isEmpty) {
        return FiyatTanimaSonucu(
          tespitEdilenFiyat: null,
          adayFiyatlar: const [],
          tespitEdilenUrunAdi: urunAdi,
          guvenSkoru: 0.0,
          tumSatirlar: tumSatirlar,
          basarili: false,
          hataMesaji: 'Etikette fiyat tespit edilemedi. Lütfen elle giriniz.',
        );
      }

      // Adayları sezgisel puanlarına göre sırala (en yüksek puan en önde)
      adaylar.sort((a, b) => b.skor.compareTo(a.skor));

      // Tekrarlanan fiyatları temizle (virgülden sonra 2 basamağa göre tekil)
      final Set<double> tekilFiyatlar = {};
      final List<double> siraliAdaylar = [];
      for (final aday in adaylar) {
        if (!tekilFiyatlar.contains(aday.fiyat)) {
          tekilFiyatlar.add(aday.fiyat);
          siraliAdaylar.add(aday.fiyat);
        }
      }

      final enIyiFiyat = siraliAdaylar.isNotEmpty ? siraliAdaylar.first : null;
      final guvenSkoru = adaylar.isNotEmpty ? (adaylar.first.skor / 100).clamp(0.1, 0.99) : 0.0;

      return FiyatTanimaSonucu(
        tespitEdilenFiyat: enIyiFiyat,
        adayFiyatlar: siraliAdaylar,
        tespitEdilenUrunAdi: urunAdi,
        guvenSkoru: guvenSkoru,
        tumSatirlar: tumSatirlar,
        basarili: enIyiFiyat != null,
      );
    } catch (e) {
      return FiyatTanimaSonucu.bos(hata: 'OCR işlemi sırasında hata oluştu: $e');
    }
  }

  /// Tek bir satırdan Türk Lirası fiyat modellerini ayıklar ve puanlar
  void _satirdanFiyatAdaylariniCikar(
    String satir,
    double kutuYuksekligi,
    List<_FiyatAdayi> adaylar,
  ) {
    final kucukSatir = satir.toLowerCase();

    // Filtre: Eğer satır sadece tarih veya saatse atla
    if (RegExp(r'\b\d{2}[./]\d{2}[./]\d{4}\b').hasMatch(satir)) return;

    // Türkiye Fiyat Regex Kalıpları
    // 1) "24,90 TL", "24.90 ₺", "1.249,50"
    // 2) Kuruşsuz tam sayılar: "25 TL", "50 ₺"
    final regex = RegExp(
      r'(?:₺|TL)?\s*(\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{1,2})|\d{1,4})\s*(?:₺|TL|kr)?',
      caseSensitive: false,
    );

    final eslesmeler = regex.allMatches(satir);

    for (final eslesme in eslesmeler) {
      final hamMetin = eslesme.group(1);
      if (hamMetin == null) continue;

      final fiyat = _fiyatNormalizeEt(hamMetin);
      if (fiyat == null || fiyat <= 0.0 || fiyat > 50000.0) continue;

      // 6 basamaklı barkod gibi sayıları ele
      if (!hamMetin.contains(',') && !hamMetin.contains('.') && hamMetin.length > 4) {
        continue;
      }

      // Yıl gibi duran 2024, 2025, 2026 sayılarını ele
      if ((fiyat == 2024 || fiyat == 2025 || fiyat == 2026) &&
          !satir.contains('₺') &&
          !satir.contains('TL')) {
        continue;
      }

      // Sezgisel Puan Hesaplama
      double skor = 50.0;

      // 1. Yazı Boyutu (Punto Büyüklüğü): Market etiketinde satış fiyatı daima en büyüktür
      skor += (kutuYuksekligi * 1.5).clamp(0.0, 40.0);

      // 2. Para Birimi Vurgusu: Satırda ₺ veya TL sembolü varsa +30 puan
      if (satir.contains('₺') || kucukSatir.contains('tl')) {
        skor += 30.0;
      }

      // 3. İndirim ve Fiyat Kelimeleri
      if (kucukSatir.contains('fiyat') || kucukSatir.contains('indirim') || kucukSatir.contains('tutar')) {
        skor += 15.0;
      }

      // 4. Negatif İpuçları (Birim / kg / gramaj fiyatı)
      if (kucukSatir.contains('/kg') ||
          kucukSatir.contains('/lt') ||
          kucukSatir.contains('/adet') ||
          kucukSatir.contains('kdv') ||
          kucukSatir.contains('barkod')) {
        skor -= 25.0;
      }

      adaylar.add(_FiyatAdayi(fiyat: fiyat, skor: skor));
    }
  }

  /// "24,90" -> 24.90, "1.249,50" -> 1249.50, "15" -> 15.0
  double? _fiyatNormalizeEt(String ham) {
    try {
      String temiz = ham.trim();

      if (temiz.contains('.') && temiz.contains(',')) {
        // Binlik nokta, kuruş virgül: 1.249,50 -> 1249.50
        temiz = temiz.replaceAll('.', '').replaceAll(',', '.');
      } else if (temiz.contains(',')) {
        // 24,90 -> 24.90
        temiz = temiz.replaceAll(',', '.');
      }

      return double.tryParse(temiz);
    } catch (_) {
      return null;
    }
  }

  /// Satırların arasından en makul ürün adı adayını seçer
  String? _urunAdiTahminEt(List<String> satirlar) {
    for (final satir in satirlar) {
      final temiz = satir.trim();
      if (temiz.length < 3) continue;

      final kucuk = temiz.toLowerCase();

      // Market ve fiş başlıklarını ele
      if (kucuk.contains('migros') ||
          kucuk.contains('a101') ||
          kucuk.contains('bim') ||
          kucuk.contains('şok') ||
          kucuk.contains('carrefour') ||
          kucuk.contains('tarih') ||
          kucuk.contains('fiş no') ||
          kucuk.contains('kasiyer') ||
          kucuk.contains('toplam') ||
          kucuk.contains('kdv')) {
        continue;
      }

      // Sadece sayılardan veya tarihten oluşanları ele
      if (RegExp(r'^\d+[\s.,\d]*$').hasMatch(temiz)) continue;

      // En az bir Türkçe/Latin harf içermeli
      if (RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ]').hasMatch(temiz)) {
        return temiz;
      }
    }
    return null;
  }

  /// OCR kaynaklarını serbest bırakır
  Future<void> kapat() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}

class _FiyatAdayi {
  final double fiyat;
  final double skor;
  const _FiyatAdayi({required this.fiyat, required this.skor});
}
