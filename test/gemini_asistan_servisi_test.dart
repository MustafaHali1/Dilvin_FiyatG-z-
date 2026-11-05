import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/servisler/gemini_asistan_servisi.dart';
import 'package:fiyatgoz/servisler/sesli_komut_servisi.dart';

void main() {
  group('Gemini Akıllı Asistan Servisi Birim Testleri', () {
    test('GeminiNiyetSonucu JSON çözümlemesi eksiksiz ve dayanıklı olmalı', () {
      final json = {
        'komut': 'BUTCE_SORGULA',
        'hedefUrun': 'süt',
        'adet': 2,
        'cevap': 'Kalan bütçeniz 450 lira.',
      };

      final sonuc = GeminiNiyetSonucu.fromJson(json);
      expect(sonuc.komut, 'BUTCE_SORGULA');
      expect(sonuc.hedefUrun, 'süt');
      expect(sonuc.adet, 2);
      expect(sonuc.cevap, 'Kalan bütçeniz 450 lira.');
    });

    test('GeminiNiyetSonucu boş veya eksik JSON alanlarında çökmemeli', () {
      final json = <String, dynamic>{};
      final sonuc = GeminiNiyetSonucu.fromJson(json);
      expect(sonuc.komut, 'DIGER');
      expect(sonuc.hedefUrun, isNull);
      expect(sonuc.adet, isNull);
      expect(sonuc.cevap, '');
    });

    test('SesliKomutServisi yerel kurallarla 0ms anında niyet çözer', () async {
      final servis = SesliKomutServisi();
      final sonuc = await servis.niyetCozAkilli('sepete atıver');
      expect(sonuc.tur, KomutTuru.sepeteEkle);
    });

    test('Gemini API anahtarı güncellenebilir ve okunabilir olmalı', () {
      expect(GeminiAsistanServisi.apiKeyVarMi, isFalse);
      GeminiAsistanServisi.apiKeyGuncelle('TEST_API_KEY_12345');
      expect(GeminiAsistanServisi.apiKey, 'TEST_API_KEY_12345');
      expect(GeminiAsistanServisi.apiKeyVarMi, isTrue);
      // Temizle
      GeminiAsistanServisi.apiKeyGuncelle('');
      expect(GeminiAsistanServisi.apiKeyVarMi, isFalse);
    });
  });
}
