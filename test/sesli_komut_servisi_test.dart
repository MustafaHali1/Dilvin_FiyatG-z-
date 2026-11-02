import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/servisler/sesli_komut_servisi.dart';

void main() {
  group('SesliKomutServisi Testleri', () {
    late SesliKomutServisi servis;

    setUp(() {
      servis = SesliKomutServisi();
    });

    test('Sepete ekle niyetini zengin sokak diliyle çözer', () {
      final s1 = servis.niyetCoz('sepete ekle');
      expect(s1.tur, KomutTuru.sepeteEkle);

      final s2 = servis.niyetCoz('bunu onayla');
      expect(s2.tur, KomutTuru.sepeteEkle);

      final s3 = servis.niyetCoz('tamam aldım');
      expect(s3.tur, KomutTuru.sepeteEkle);

      final s4 = servis.niyetCoz('çantaya at');
      expect(s4.tur, KomutTuru.sepeteEkle);

      final s5 = servis.niyetCoz('yapıştır');
      expect(s5.tur, KomutTuru.sepeteEkle);

      final s6 = servis.niyetCoz('sepete fırlat');
      expect(s6.tur, KomutTuru.sepeteEkle);
    });

    test('İptal niyetini ve argo/sokak kalıplarını doğru çözer', () {
      final s1 = servis.niyetCoz('iptal et');
      expect(s1.tur, KomutTuru.iptal);

      final s2 = servis.niyetCoz('vazgeçtim alma');
      expect(s2.tur, KomutTuru.iptal);

      final s3 = servis.niyetCoz('pahalıymış kurtarmaz');
      expect(s3.tur, KomutTuru.iptal);

      final s4 = servis.niyetCoz('pas geç');
      expect(s4.tur, KomutTuru.iptal);
    });

    test('Bütçe ve harcama sorgularını çözer', () {
      final s1 = servis.niyetCoz('kalan bütçem ne kadar');
      expect(s1.tur, KomutTuru.butceSorgula);

      final s2 = servis.niyetCoz('ne kadar param kaldı');
      expect(s2.tur, KomutTuru.butceSorgula);

      final s3 = servis.niyetCoz('patladık mı limit ne durumda');
      expect(s3.tur, KomutTuru.butceSorgula);
    });

    test('Sepet özetini ve hesap sorgularını çözer', () {
      final s1 = servis.niyetCoz('sepette ne var');
      expect(s1.tur, KomutTuru.sepetOzeti);

      final s2 = servis.niyetCoz('toplam tutar ne kadar');
      expect(s2.tur, KomutTuru.sepetOzeti);

      final s3 = servis.niyetCoz('kaça patladı hesap ne tuttu');
      expect(s3.tur, KomutTuru.sepetOzeti);
    });

    test('Selamlama, Teşekkür, Yardım ve Sıfırlama niyetlerini çözer', () {
      expect(servis.niyetCoz('merhaba naber').tur, KomutTuru.selamlama);
      expect(servis.niyetCoz('sağ ol eyvallah adamsın').tur, KomutTuru.tesekkurVeda);
      expect(servis.niyetCoz('bana yardım et ne yapabilirsin').tur, KomutTuru.yardim);
      expect(servis.niyetCoz('sepeti boşalt her şeyi sil').tur, KomutTuru.sepetiSifirla);
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

      final s4 = servis.niyetCoz('çift al');
      expect(s4.tur, KomutTuru.adetBelirle);
      expect(s4.adet, 2);
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
