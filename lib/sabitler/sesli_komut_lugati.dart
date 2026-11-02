import '../servisler/sesli_komut_servisi.dart';

/// Kullanıcının sesli komutlarını, sokak/market Türkçesini ve günlük konuşma kalıplarını
/// içeren zengin veri seti ve sözlük (Vocabulary Dataset)
class AsistanVeriSeti {
  // =========================================================================
  // 🤝 1. SELAMLAŞMA, HAL-HATIR VE GİRİŞ
  // =========================================================================
  static final Set<String> selamlamaKelimeleri = {
    'merhaba', 'merhabalar', 'selam', 'selamlar', 'selamün aleyküm', 'selamun aleykum',
    'sa', 'as', 'günaydın', 'gunaydin', 'iyi günler', 'iyi gunler', 'iyi akşamlar',
    'iyi aksamlar', 'naber', 'ne haber', 'nasılsın', 'nasilsin', 'nasıl gidiyor',
    'nasil gidiyor', 'ne var ne yok', 'ses ver', 'orada mısın', 'orada misin',
    'uyandın mı', 'uyandin mi', 'heey', 'pişt', 'pist', 'bakar mısın', 'bakar misin',
    'alo', 'burada mısın', 'burada misin', 'canım', 'kolay gelsin'
  };

  // =========================================================================
  // 🙋‍♂️ 2. YARDIM VE ASİSTAN KAPASİTESİ SORGULARI
  // =========================================================================
  static final Set<String> yardimKelimeleri = {
    'yardım', 'yardim', 'yardım et', 'yardim et', 'ne yapabilirsin', 'neler yapabilirsin',
    'sen kimsin', 'görevin ne', 'gorevin ne', 'komutlar', 'komutları söyle', 'neler var',
    'nasıl kullanırım', 'nasil kullanirim', 'bana yardım et', 'yardımcı olur musun',
    'ne işe yararsın', 'ne ise yararsin', 'menü', 'menu', 'neler biliyorsun', 'yardım lütfen'
  };

  // =========================================================================
  // 🛒 3. SEPETE EKLEME VE GENEL ONAY
  // =========================================================================
  static final Set<String> sepeteEkleKelimeleri = {
    'sepete ekle', 'sepete at', 'sepete koy', 'sepete atıver', 'sepete ativer',
    'yaz sepete', 'sepete yaz', 'sepete fırlat', 'sepete firlat', 'sepete salla',
    'at sepete', 'koy sepete', 'sepete iliştir', 'sepete ilistir', 'torbaya at',
    'torbaya koy', 'çantaya at', 'cantaya at', 'poşete at', 'posete at',
    'ekle', 'ekle gitsin', 'ekle bakalım', 'ekle bakalim', 'yapıştır', 'yapistir',
    'aldım', 'aldim', 'alıyorum', 'aliyorum', 'aldık', 'aldik', 'satın al', 'satin al',
    'bunu al', 'bunu alalım', 'bunu alalim', 'bunu da al', 'bunu ekle', 'bunu yaz',
    'bunu koy', 'koy bunu', 'koy gitsin', 'sar bunu', 'paketle', 'kasaya yolla',
    'onayla', 'onaylıyorum', 'onayliyorum', 'onay ver', 'tamam', 'tamamdır', 'tamamdir',
    'olur', 'oldu', 'kabul', 'kabul et', 'uyar', 'anlaştık', 'anlastik',
    'yolla gelsin', 'yaz tahtaya', 'yaz bunu', 'yaz listeye', 'lazım bu', 'lazim bu',
    'iş görür', 'is gorur', 'geç sepete', 'gec sepete', 'hadi alalım', 'hadi alalim',
    'bunu seçtim', 'bunu sectim'
  };

  // =========================================================================
  // ❌ 4. İPTAL, VAZGEÇME VE SEPETTEN ÇIKARMA
  // =========================================================================
  static final Set<String> iptalKelimeleri = {
    'iptal', 'iptal et', 'vazgeç', 'vazgec', 'vazgeçtim', 'vazgectim', 'sil',
    'kaldır', 'kaldir', 'sil gitsin', 'çıkart', 'cikart', 'sepetten çıkar',
    'sepetten çıkart', 'bırak', 'birak', 'kapat', 'geri al', 'işlemi durdur',
    'alma', 'bunu alma', 'istemiyorum', 'bunu istemiyorum', 'istemem', 'kalsın',
    'kalsin', 'böyle kalsın', 'orada kalsın', 'atma sepete', 'koyma', 'ekleme',
    'bunu ekleme', 'yazma', 'listeden sil', 'sepetten sil', 'sepetten at',
    'hayır', 'hayir', 'yok', 'yok vazgeçtim', 'yok alma', 'boşver', 'bosver',
    'aman boşver', 'değmez', 'degmez', 'gerek yok', 'ihtiyaç yok', 'ihtiyac yok',
    'pahalıymış', 'pahaliymis', 'kurtarmaz', 'bunu geç', 'bunu gec', 'geç bunu',
    'gec bunu', 'pas geç', 'pas gec', 'sonra bakarız', 'sonra bakariz',
    'dursun şimdilik', 'dursun simdilik'
  };

  // =========================================================================
  // 💰 5. BÜTÇE, LİMİT VE KALAN PARA SORGULARI
  // =========================================================================
  static final Set<String> butceSorgulari = {
    'bütçem', 'butcem', 'bütçe ne kadar', 'butce ne kadar', 'kalan bütçe', 'kalan butce',
    'bütçe durumu', 'bütçede ne var', 'bütçe ne durumda', 'param kaldı mı', 'param kaldi mi',
    'para kaldı mı', 'ne kadar param kaldı', 'ne kadar param kaldi', 'kaç param var',
    'kac param var', 'kaç param kaldı', 'kac param kaldi', 'kalan para', 'cebimde ne kaldı',
    'cebimde ne kaldi', 'cüzdanda ne var', 'cuzdanda ne var', 'para bitti mi',
    'para yetiyor mu', 'param yetecek mi', 'limiti aştık mı', 'limiti astik mi',
    'bütçeyi aştım mı', 'butceyi astim mi', 'sınırı geçtik mi', 'siniri gectik mi',
    'limit ne durumda', 'harcamam', 'harcama durumu', 'ne kadar harcadım',
    'ne kadar harcadim', 'toplam harcama', 'ne harcadık', 'ne harcadik',
    'bütçeden ne gitti', 'patladık mı', 'patladik mi'
  };

  // =========================================================================
  // 🧾 6. SEPET ÖZETİ, HESAP VE LİSTE SORGULARI
  // =========================================================================
  static final Set<String> sepetOzetiSorgulari = {
    'sepette ne var', 'sepette neler var', 'sepeti oku', 'sepeti söyle', 'sepeti soyle',
    'sepeti göster', 'sepeti goster', 'sepet durumu', 'sepet özeti', 'sepet ozeti',
    'neler aldım', 'neler aldim', 'aldıklarım', 'aldiklarim', 'aldıklarımı göster',
    'listeyi oku', 'listede ne var', 'çantamda ne var', 'cantamda ne var',
    'sepettekileri say', 'kaç ürün var', 'kac urun var', 'kaç parça oldu',
    'kac parca oldu', 'kaç tane aldım', 'kac tane aldim', 'ürün sayısı', 'urun sayisi',
    'sepet doldu mu', 'toplam ne kadar', 'toplam tutar', 'toplam ne tuttu',
    'ne kadar tuttu', 'hesap ne kadar', 'hesap nedir', 'hesap ne tuttu',
    'borcumuz ne', 'borç ne kadar', 'borc ne kadar', 'kaça patladı', 'kaca patladi',
    'kaç para tuttu', 'kac para tuttu', 'fatura ne kadar', 'kasa toplamı', 'kasa toplami'
  };

  // =========================================================================
  // 🧹 7. SEPETİ TAMAMEN SIFIRLAMA
  // =========================================================================
  static final Set<String> sepetSifirlamaKelimeleri = {
    'sepeti boşalt', 'sepeti bosalt', 'sepeti sıfırla', 'sepeti sifirla',
    'hepsini sil', 'her şeyi sil', 'her seyi sil', 'tümünü sil', 'tumunu sil',
    'sepeti temizle', 'baştan başla', 'bastan basla', 'her şeyi iptal et',
    'her seyi iptal et', 'sepeti dök', 'sepeti dok'
  };

  // =========================================================================
  // 🙏 8. TEŞEKKÜR VE VEDA
  // =========================================================================
  static final Set<String> tesekkurVedaKelimeleri = {
    'teşekkürler', 'tesekkurler', 'teşekkür ederim', 'tesekkur ederim',
    'sağ ol', 'sag ol', 'eyvallah', 'adamsın', 'adamsin', 'harikasın', 'harikasin',
    'süpersin', 'supersin', 'görüşürüz', 'gorusuruz', 'bay bay', 'hoşça kal',
    'hosca kal', 'kendine iyi bak', 'güle güle', 'gule gule', 'eline sağlık', 'eline saglik'
  };

  // =========================================================================
  // 🔢 9. YAZIYLA SAYI VE ADET EŞLEŞTİRMELERİ
  // =========================================================================
  static final Map<String, int> sayiKarsiliklari = {
    'sıfır': 0, 'sifir': 0, 'bir': 1, 'tek': 1, 'tane': 1, 'adet': 1,
    'iki': 2, 'çift': 2, 'cift': 2, 'üç': 3, 'uc': 3, 'dört': 4, 'dort': 4,
    'beş': 5, 'bes': 5, 'altı': 6, 'alti': 6, 'yedi': 7, 'sekiz': 8, 'dokuz': 9,
    'on': 10, 'on bir': 11, 'onbir': 11, 'on iki': 12, 'oniki': 12, 'düzine': 12,
    'duzine': 12, 'on üç': 13, 'onüç': 13, 'on dört': 14, 'ondört': 14,
    'on beş': 15, 'onbeş': 15, 'on altı': 16, 'onaltı': 16, 'on yedi': 17,
    'onyedi': 17, 'on sekiz': 18, 'onsekiz': 18, 'on dokuz': 19, 'ondokuz': 19,
    'yirmi': 20, 'otuz': 30, 'kırk': 40, 'kirk': 40, 'elli': 50, 'deste': 10
  };

  /// Dinamik olarak çalışma anında yeni kelime eklemek için
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
      case KomutTuru.sepetiSifirla:
        sepetSifirlamaKelimeleri.add(k);
        break;
      case KomutTuru.selamlama:
        selamlamaKelimeleri.add(k);
        break;
      case KomutTuru.tesekkurVeda:
        tesekkurVedaKelimeleri.add(k);
        break;
      case KomutTuru.yardim:
        yardimKelimeleri.add(k);
        break;
      default:
        break;
    }
  }
}

/// Geriye dönük uyumluluk için takma ad (alias)
typedef SesliKomutLugati = AsistanVeriSeti;
