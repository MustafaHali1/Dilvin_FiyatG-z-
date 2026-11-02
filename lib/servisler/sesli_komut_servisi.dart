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

/// Kullanıcının Türkçe serbest konuşma cümlelerini kurallı komutlara ve niyetlere (NLU) dönüştüren servis
class SesliKomutServisi {
  static const Map<String, int> _turkceSayilar = {
    'bir': 1,
    'iki': 2,
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

  /// Gelen sesli metni analiz eder ve niyetini çıkarır
  SesliKomutSonucu niyetCoz(String hamMetin) {
    final kucukMetin = _turkceKucult(hamMetin).trim();
    if (kucukMetin.isEmpty) {
      return SesliKomutSonucu(
        tur: KomutTuru.belirsiz,
        hamMetin: hamMetin,
      );
    }

    // 1. İptal / Vazgeç Komutları
    if (_iciriyorMu(kucukMetin, ['iptal', 'vazgeç', 'vazgec', 'sil', 'bırak', 'birak', 'kapat', 'alma'])) {
      return SesliKomutSonucu(
        tur: KomutTuru.iptal,
        hamMetin: hamMetin,
      );
    }

    // 2. Bütçe ve Harcama Sorguları
    if (_iciriyorMu(kucukMetin, [
      'bütçem',
      'butcem',
      'kalan bütçe',
      'ne kadar param kaldı',
      'param kaldı mı',
      'bütçeyi aştım mı',
      'bütçe durumu',
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.butceSorgula,
        hamMetin: hamMetin,
      );
    }

    // 3. Sepet Özeti ve Toplam Sorguları
    if (_iciriyorMu(kucukMetin, [
      'sepette ne var',
      'sepeti oku',
      'toplam ne kadar',
      'toplam tutar',
      'kaç ürün var',
      'kac urun var',
      'sepet durumu',
    ])) {
      return SesliKomutSonucu(
        tur: KomutTuru.sepetOzeti,
        hamMetin: hamMetin,
      );
    }

    // 4. Hedef Ürün Arama (Radar için: "Bana süt bul", "Zeytin ara", "Hortum nerede")
    final aramaKomutu = _urunAramaNiyetiCoz(kucukMetin, hamMetin);
    if (aramaKomutu != null) {
      return aramaKomutu;
    }

    // 5. Adet Belirleme ("2 adet", "3 tane", "dört adet ekle", "5 tane yap")
    final adetSonucu = _adetCoz(kucukMetin, hamMetin);
    if (adetSonucu != null) {
      return adetSonucu;
    }

    // 6. Sepete Ekleme / Onaylama ("sepete ekle", "onayla", "ekle", "tamam", "aldım", "sepete at")
    if (_iciriyorMu(kucukMetin, [
      'sepete ekle',
      'sepete at',
      'sepete koy',
      'onayla',
      'ekle',
      'tamam',
      'aldım',
      'aldim',
      'kabul et',
      'satın al',
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
    // Örnek kalıplar: "bana süt bul", "zeytin nerede", "peynir ara", "çay getir"
    final kalip = RegExp(
      r'(?:bana\s+)?([a-zA-ZçğıöşüÇĞİÖŞÜ0-9\s]+?)\s+(?:bul|ara|nerede|arıyorum|ariyorum|göster|goster)$',
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
    return null;
  }

  /// Metinden adet bilgisini ayıklar ("2 adet", "üç tane")
  SesliKomutSonucu? _adetCoz(String kucukMetin, String hamMetin) {
    // 1. Rakam ile adet: "2 adet", "3 tane", "5 adet ekle"
    final rakamReg = RegExp(r'(\d+)\s*(?:adet|tane|paket|tanesini)?');
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

    // 2. Yazı ile sayı: "iki adet", "üç tane", "bir adet"
    for (final entry in _turkceSayilar.entries) {
      if (kucukMetin.contains('${entry.key} adet') ||
          kucukMetin.contains('${entry.key} tane') ||
          kucukMetin.contains('${entry.key} paket') ||
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
