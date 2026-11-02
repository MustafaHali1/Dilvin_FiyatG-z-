/// Sesli asistan tarafından çözülen niyet (komut) türleri
enum KomutTuru {
  sepeteEkle,
  adetBelirle,
  iptal,
  butceSorgula,
  sepetOzeti,
  urunAra,
  belirsiz,
}

/// Çözümlenen sesli komutun detaylı verisi
class SesliKomutSonucu {
  final KomutTuru tur;
  final int? adet;
  final String? hedefUrun;
  final String hamMetin;

  const SesliKomutSonucu({
    required this.tur,
    this.adet,
    this.hedefUrun,
    required this.hamMetin,
  });

  @override
  String toString() =>
      'SesliKomutSonucu(tur: $tur, adet: $adet, hedefUrun: $hedefUrun, hamMetin: "$hamMetin")';
}

/// Kullanıcının Türkçe serbest konuşma cümlelerini kurallı komutlara ve niyetlere (NLU) dönüştüren zeki servis
class SesliKomutServisi {
  static const Map<String, int> _turkceSayilar = {
    'bir': 1,
    'iki': 2,
    'çift': 2,
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
  };

  /// Gelen serbest Türkçe konuşma metnini analiz eder ve asıl niyeti (Intent) çözer
  SesliKomutSonucu niyetCoz(String hamMetin) {
    final kucukMetin = _turkceKucult(hamMetin).trim();
    if (kucukMetin.isEmpty) {
      return SesliKomutSonucu(
        tur: KomutTuru.belirsiz,
        hamMetin: hamMetin,
      );
    }

    // 1. İptal / Vazgeç Komutları (Genişletilmiş)
    if (_iciriyorMu(kucukMetin, [
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
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.iptal,
        hamMetin: hamMetin,
      );
    }

    // 2. Bütçe ve Harcama Sorguları (Genişletilmiş)
    if (_iciriyorMu(kucukMetin, [
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
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.butceSorgula,
        hamMetin: hamMetin,
      );
    }

    // 3. Sepet Özeti ve Hesap Sorguları (Genişletilmiş)
    if (_iciriyorMu(kucukMetin, [
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
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.sepetOzeti,
        hamMetin: hamMetin,
      );
    }

    // 4. Hedef Ürün Arama (Radar için: "Bana süt bul", "Zeytin ara", "Peynir nerede", "Çay lazım")
    final aramaKomutu = _urunAramaNiyetiCoz(kucukMetin, hamMetin);
    if (aramaKomutu != null) {
      return aramaKomutu;
    }

    // 5. Adet Belirleme ("2 adet", "3 tane", "dört adet ekle", "5 tane yap", "çift al")
    final adetSonucu = _adetCoz(kucukMetin, hamMetin);
    if (adetSonucu != null) {
      return adetSonucu;
    }

    // 6. Sepete Ekleme / Onaylama (Genişletilmiş Halk Ağzı)
    if (_iciriyorMu(kucukMetin, [
      'sepete ekle',
      'sepete at',
      'sepete koy',
      'sepete atıver',
      'sepete ativer',
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
      'yaz sepete',
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.sepeteEkle,
        hamMetin: hamMetin,
      );
    }

    return SesliKomutSonucu(
      tur: KomutTuru.belirsiz,
      hamMetin: hamMetin,
    );
  }

  /// Metinden ürün arama niyetini ayıklar
  SesliKomutSonucu? _urunAramaNiyetiCoz(String kucukMetin, String hamMetin) {
    // 1. "bana süt bul", "zeytin nerede", "peynir ara", "çay getir", "ekmek lazım"
    final kalip = RegExp(
      r'(?:bana\s+)?([a-zA-ZçğıöşüÇĞİÖŞÜ0-9\s]+?)\s+(?:bul|ara|nerede|arıyorum|ariyorum|göster|goster|lazım|lazim|var mı|var mi)$',
    );
    final match = kalip.firstMatch(kucukMetin);
    if (match != null) {
      final hedef = match.group(1)?.trim();
      if (hedef != null && hedef.isNotEmpty && hedef.length > 1) {
        return SesliKomutSonucu(
          tur: KomutTuru.urunAra,
          hedefUrun: hedef,
          hamMetin: hamMetin,
        );
      }
    }

    // 2. "süt bulur musun", "zeytine bak"
    final kalip2 = RegExp(r'^(?:bana\s+)?([a-zA-ZçğıöşüÇĞİÖŞÜ0-9\s]+?)\s+(?:bulur musun|bakar mısın|bakar misin)$');
    final match2 = kalip2.firstMatch(kucukMetin);
    if (match2 != null) {
      final hedef = match2.group(1)?.trim();
      if (hedef != null && hedef.isNotEmpty && hedef.length > 1) {
        return SesliKomutSonucu(
          tur: KomutTuru.urunAra,
          hedefUrun: hedef,
          hamMetin: hamMetin,
        );
      }
    }

    return null;
  }

  /// Metinden adet bilgisini ayıklar ("2 adet", "üç tane", "5 paket", "çift al")
  SesliKomutSonucu? _adetCoz(String kucukMetin, String hamMetin) {
    // 1. Rakam ile adet: "2 adet", "3 tane", "5 paket ekle"
    final rakamReg = RegExp(r'(\d+)\s*(?:adet|tane|paket|kutu|şişe|tanesini)?');
    final rMatch = rakamReg.firstMatch(kucukMetin);
    if (rMatch != null) {
      final sayiStr = rMatch.group(1);
      final sayi = int.tryParse(sayiStr ?? '');
      if (sayi != null && sayi > 0 && sayi <= 99) {
        return SesliKomutSonucu(
          tur: KomutTuru.adetBelirle,
          adet: sayi,
          hamMetin: hamMetin,
        );
      }
    }

    // 2. Yazı ile sayı: "iki adet", "üç tane", "bir adet", "çift al"
    for (final entry in _turkceSayilar.entries) {
      if (kucukMetin.contains('${entry.key} adet') ||
          kucukMetin.contains('${entry.key} tane') ||
          kucukMetin.contains('${entry.key} paket') ||
          kucukMetin.contains('${entry.key} kutu') ||
          kucukMetin.startsWith('${entry.key} ')) {
        return SesliKomutSonucu(
          tur: KomutTuru.adetBelirle,
          adet: entry.value,
          hamMetin: hamMetin,
        );
      }
    }

    return null;
  }

  bool _iciriyorMu(String metin, List<String> anahtarlar) {
    for (final anahtar in anahtarlar) {
      if (metin.contains(anahtar)) return true;
    }
    return false;
  }

  String _turkceKucult(String metin) {
    return metin
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase();
  }
}
