import 'package:flutter/foundation.dart';
import '../sabitler/sesli_komut_lugati.dart';
import 'gemini_asistan_servisi.dart';

/// Sesli asistan tarafından çözülen niyet (Intent) türleri
enum KomutTuru {
  selamlama,
  tesekkurVeda,
  yardim,
  sepetiSifirla,
  iptal,
  sepeteEkle,
  butceSorgula,
  sepetOzeti,
  urunAra,
  adetBelirle,
  belirsiz,
}

/// Çözümlenen sesli komutun detaylı verisi
class SesliKomutSonucu {
  final KomutTuru tur;
  final int? adet;
  final String? hedefUrun;
  final String hamMetin;
  final String? asistanCevabi;

  const SesliKomutSonucu({
    required this.tur,
    this.adet,
    this.hedefUrun,
    required this.hamMetin,
    this.asistanCevabi,
  });

  @override
  String toString() =>
      'SesliKomutSonucu(tur: $tur, adet: $adet, hedefUrun: $hedefUrun, hamMetin: "$hamMetin", asistanCevabi: "$asistanCevabi")';
}

/// Kullanıcının Türkçe serbest konuşma cümlelerini kurallı komutlara ve niyetlere (NLU) dönüştüren zeki motor
class SesliKomutServisi {
  /// Gelen serbest Türkçe konuşma metnini analiz eder ve asıl niyeti (Intent) çözer
  SesliKomutSonucu niyetCoz(String hamMetin) {
    // 1. Temizlik ve normalizasyon
    final metin = _turkceKucult(hamMetin)
        .replaceAll(RegExp(r'[.,!?\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (metin.isEmpty) {
      return SesliKomutSonucu(
        tur: KomutTuru.belirsiz,
        hamMetin: hamMetin,
      );
    }

    // 2. Öncelik Sırasına Göre Niyet Kontrolü

    // A) Tehlikeli / Sıfırlama İşlemleri ("Sepeti boşalt", "Sıfırla")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.sepetSifirlamaKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.sepetiSifirla,
        hamMetin: hamMetin,
      );
    }

    // B) İptal / Vazgeçme ("Ekleme iptal et" durumunda eklemeyi tetiklememek için iptal önce gelir)
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.iptalKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.iptal,
        hamMetin: hamMetin,
      );
    }

    // C) Bütçe ve Harcama Sorguları ("Bütçem ne kadar", "Patladık mı")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.butceSorgulari)) {
      return SesliKomutSonucu(
        tur: KomutTuru.butceSorgula,
        hamMetin: hamMetin,
      );
    }

    // D) Sepet Özeti ve Hesap Sorguları ("Sepette ne var", "Kaça patladı")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.sepetOzetiSorgulari)) {
      return SesliKomutSonucu(
        tur: KomutTuru.sepetOzeti,
        hamMetin: hamMetin,
      );
    }

    // E) Yardım ve Kapasite Sorguları ("Yardım et", "Sen kimsin", "Komutlar")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.yardimKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.yardim,
        hamMetin: hamMetin,
      );
    }

    // F) Teşekkür ve Veda ("Sağ ol", "Eyvallah", "Görüşürüz")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.tesekkurVedaKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.tesekkurVeda,
        hamMetin: hamMetin,
      );
    }

    // G) Selamlaşma ve Hal-Hatır ("Merhaba", "Naber", "Günaydın", "sa")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.selamlamaKelimeleri)) {
      return SesliKomutSonucu(
        tur: KomutTuru.selamlama,
        hamMetin: hamMetin,
      );
    }

    // H) Hedef Ürün Arama (Radar için: "Bana süt bul", "Zeytin nerede", "Peynir ara")
    final aramaKomutu = _urunAramaNiyetiCoz(metin, hamMetin);
    if (aramaKomutu != null) {
      return aramaKomutu;
    }

    // I) Adet Belirleme ("2 adet", "3 tane", "dört adet ekle", "çift al")
    final adetSonucu = _adetCoz(metin, hamMetin);
    if (adetSonucu != null) {
      return adetSonucu;
    }

    // J) Sepete Ekleme / Onaylama ("Sepete fırlat", "Yapıştır", "Aldım", "Koy sepete")
    if (_kumeIcindeGeciyorMu(metin, AsistanVeriSeti.sepeteEkleKelimeleri)) {
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

  /// Asenkron Hibrit Niyet Çözümleyici:
  /// 1. İnternet ve Gemini API anahtarı varsa: Her şeyi Gemini çözer, şiveleri anlar, samimi Türkçe yanıt üretir ve yerel SQLite'ı eğitir.
  /// 2. İnternet yoksa veya istek başarısız olursa: Eski kural tabanlı motor + daha önce Gemini'den öğrenilen SQLite hafızası devreye girer (0 ms, %100 internetsiz).
  Future<SesliKomutSonucu> niyetCozAkilli(
    String hamMetin, {
    double? kalanButce,
    double? sepetTutar,
    int? sepetAdet,
  }) async {
    // 1. İNTERNET VE GEMINI AKTİFSE: Önce Gemini Çözer ve Yerel Hafızayı Eğitir
    if (GeminiAsistanServisi.apiKeyVarMi) {
      try {
        final gemini = GeminiAsistanServisi();
        final geminiSonuc = await gemini.niyetCoz(
          metin: hamMetin,
          kalanButce: kalanButce,
          sepetTutar: sepetTutar,
          sepetAdet: sepetAdet,
        );

        if (geminiSonuc != null) {
          KomutTuru eslesenTur = KomutTuru.belirsiz;
          switch (geminiSonuc.komut) {
            case 'BUTCE_SORGULA':
              eslesenTur = KomutTuru.butceSorgula;
              break;
            case 'SEPETE_EKLE':
              eslesenTur = KomutTuru.sepeteEkle;
              break;
            case 'SEPET_DOKUMU':
              eslesenTur = KomutTuru.sepetOzeti;
              break;
            case 'URUN_ARA':
              eslesenTur = KomutTuru.urunAra;
              break;
            case 'IPTAL':
              eslesenTur = KomutTuru.iptal;
              break;
            default:
              eslesenTur = KomutTuru.belirsiz;
          }

          if (eslesenTur != KomutTuru.belirsiz) {
            return SesliKomutSonucu(
              tur: eslesenTur,
              hedefUrun: geminiSonuc.hedefUrun,
              adet: geminiSonuc.adet,
              hamMetin: hamMetin,
              asistanCevabi: geminiSonuc.cevap.isNotEmpty ? geminiSonuc.cevap : null,
            );
          } else if (geminiSonuc.cevap.isNotEmpty) {
            return SesliKomutSonucu(
              tur: KomutTuru.belirsiz,
              hamMetin: hamMetin,
              asistanCevabi: geminiSonuc.cevap,
            );
          }
        }
      } catch (e) {
        debugPrint('Gemini bağlantı hatası, yerel kurallara dönülüyor: $e');
      }
    }

    // 2. İNTERNETSİZ DURUMDA (VEYA GEMINI OLMADIĞINDA):
    // Eski kural tabanlı yerel motor (0ms gecikme, sıfır internet bağımlılığı)
    return niyetCoz(hamMetin);
  }

  /// Metinden ürün arama niyetini ayıklar
  SesliKomutSonucu? _urunAramaNiyetiCoz(String kucukMetin, String hamMetin) {
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

  /// Metinden adet bilgisini ayıklar
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

    // 2. Yazı ile sayı: "iki adet", "üç tane", "bir adet", "çift al", "düzine"
    for (final entry in AsistanVeriSeti.sayiKarsiliklari.entries) {
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

  static bool _kumeIcindeGeciyorMu(String metin, Set<String> kume) {
    final sozcukler = metin.split(' ');
    for (final kalip in kume) {
      if (kalip.contains(' ')) {
        // Çok sözcüklü kalıp ise ("sepete ekle", "sağ ol", "bütçem ne kadar") doğrudan substring kontrolü
        if (metin.contains(kalip)) return true;
      } else {
        // Tek sözcük ise ("sa", "as", "al", "iptal") başka sözcüklerin içine yapışmamalı, bağımsız olmalı
        if (sozcukler.contains(kalip)) return true;
      }
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

/// Geriye dönük uyumluluk için alias
typedef AsistanMotoru = SesliKomutServisi;
