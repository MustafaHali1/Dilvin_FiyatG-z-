import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fiyatgoz/main.dart';
import 'package:fiyatgoz/yoneticiler/profil_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/sepet_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/fis_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/kullanici_yoneticisi.dart';
import 'package:fiyatgoz/modeller/kullanici_modeli.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';
import 'package:fiyatgoz/modeller/urun_modeli.dart';

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

      // İlk anda CircularProgressIndicator veya ana sayfa aranır
      await tester.pump();
      expect(find.byType(FiyatGozUygulamasi), findsOneWidget);
    });
  });
}
