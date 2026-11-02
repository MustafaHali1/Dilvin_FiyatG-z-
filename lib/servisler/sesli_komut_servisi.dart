import '../sabitler/sesli_komut_lugati.dart';

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
  /// Gelen serbest Türkçe konuşma metnini analiz eder ve asıl niyeti (Intent) çözer
  SesliKomutSonucu niyetCoz(String hamMetin) {
    final kucukMetin = _turkceKucult(hamMetin).trim();
    if (kucukMetin.isEmpty) {
      return SesliKomutSonucu(
        tur: KomutTuru.belirsiz,
        hamMetin: hamMetin,
      );
    }

    // 1. İptal / Vazgeç Komutları (SesliKomutLugati.iptalKelimeleri)
    if (_iciriyorMu(kucukMetin, SesliKomutLugati.iptalKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.iptal,
        hamMetin: hamMetin,
      );
    }

    // 2. Bütçe ve Harcama Sorguları (SesliKomutLugati.butceSorgulari)
    if (_iciriyorMu(kucukMetin, SesliKomutLugati.butceSorgulari)) {
      return SesliKomutSonucu(
        tur: KomutTuru.butceSorgula,
        hamMetin: hamMetin,
      );
    }

    // 3. Sepet Özeti ve Hesap Sorguları (SesliKomutLugati.sepetOzetiSorgulari)
    if (_iciriyorMu(kucukMetin, SesliKomutLugati.sepetOzetiSorgulari)) {
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

    // 6. Sepete Ekleme / Onaylama (SesliKomutLugati.sepeteEkleKelimeleri)
    if (_iciriyorMu(kucukMetin, SesliKomutLugati.sepeteEkleKelimeleri)) {
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
    for (final entry in SesliKomutLugati.sayiKarsiliklari.entries) {
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

  bool _iciriyorMu(String metin, Iterable<String> anahtarlar) {
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
