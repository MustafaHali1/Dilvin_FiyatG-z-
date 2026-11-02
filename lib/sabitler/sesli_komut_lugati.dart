import '../servisler/sesli_komut_servisi.dart';

/// Kullanıcının istediği kelimeleri, şive kalıplarını ve günlük konuşma cümlelerini
/// dilediği gibi ekleyip çıkarabileceği merkezi Sesli Komut Sözlüğü (Vocabulary Sets).
class SesliKomutLugati {
  // =========================================================================
  // 🛒 1. SEPETE EKLEME / ONAY KELİMELERİ
  // (Kullanıcı bunlardan birini söylediğinde ürün sepete atılır)
  // =========================================================================
  static final Set<String> sepeteEkleKelimeleri = {
    'sepete ekle',
    'sepete at',
    'sepete koy',
    'sepete atıver',
    'sepete ativer',
    'yaz sepete',
    'sepete yaz',
    'onayla',
    'onaylıyorum',
    'onayliyorum',
    'ekle',
    'tamam',
    'aldım',
    'aldim',
    'kabul et',
    'satın al',
    'satin al',
    'bunu al',
    'bunu alalım',
    'bunu alalim',
    'bunu ekle',
    'bunu yaz',
    'alıyorum',
    'aliyorum',
    'koy bunu',
    'ekle gitsin',
    'olur',
    'tamamdır',
    'tamamdir',
    'ekle bakalım',
    'oldu',
    // ✍️ İstediğin yeni ekleme cümlelerini buraya tırnak içinde ekleyebilirsin:
    // 'at çantaya',
  };

  // =========================================================================
  // ❌ 2. İPTAL / VAZGEÇME KELİMELERİ
  // (Kullanıcı bunlardan birini söylediğinde işlem iptal edilir veya taranan ürün silinir)
  // =========================================================================
  static final Set<String> iptalKelimeleri = {
    'iptal',
    'vazgeç',
    'vazgec',
    'sil',
    'bırak',
    'birak',
    'kapat',
    'alma',
    'istemiyorum',
    'bunu alma',
    'çıkart',
    'cikart',
    'vazgectim',
    'vazgeçtim',
    'hayır',
    'hayir',
    'yok',
    'bosver',
    'boşver',
    'kalsın',
    'kalsin',
    'atma sepete',
    // ✍️ İstediğin yeni iptal cümlelerini buraya ekleyebilirsin:
  };

  // =========================================================================
  // 💰 3. BÜTÇE VE HARCAMA SORGULARI
  // (Kullanıcı bütçesini, kalan parasını veya limitini sorduğunda tetiklenir)
  // =========================================================================
  static final Set<String> butceSorgulari = {
    'bütçem',
    'butcem',
    'kalan bütçe',
    'param kaldı mı',
    'param kaldi mi',
    'ne kadar param kaldı',
    'ne kadar harcadım',
    'ne kadar harcadim',
    'harcamam',
    'harcama durumu',
    'bütçeyi aştım mı',
    'butceyi astim mi',
    'para bitti mi',
    'cebimde ne kaldı',
    'limiti aştık mı',
    'bütçe ne kadar',
    'para yetiyor mu',
    'kaç param var',
    'kac param var',
    'kalan para',
    // ✍️ İstediğin bütçe sorularını buraya ekleyebilirsin:
  };

  // =========================================================================
  // 🧾 4. SEPET ÖZETİ VE HESAP SORGULARI
  // (Sepetteki ürünleri, genel toplamı veya hesabı sorduğunda tetiklenir)
  // =========================================================================
  static final Set<String> sepetOzetiSorgulari = {
    'sepette ne var',
    'sepette neler var',
    'sepeti oku',
    'sepeti söyle',
    'sepeti soyle',
    'toplam ne kadar',
    'toplam tutar',
    'toplam ne tuttu',
    'ne kadar tuttu',
    'hesap ne kadar',
    'kaça patladı',
    'kaca patladi',
    'kaç ürün var',
    'kac urun var',
    'sepet durumu',
    'neler aldım',
    'neler aldim',
    'aldıklarım',
    'aldiklarim',
    'sepeti göster',
    'sepeti goster',
    'listeyi oku',
    'sepet özeti',
    'kaç para tuttu',
    'kac para tuttu',
    // ✍️ İstediğin hesap/sepet sorularını buraya ekleyebilirsin:
  };

  // =========================================================================
  // 🔢 5. YAZIYLA SAYI VE ADET EŞLEŞTİRMELERİ
  // (Söylenen kelimeyi rakamsal adede dönüştürür)
  // =========================================================================
  static final Map<String, int> sayiKarsiliklari = {
    'bir': 1,
    'tek': 1,
    'iki': 2,
    'çift': 2,
    'cift': 2,
    'üç': 3,
    'uc': 3,
    'dört': 4,
    'dort': 4,
    'beş': 5,
    'bes': 5,
    'altı': 6,
    'alti': 6,
    'yedi': 7,
    'sekiz': 8,
    'dokuz': 9,
    'on': 10,
    // ✍️ Yeni adet kalıpları ekleyebilirsin:
    'düzine': 12,
    'deste': 10,
  };

  /// İstenirse çalışma anında (runtime) koddan yeni kelime eklemek için metot
  static void kelimeEkle(KomutTuru tur, String yeniKelime) {
    final k = yeniKelime.toLowerCase().trim();
    switch (tur) {
      case KomutTuru.sepeteEkle:
        sepeteEkleKelimeleri.add(k);
        break;
      case KomutTuru.iptal:
        iptalKelimeleri.add(k);
        break;
      case KomutTuru.butceSorgula:
        butceSorgulari.add(k);
        break;
      case KomutTuru.sepetOzeti:
        sepetOzetiSorgulari.add(k);
        break;
      default:
        break;
    }
  }
}
