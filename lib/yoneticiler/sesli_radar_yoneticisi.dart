import 'dart:async';
import 'package:flutter/material.dart';
import '../modeller/fiyat_tanima_sonucu.dart';
import '../modeller/profil_modeli.dart';
import '../modeller/urun_modeli.dart';
import '../servisler/sesli_asistan_servisi.dart';
import '../servisler/sesli_komut_servisi.dart';
import 'sepet_yoneticisi.dart';

/// Görme engelli sesli asistan modunun anlık durumu
enum RadarDurumu {
  bosta,
  dinliyor,
  taraniyor,
  hedefAraniyor,
  urunBulundu,
  onaylandi,
}

/// %100 Konuşma ve Ses Odaklı Görme Engelli Asistanı ViewModel'i
class SesliRadarYoneticisi extends ChangeNotifier {
  final SesliAsistanServisi _asistan = SesliAsistanServisi();
  final SesliKomutServisi _komutServisi = SesliKomutServisi();

  RadarDurumu _durum = RadarDurumu.bosta;
  String? _hedefUrun;
  UrunModeli? _sonBulunanUrun;
  String _asistanMesaji = 'Sesli asistan devrede. Kamerayı etiketlere doğru tutun.';
  String _kullaniciMetni = '';
  int _seciliAdet = 1;
  bool _konusuyor = false;
  bool _aktifMi = false;

  RadarDurumu get durum => _durum;
  String? get hedefUrun => _hedefUrun;
  UrunModeli? get sonBulunanUrun => _sonBulunanUrun;
  String get asistanMesaji => _asistanMesaji;
  String get kullaniciMetni => _kullaniciMetni;
  int get seciliAdet => _seciliAdet;
  bool get konusuyor => _konusuyor;

  /// Radarı ve sesli asistanı güvenli şekilde durdurur
  Future<void> durdur() async {
    _aktifMi = false;
    _konusuyor = false;
    _durum = RadarDurumu.bosta;
    _asistan.durumDinleyicisiAyarla(null);
    await _asistan.durdur();
  }

  /// Açılış karşılama mesajı
  Future<void> baslat({
    required bool sesliAsistanAcik,
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    _aktifMi = true;
    _durum = RadarDurumu.taraniyor;
    _asistanMesaji = 'Sesli radar devrede. Kamerayı etiketlere doğru tutun, sizi dinliyorum.';
    notifyListeners();

    // Dinleyiciyi kaydet: Sessizlikten mikrofon kapanırsa uyanık kalması için arka planda tazeleyelim
    _asistan.durumDinleyicisiAyarla((durum) {
      if (!_aktifMi || _konusuyor) return;
      if (durum == 'notListening' || durum == 'done') {
        // Eğer kullanıcı bir şey söylediyse ve finalResult tetiklenmeden kapanmışsa işle
        if (_kullaniciMetni.trim().isNotEmpty) {
          final islenecek = _kullaniciMetni;
          _kullaniciMetni = '';
          _komutuYonet(islenecek, sepet: sepet, profil: profil);
        } else {
          // Sessizlikten kapandıysa kullanıcı bağırmak zorunda kalmasın diye dinlemeyi hemen tazele
          Timer(const Duration(milliseconds: 350), () {
            if (_aktifMi && !_konusuyor && !_asistan.dinliyorMu) {
              dinlemeyiBaslat(sepet: sepet, profil: profil);
            }
          });
        }
      }
    });

    if (sesliAsistanAcik) {
      _konusuyor = true;
      notifyListeners();
      await _asistan.konus(_asistanMesaji);
      _konusuyor = false;
      if (!_aktifMi) return;
      notifyListeners();

      // Konuşma bitince dinlemeyi başlat
      dinlemeyiBaslat(sepet: sepet, profil: profil);
    }
  }

  /// Mikrofonu açarak kullanıcının sesli komutunu dinler
  Future<void> dinlemeyiBaslat({
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    if (_konusuyor || !_aktifMi) return;
    _durum = RadarDurumu.dinliyor;
    notifyListeners();

    await _asistan.dinle(
      dinlemeSuresi: const Duration(seconds: 30),
      sessizlikSuresi: const Duration(seconds: 4),
      onSonuc: (metin, sonMu) async {
        if (!_aktifMi || _konusuyor) return;
        _kullaniciMetni = metin;
        notifyListeners();

        if (sonMu && metin.trim().isNotEmpty) {
          final islenecek = metin;
          _kullaniciMetni = '';
          await _komutuYonet(islenecek, sepet: sepet, profil: profil);
        }
      },
    );
  }

  /// Sesli komut sonucunu iş mantığına yönlendirir
  Future<void> _komutuYonet(
    String konusmaMetni, {
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    final sonuc = await _komutServisi.niyetCozAkilli(
      konusmaMetni,
      kalanButce: profil.aylikButce - sepet.toplamTutar,
      sepetTutar: sepet.toplamTutar,
      sepetAdet: sepet.toplamUrunAdedi,
    );
    debugPrint('Görme Engelli Komut Çözüldü: $sonuc');

    // Eğer bir ürün yeni bulunmuşsa ve kullanıcı onay veya ret veriyorsa:
    if (_durum == RadarDurumu.urunBulundu && _sonBulunanUrun != null) {
      // 1. Sepete Ekleme Onayı
      if (sonuc.tur == KomutTuru.sepeteEkle ||
          konusmaMetni.toLowerCase().contains('evet') ||
          konusmaMetni.toLowerCase().contains('ekle') ||
          konusmaMetni.toLowerCase().contains('al') ||
          konusmaMetni.toLowerCase().contains('koy')) {
        
        final adet = sonuc.adet ?? _seciliAdet;
        final eklenen = _sonBulunanUrun!.kopyala(adet: adet);
        sepet.urunEkle(eklenen);

        _asistan.titret(TitresimTuru.basari);
        _asistanMesaji = '$adet adet ${eklenen.ad} sepete eklendi. Güncel sepet toplamı ${sepet.toplamTutar.toStringAsFixed(2)} lira.';
        _sonBulunanUrun = null;
        _seciliAdet = 1;
        _durum = RadarDurumu.taraniyor;
        notifyListeners();

        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        return;
      }

      // 2. İptal / Vazgeçme
      if (sonuc.tur == KomutTuru.iptal ||
          konusmaMetni.toLowerCase().contains('hayır') ||
          konusmaMetni.toLowerCase().contains('kalsın') ||
          konusmaMetni.toLowerCase().contains('alma') ||
          konusmaMetni.toLowerCase().contains('boşver')) {
        
        _asistan.titret(TitresimTuru.hafif);
        _asistanMesaji = 'Tamam, eklemedim. Taramaya devam ediyorum.';
        _sonBulunanUrun = null;
        _seciliAdet = 1;
        _durum = RadarDurumu.taraniyor;
        notifyListeners();

        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        return;
      }
    }

    // Genel Komutlar
    switch (sonuc.tur) {
      case KomutTuru.selamlama:
        _asistanMesaji = 'Merhabalar! Kamerayı etiketlere doğru gezdirin, ürün ve fiyatları okuyayım.';
        _asistan.titret(TitresimTuru.secim);
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.tesekkurVeda:
        _asistanMesaji = 'Rica ederim, iyi alışverişler!';
        _asistan.titret(TitresimTuru.secim);
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.yardim:
        _asistanMesaji = 'Ben alışveriş asistanınızım. Kamerayı etiketlere tuttuğunuzda fiyatı okurum ve ekleyeyim mi diye sorarım. "Sepette ne var" veya "Bütçem ne kadar" diyebilirsiniz.';
        _asistan.titret(TitresimTuru.secim);
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.sepetiSifirla:
        sepet.sepetiBosalt();
        _sonBulunanUrun = null;
        _asistanMesaji = 'Sepetiniz tamamen sıfırlandı.';
        _asistan.titret(TitresimTuru.hafif);
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.sepeteEkle:
        if (_sonBulunanUrun != null) {
          final eklenen = _sonBulunanUrun!.kopyala(adet: _seciliAdet);
          sepet.urunEkle(eklenen);
          _asistan.titret(TitresimTuru.basari);
          _asistanMesaji = '${eklenen.ad} sepete eklendi. Toplam ${sepet.toplamTutar.toStringAsFixed(2)} lira.';
          _sonBulunanUrun = null;
          await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        } else {
          _asistanMesaji = 'Henüz algılanmış bir ürün yok. Kamerayı etikete tutabilirsiniz.';
          await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        }
        break;

      case KomutTuru.adetBelirle:
        if (sonuc.adet != null && sonuc.adet! > 0) {
          _seciliAdet = sonuc.adet!;
          _asistanMesaji = 'Adet $_seciliAdet olarak güncellendi.';
          _asistan.titret(TitresimTuru.secim);
          await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        }
        break;

      case KomutTuru.iptal:
        _sonBulunanUrun = null;
        _hedefUrun = null;
        _durum = RadarDurumu.taraniyor;
        _asistanMesaji = 'İptal edildi. Tarama devam ediyor.';
        _asistan.titret(TitresimTuru.hafif);
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.butceSorgula:
        final kalanGun = profil.kalanGunSayisi;
        final donem = profil.butceDonemiFormatli;
        final harcanan = sepet.toplamTutar;
        final kalan = profil.aylikButce - harcanan;
        if (kalan >= 0) {
          _asistanMesaji = '$donem dönemi bütçeniz ${profil.aylikButce.toStringAsFixed(0)} lira. Kalan bütçeniz ${kalan.toStringAsFixed(2)} lira ve dönemin bitmesine $kalanGun gün var.';
        } else {
          _asistanMesaji = '$donem dönemi bütçenizi ${(-kalan).toStringAsFixed(2)} lira aştınız! Toplam tutarınız ${harcanan.toStringAsFixed(2)} lira.';
        }
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.sepetOzeti:
        final adet = sepet.toplamUrunAdedi;
        final cesit = sepet.urunCesitSayisi;
        final toplam = sepet.toplamTutar;
        if (adet == 0) {
          _asistanMesaji = 'Sepetiniz şu anda boş.';
        } else {
          _asistanMesaji = 'Sepetinizde $cesit farklı ürün, toplam $adet adet var. Genel toplam ${toplam.toStringAsFixed(2)} lira.';
        }
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;

      case KomutTuru.urunAra:
        if (sonuc.hedefUrun != null) {
          _hedefUrun = sonuc.hedefUrun;
          _durum = RadarDurumu.hedefAraniyor;
          _asistanMesaji = '${_hedefUrun!} aranıyor. Kamerayı raflardaki etiketlere doğru gezdirin.';
          _asistan.titret(TitresimTuru.secim);
          await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        }
        break;

      case KomutTuru.belirsiz:
        // Eğer kullanıcı son ürünü çıkarmak istiyorsa
        if (konusmaMetni.toLowerCase().contains('çıkar') || konusmaMetni.toLowerCase().contains('sil')) {
          if (sepet.urunler.isNotEmpty) {
            final silinen = sepet.urunler.last;
            sepet.urunSil(silinen.id);
            _asistanMesaji = 'Son ürün "${silinen.ad}" sepetten çıkarıldı. Güncel toplam ${sepet.toplamTutar.toStringAsFixed(2)} lira.';
          } else {
            _asistanMesaji = 'Sepetiniz zaten boş.';
          }
        } else if (sonuc.asistanCevabi != null && sonuc.asistanCevabi!.isNotEmpty) {
          _asistanMesaji = sonuc.asistanCevabi!;
        } else {
          _asistanMesaji = 'Tam anlayamadım. "Sepette ne var", "Ekle", "Kalsın" veya "Bütçem" diyebilirsiniz.';
        }
        await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
        break;
    }
  }

  /// Asistan cevabı seslendirir ve ardından dinlemeye devam eder
  Future<void> _sesliCevapVer(
    String mesaj, {
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    if (!_aktifMi) return;
    _konusuyor = true;
    notifyListeners();

    if (profil.sesliAsistanAcik) {
      await _asistan.konus(mesaj);
    }

    _konusuyor = false;
    if (!_aktifMi) return;
    notifyListeners();

    // Kullanıcıya tekrar mikrofon açılır
    dinlemeyiBaslat(sepet: sepet, profil: profil);
  }

  /// Kameradan gelen OCR sonucunu işler ve kullanıcıya sesli soru yöneltir
  Future<void> etiketAlgilandi(
    FiyatTanimaSonucu sonuc, {
    required ProfilModeli profil,
    required SepetYoneticisi sepet,
  }) async {
    // Kullanıcı konuşurken veya asistan konuşurken KESİNLİKLE araya girip lafını kesme!
    if (!sonuc.basarili ||
        sonuc.tespitEdilenFiyat == null ||
        _konusuyor ||
        _kullaniciMetni.trim().isNotEmpty ||
        _durum == RadarDurumu.urunBulundu) {
      return;
    }

    final urunAdi = sonuc.tespitEdilenUrunAdi ?? 'Market Ürünü';
    final fiyat = sonuc.tespitEdilenFiyat!;

    // Aynı ürünü arka arkaya durmadan tekrar okumasın
    if (_sonBulunanUrun != null &&
        _sonBulunanUrun!.ad == urunAdi &&
        _sonBulunanUrun!.birimFiyat == fiyat) {
      return;
    }

    // Hedef arama modundaysak kontrol et
    if (_durum == RadarDurumu.hedefAraniyor && _hedefUrun != null) {
      final eslesiyor = urunAdi.toLowerCase().contains(_hedefUrun!.toLowerCase());
      if (!eslesiyor) {
        _asistan.titret(TitresimTuru.hafif);
        return;
      }
    }

    _sonBulunanUrun = UrunModeli(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ad: urunAdi,
      birimFiyat: fiyat,
      adet: _seciliAdet,
      yapayZekaIleTanindi: true,
    );

    _durum = RadarDurumu.urunBulundu;
    _asistanMesaji = '$urunAdi, ${fiyat.toStringAsFixed(2)} lira. Sepete ekleyeyim mi?';
    notifyListeners();

    _asistan.titret(TitresimTuru.radarKilitlendi);
    await _sesliCevapVer(_asistanMesaji, sepet: sepet, profil: profil);
  }

  /// Gemini Vision tarafından çözülen görsel sahne / ürün analiz sonucunu seslendirir
  Future<void> visionSonucuDuyur(
    String aciklama, {
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    if (_konusuyor || _durum == RadarDurumu.urunBulundu) return;
    _asistanMesaji = aciklama;
    notifyListeners();
    _asistan.titret(TitresimTuru.radarKilitlendi);
    await _sesliCevapVer(aciklama, sepet: sepet, profil: profil);
  }

  @override
  void dispose() {
    _asistan.durdur();
    super.dispose();
  }
}
