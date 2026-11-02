import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/servisler/fiyat_tanima_servisi.dart';
import 'package:fiyatgoz/modeller/metin_satir_kutusu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Akıllı Fiyat ve Ürün Tanıma Servisi Testleri', () {
    final servis = FiyatTanimaServisi();

    test('Bilgisayar Ekranı & Dikey Banner Senaryosu: Dikey metinler elenmeli, 299 TL ve JOY BAHCE HORTUMU seçilmeli', () {
      final satirlar = [
        // Sol kenardaki scroll / simge
        const MetinSatirKutusu(
          metin: '< > 4.00 6.50',
          kutu: Rect.fromLTWH(10, 100, 40, 20),
        ),
        // Sağ taraftaki DİKEY Şikayetvar Web Bannerı (yükseklik: 400 piksel!)
        const MetinSatirKutusu(
          metin: 'Şok Marketler Şok Market Etiket Fiyat Yanlışlığı - Şikayetvar',
          kutu: Rect.fromLTWH(720, 50, 35, 400), // DİKEY SÜTUN!
        ),
        // Tek başına "Market" yazısı
        const MetinSatirKutusu(
          metin: 'Market',
          kutu: Rect.fromLTWH(720, 460, 35, 20),
        ),
        // Ürün Adı (20 M içeriyor)
        const MetinSatirKutusu(
          metin: 'JOY BAHCE HORTUMU 20 M',
          kutu: Rect.fromLTWH(200, 120, 350, 32),
        ),
        // Tek harfli gereksiz karakter
        const MetinSatirKutusu(
          metin: 'T',
          kutu: Rect.fromLTWH(200, 155, 20, 20),
        ),
        // Üretim bilgisi
        const MetinSatirKutusu(
          metin: 'Üretim: TÜRKİYE',
          kutu: Rect.fromLTWH(200, 180, 140, 18),
        ),
        // Birim fiyat satırı (TL/AD)
        const MetinSatirKutusu(
          metin: 'Birim Fiyatı: 299.00 TL/AD',
          kutu: Rect.fromLTWH(200, 200, 220, 18),
        ),
        // Devasa puntoyla yazılmış asıl satış fiyatı (299,00 veya 299.90)
        const MetinSatirKutusu(
          metin: '299,00',
          kutu: Rect.fromLTWH(360, 220, 180, 75), // Yükseklik: 75 (En büyük yatay yazı)
        ),
        // Hemen altında duran TL kutusu
        const MetinSatirKutusu(
          metin: 'TL',
          kutu: Rect.fromLTWH(550, 260, 40, 30),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(
        satirlar,
        goruntuGenisligi: 800,
        merkezOdakli: true,
      );

      expect(sonuc.basarili, isTrue);
      // Fiyat 6.50 veya 4.00 değil, 299.00 olmalı!
      expect(sonuc.tespitEdilenFiyat, 299.00);
      // Ürün adı 'Market' değil, 'JOY BAHCE HORTUMU 20 M' olmalı!
      expect(sonuc.tespitEdilenUrunAdi, 'JOY BAHCE HORTUMU 20 M');
    });

    test('E-Ticaret Web Sayfası Senaryosu: Sayfanın altındaki 8268.76 TL ve damga market elenmeli, merkezdeki 299 TL ve JOY BAHCE HORTUMU seçilmeli', () {
      final satirlar = [
        // Sayfanın en altındaki toptan kart ilanı ve fiyatı (Y: 650-700)
        const MetinSatirKutusu(
          metin: 'damga market San SOK FIYAT Etketi Kartı Market',
          kutu: Rect.fromLTWH(200, 620, 400, 30),
        ),
        const MetinSatirKutusu(
          metin: '8268.76 ₺',
          kutu: Rect.fromLTWH(250, 660, 200, 45),
        ),

        // Merkezdeki asıl market etiketi (Y: 150-350)
        const MetinSatirKutusu(
          metin: 'JOY BAHCE HORTUMU 20 M',
          kutu: Rect.fromLTWH(250, 160, 320, 30),
        ),
        const MetinSatirKutusu(
          metin: 'Üretim: TÜRKİYE',
          kutu: Rect.fromLTWH(250, 200, 150, 18),
        ),
        const MetinSatirKutusu(
          metin: 'Birim Fiyatı: 299.00 TL/AD',
          kutu: Rect.fromLTWH(250, 225, 230, 18),
        ),
        const MetinSatirKutusu(
          metin: '299,00 TL',
          kutu: Rect.fromLTWH(350, 260, 200, 70), // Merkezde ve büyük
        ),
        const MetinSatirKutusu(
          metin: '8 699037 130518',
          kutu: Rect.fromLTWH(250, 340, 200, 20),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(
        satirlar,
        goruntuGenisligi: 800,
        goruntuYuksekligi: 800,
        merkezOdakli: true,
      );

      expect(sonuc.basarili, isTrue);
      expect(sonuc.tespitEdilenFiyat, 299.00);
      expect(sonuc.tespitEdilenUrunAdi, 'JOY BAHCE HORTUMU 20 M');
      expect(sonuc.tespitEdilenUrunAdi?.contains('damga'), isFalse);
    });

    test('Virgülün 9 Olarak Okunması (2999) ve Çerçeve Çizgisi (1299) Senaryosu: 299.00 TL Doğrulanmalı', () {
      final satirlar = [
        const MetinSatirKutusu(
          metin: 'JOY BAHCE HORTUMU 20 M',
          kutu: Rect.fromLTWH(100, 100, 300, 30),
        ),
        // Yasal etiket referans birim fiyatı
        const MetinSatirKutusu(
          metin: 'Birim Fiyatı: 299.00 TL/AD',
          kutu: Rect.fromLTWH(100, 140, 250, 18),
        ),
        // OCR virgülü 9 okuyarak 2999,00 çıkarmış
        const MetinSatirKutusu(
          metin: '2999,00',
          kutu: Rect.fromLTWH(150, 180, 200, 70),
        ),
        const MetinSatirKutusu(
          metin: 'TL',
          kutu: Rect.fromLTWH(360, 210, 40, 30),
        ),
        // Barkod satırı parçaları
        const MetinSatirKutusu(
          metin: '8 699037 130518',
          kutu: Rect.fromLTWH(100, 280, 200, 20),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(satirlar);

      expect(sonuc.basarili, isTrue);
      // 2999.00 yerine düzeltilmiş ve referansla doğrulanmış 299.00 seçilmeli!
      expect(sonuc.tespitEdilenFiyat, 299.00);
      expect(sonuc.tespitEdilenUrunAdi, 'JOY BAHCE HORTUMU 20 M');
      // Barkod parçaları (18, 37, 77) aday olmamalı
      expect(sonuc.adayFiyatlar.contains(18.0), isFalse);
      expect(sonuc.adayFiyatlar.contains(37.0), isFalse);
    });

    test('Standart Tek Satır Fiyat ve Ürün Tespiti: Pınar Süt 1L 34.50 TL', () {
      final satirlar = [
        const MetinSatirKutusu(
          metin: 'PINAR SUT 1L',
          kutu: Rect.fromLTWH(100, 100, 300, 30),
        ),
        const MetinSatirKutusu(
          metin: '34,50 TL',
          kutu: Rect.fromLTWH(100, 150, 200, 60),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(satirlar);

      expect(sonuc.basarili, isTrue);
      expect(sonuc.tespitEdilenFiyat, 34.50);
      expect(sonuc.tespitEdilenUrunAdi, 'PINAR SUT 1L');
    });

    test('Hedef Ürün Arama Modu: Aranan süt ise süte öncelik verilmeli', () {
      final satirlar = [
        const MetinSatirKutusu(
          metin: 'Çikolatalı Gofret',
          kutu: Rect.fromLTWH(100, 50, 200, 25),
        ),
        const MetinSatirKutusu(
          metin: '12,50 TL',
          kutu: Rect.fromLTWH(100, 80, 150, 40),
        ),
        const MetinSatirKutusu(
          metin: 'Sütaş Yağlı Süt',
          kutu: Rect.fromLTWH(100, 150, 250, 30),
        ),
        const MetinSatirKutusu(
          metin: '32,00 TL',
          kutu: Rect.fromLTWH(100, 190, 180, 55),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(
        satirlar,
        hedefUrun: 'süt',
      );

      expect(sonuc.basarili, isTrue);
      expect(sonuc.tespitEdilenUrunAdi, 'Sütaş Yağlı Süt');
    });
  });
}
