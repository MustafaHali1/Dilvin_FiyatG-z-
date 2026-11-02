import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/servisler/fiyat_tanima_servisi.dart';
import 'package:fiyatgoz/modeller/metin_satir_kutusu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Akıllı Fiyat ve Ürün Tanıma Servisi Testleri', () {
    final servis = FiyatTanimaServisi();

    test('Bahçe Hortumu Gerçek Market Etiketi Senaryosu: 20 M elenmeli, 299.00 TL ve JOY BAHCE HORTUMU 20 M seçilmeli', () {
      // Kullanıcının çektiği gerçek market görselinin kutu koordinatları simülasyonu
      final satirlar = [
        // Sol kenardaki kitap (Arapça yazı / Ajisal Gsall)
        const MetinSatirKutusu(
          metin: 'Ajisal Gsall',
          kutu: Rect.fromLTWH(10, 100, 60, 250),
        ),
        // Sağ üstteki market bannerı
        const MetinSatirKutusu(
          metin: 'Şok Marketler Şok Market Etiket Fiyat',
          kutu: Rect.fromLTWH(700, 50, 80, 300),
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
        // Devasa puntoyla yazılmış asıl satış fiyatı tamsayısı (299)
        const MetinSatirKutusu(
          metin: '299',
          kutu: Rect.fromLTWH(360, 220, 180, 85), // Yükseklik: 85 (En büyük yazı)
        ),
        // Yanındaki kuruş ve para birimi kutusu (,00 TL)
        const MetinSatirKutusu(
          metin: ',00 TL',
          kutu: Rect.fromLTWH(545, 225, 75, 45),
        ),
      ];

      final sonuc = servis.satirlardanFiyatVeUrunCikar(
        satirlar,
        goruntuGenisligi: 800,
        merkezOdakli: true,
      );

      expect(sonuc.basarili, isTrue);
      // Fiyat 20 M'deki 20 değil, kesinlikle 299.00 olmalı
      expect(sonuc.tespitEdilenFiyat, 299.00);
      // Ürün adı kitap değil, 'JOY BAHCE HORTUMU 20 M' olmalı
      expect(sonuc.tespitEdilenUrunAdi, 'JOY BAHCE HORTUMU 20 M');
      // 20.00 fiyata aday bile olmamalı
      expect(sonuc.adayFiyatlar.contains(20.00), isFalse);
    });

    test('Standart Tek Satır Fiyat ve Ürün Tespiti: Pınar Süt 1L 34.50 TL', () {
      final satirlar = [
        const MetinSatirKutusu(
          metin: 'PINAR SUT 1L',
          kutu: Rect.fromLTWH(100, 100, 300, 30),
        ),
        const MetinSatirKutusu(
          metin: '34,50 TL',
          kutu: Rect.fromLTWH(100, 150, 200, 60), // En büyük punto
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
