import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fiyatgoz/main.dart';
import 'package:fiyatgoz/yoneticiler/profil_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/sepet_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/fis_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/kullanici_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/fiyat_onay_yoneticisi.dart';
import 'package:fiyatgoz/modeller/kullanici_modeli.dart';
import 'package:fiyatgoz/modeller/profil_modeli.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';
import 'package:fiyatgoz/modeller/urun_modeli.dart';
import 'package:fiyatgoz/modeller/fiyat_tanima_sonucu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model ve Veri Dönüşüm Testleri', () {
    test('KullaniciModeli toMap ve fromMap doğru çalışmalı', () {
      final simdi = DateTime.now();
      final kullanici = KullaniciModeli(
        id: 1,
        adSoyad: 'Ali Kaya',
        eposta: 'ali@test.com',
        epostaBulteniAktif: true,
        kayitTarihi: simdi,
      );

      final map = kullanici.toMap();
      expect(map['id'], 1);
      expect(map['ad_soyad'], 'Ali Kaya');
      expect(map['eposta_bulteni_aktif'], 1);

      final donusen = KullaniciModeli.fromMap(map);
      expect(donusen.adSoyad, 'Ali Kaya');
      expect(donusen.eposta, 'ali@test.com');
      expect(donusen.epostaBulteniAktif, true);
    });

    test('FisModeli ve UrunModeli harcama/tasarruf hesaplaması', () {
      final urun1 = const UrunModeli(
        id: '1',
        ad: 'Süt',
        birimFiyat: 20.0,
        eskiFiyat: 25.0,
        adet: 2,
      );
      final urun2 = const UrunModeli(
        id: '2',
        ad: 'Ekmek',
        birimFiyat: 10.0,
        adet: 1,
      );

      final fis = FisModeli(
        id: 'F-1',
        aciklama: 'Test Fişi',
        marketAdi: 'BİM',
        tarih: DateTime.now(),
        urunler: [urun1, urun2],
      );

      // Toplam: (20*2) + (10*1) = 50.0
      expect(fis.toplamTutar, 50.0);
      // Tasarruf: (25 - 20) * 2 = 10.0
      expect(fis.toplamIndirim, 10.0);
      expect(fis.toplamUrunAdedi, 3);
    });

    test('ProfilModeli bütçe dönemi ve tarih hesaplamaları doğru çalışmalı', () {
      final baslangic = DateTime(2026, 11, 1);
      final bitis = DateTime(2026, 11, 30, 23, 59, 59);

      final profil = ProfilModeli(
        aylikButce: 7500.0,
        butceBaslangicTarihi: baslangic,
        butceBitisTarihi: bitis,
      );

      expect(profil.aylikButce, 7500.0);
      expect(profil.etkinButceBaslangic, baslangic);
      expect(profil.etkinButceBitis, bitis);
      expect(profil.butceDonemiFormatli, '1 Kas - 30 Kas');
      expect(profil.kalanGunSayisi, greaterThanOrEqualTo(0));
    });
  });

  group('Fiyat Tanıma ve OCR Modelleri Testi', () {
    test('FiyatTanimaSonucu varsayılan ve örnek fabrika metotları', () {
      final ornek = FiyatTanimaSonucu.ornek();
      expect(ornek.basarili, true);
      expect(ornek.tespitEdilenFiyat, 24.90);
      expect(ornek.adayFiyatlar.length, 2);

      final bos = FiyatTanimaSonucu.bos(hata: 'Hata var');
      expect(bos.basarili, false);
      expect(bos.tespitEdilenFiyat, null);
      expect(bos.hataMesaji, 'Hata var');
    });

    test('FiyatOnayYoneticisi adet ve onay verisi doğrulaması', () {
      final yonetici = FiyatOnayYoneticisi();
      yonetici.urunAdiDenetleyici.text = 'Çay 1000g';
      yonetici.fiyatDenetleyici.text = '145.50';
      yonetici.adetArtir();
      expect(yonetici.adet, 2);

      final veri = yonetici.onayVerisiHazirla();
      expect(veri, isNotNull);
      expect(veri!['ad'], 'Çay 1000g');
      expect(veri['birimFiyat'], 145.50);
      expect(veri['adet'], 2);
    });
  });

  group('Uygulama Iskeleti Testi', () {
    testWidgets('Uygulama MultiProvider ile ayağa kalkmalı', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfilYoneticisi()),
            ChangeNotifierProvider(create: (_) => SepetYoneticisi()),
            ChangeNotifierProvider(create: (_) => FisYoneticisi()),
            ChangeNotifierProvider(create: (_) => KullaniciYoneticisi()),
          ],
          child: const FiyatGozUygulamasi(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
      expect(find.byType(FiyatGozUygulamasi), findsOneWidget);
    });
  });
}
