import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/servisler/sesli_komut_servisi.dart';

void main() {
  group('SesliKomutServisi Testleri', () {
    late SesliKomutServisi servis;

    setUp(() {
      servis = SesliKomutServisi();
    });

    test('Sepete ekle niyetini doğru çözer', () {
      final s1 = servis.niyetCoz('sepete ekle');
      expect(s1.tur, KomutTuru.sepeteEkle);

      final s2 = servis.niyetCoz('bunu onayla');
      expect(s2.tur, KomutTuru.sepeteEkle);

      final s3 = servis.niyetCoz('tamam aldım');
      expect(s3.tur, KomutTuru.sepeteEkle);
    });

    test('İptal niyetini doğru çözer', () {
      final s1 = servis.niyetCoz('iptal et');
      expect(s1.tur, KomutTuru.iptal);

      final s2 = servis.niyetCoz('vazgeçtim alma');
      expect(s2.tur, KomutTuru.iptal);
    });

    test('Bütçe ve harcama sorgularını çözer', () {
      final s1 = servis.niyetCoz('kalan bütçem ne kadar');
      expect(s1.tur, KomutTuru.butceSorgula);

      final s2 = servis.niyetCoz('ne kadar param kaldı');
      expect(s2.tur, KomutTuru.butceSorgula);
    });

    test('Sepet özetini çözer', () {
      final s1 = servis.niyetCoz('sepette ne var');
      expect(s1.tur, KomutTuru.sepetOzeti);

      final s2 = servis.niyetCoz('toplam tutar ne kadar');
      expect(s2.tur, KomutTuru.sepetOzeti);
    });

    test('Adet belirleme komutlarını doğru çözer (Rakam ve Yazı)', () {
      final s1 = servis.niyetCoz('2 adet');
      expect(s1.tur, KomutTuru.adetBelirle);
      expect(s1.adet, 2);

      final s2 = servis.niyetCoz('üç tane');
      expect(s2.tur, KomutTuru.adetBelirle);
      expect(s2.adet, 3);

      final s3 = servis.niyetCoz('5 paket');
      expect(s3.tur, KomutTuru.adetBelirle);
      expect(s3.adet, 5);
    });

    test('Ürün arama niyetini ayıklar', () {
      final s1 = servis.niyetCoz('bana süt bul');
      expect(s1.tur, KomutTuru.urunAra);
      expect(s1.hedefUrun, 'süt');

      final s2 = servis.niyetCoz('zeytin ara');
      expect(s2.tur, KomutTuru.urunAra);
      expect(s2.hedefUrun, 'zeytin');
    });
  });
}
