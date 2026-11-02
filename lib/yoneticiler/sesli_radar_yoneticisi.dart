import 'package:flutter/material.dart';
import '../modeller/fiyat_tanima_sonucu.dart';
import '../modeller/profil_modeli.dart';
import '../modeller/urun_modeli.dart';
import '../servisler/sesli_asistan_servisi.dart';
import '../servisler/sesli_komut_servisi.dart';
import 'sepet_yoneticisi.dart';

/// Görme engelli ve sesli radar modunun anlık durumu
enum RadarDurumu {
  bosta,
  dinliyor,
  taraniyor,
  hedefAraniyor,
  urunBulundu,
  onaylandi,
}

/// Görme Engelli Radar ve Sesli Alışveriş Asistanı ViewModel'i
class SesliRadarYoneticisi extends ChangeNotifier {
  final SesliAsistanServisi _asistan = SesliAsistanServisi();
  final SesliKomutServisi _komutServisi = SesliKomutServisi();

  RadarDurumu _durum = RadarDurumu.bosta;
  String? _hedefUrun;
  UrunModeli? _sonBulunanUrun;
  String _asistanMesaji = 'Kamerayı ürün etiketine yönlendirin veya konuşmak için basılı tutun.';
  int _seciliAdet = 1;

  RadarDurumu get durum => _durum;
  String? get hedefUrun => _hedefUrun;
  UrunModeli? get sonBulunanUrun => _sonBulunanUrun;
  String get asistanMesaji => _asistanMesaji;
  int get seciliAdet => _seciliAdet;

  /// Açılış karşılama mesajı
  Future<void> baslat(bool sesliAsistanAcik) async {
    _durum = RadarDurumu.taraniyor;
    _asistanMesaji = 'FiyatGöz Sesli Radar aktif. Kamerayı etiketlere doğru gezdirin.';
    notifyListeners();

    if (sesliAsistanAcik) {
      await _asistan.konus(_asistanMesaji);
    }
  }

  /// Mikrofonu açarak kullanıcının sesli komutunu dinler
  Future<void> dinlemeyiBaslat({
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    _durum = RadarDurumu.dinliyor;
    _asistanMesaji = 'Sizi dinliyorum... ("Sepete ekle", "2 adet", "Bütçem ne kadar", "Süt bul")';
    notifyListeners();

    await _asistan.dinle(
      onSonuc: (metin, sonMu) async {
        if (sonMu && metin.isNotEmpty) {
          await _komutuYonet(metin, sepet: sepet, profil: profil);
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
    final sonuc = _komutServisi.niyetCoz(konusmaMetni);
    debugPrint('Algılanan sesli komut: $sonuc');

    switch (sonuc.tur) {
      case KomutTuru.sepeteEkle:
        if (_sonBulunanUrun != null) {
          await ekranaCiftDokunuldu(sepet: sepet, profil: profil);
        } else {
          _asistanMesaji = 'Henüz algılanmış bir ürün yok. Lütfen önce etiketi taratın.';
          notifyListeners();
          if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        }
        break;

      case KomutTuru.adetBelirle:
        if (sonuc.adet != null && sonuc.adet! > 0) {
          _seciliAdet = sonuc.adet!;
          _asistanMesaji = 'Adet $_seciliAdet olarak güncellendi.';
          notifyListeners();
          _asistan.titret(TitresimTuru.secim);
          if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        }
        break;

      case KomutTuru.iptal:
        _sonBulunanUrun = null;
        _hedefUrun = null;
        _durum = RadarDurumu.taraniyor;
        _asistanMesaji = 'İptal edildi. Tarama devam ediyor.';
        notifyListeners();
        _asistan.titret(TitresimTuru.hafif);
        if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        break;

      case KomutTuru.butceSorgula:
        final harcanan = sepet.toplamTutar;
        final kalan = profil.aylikButce - harcanan;
        if (kalan >= 0) {
          _asistanMesaji =
              'Şu ana kadar ${harcanan.toStringAsFixed(2)} lira harcadınız. Kalan bütçeniz ${kalan.toStringAsFixed(2)} lira.';
        } else {
          _asistanMesaji =
              'Bütçenizi ${(-kalan).toStringAsFixed(2)} lira aştınız! Toplam sepet tutarınız ${harcanan.toStringAsFixed(2)} lira.';
        }
        notifyListeners();
        if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        break;

      case KomutTuru.sepetOzeti:
        final adet = sepet.toplamUrunAdedi;
        final cesit = sepet.urunCesitSayisi;
        final toplam = sepet.toplamTutar;
        _asistanMesaji =
            'Sepetinizde $cesit farklı ürün, toplam $adet adet var. Genel toplam ${toplam.toStringAsFixed(2)} lira.';
        notifyListeners();
        if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        break;

      case KomutTuru.urunAra:
        if (sonuc.hedefUrun != null) {
          _hedefUrun = sonuc.hedefUrun;
          _durum = RadarDurumu.hedefAraniyor;
          _asistanMesaji =
              '${_hedefUrun!} aranıyor. Kamerayı raflardaki etiketlere doğru gezdirin.';
          notifyListeners();
          _asistan.titret(TitresimTuru.secim);
          if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        }
        break;

      case KomutTuru.belirsiz:
        _asistanMesaji = 'Tam anlayamadım. "Sepete ekle", "Kaç param kaldı" veya "Süt bul" diyebilirsiniz.';
        notifyListeners();
        if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
        break;
    }
  }

  /// Kameradan gelen OCR sonucunu işler ve radar tepkisi verir
  Future<void> etiketAlgilandi(
    FiyatTanimaSonucu sonuc, {
    required ProfilModeli profil,
  }) async {
    if (!sonuc.basarili || sonuc.tespitEdilenFiyat == null) return;

    final urunAdi = sonuc.tespitEdilenUrunAdi ?? 'Market Ürünü';
    final fiyat = sonuc.tespitEdilenFiyat!;

    // Hedef arama modundaysak kontrol et
    if (_durum == RadarDurumu.hedefAraniyor && _hedefUrun != null) {
      final eslesiyor = urunAdi.toLowerCase().contains(_hedefUrun!.toLowerCase());
      if (!eslesiyor) {
        // Hedef ürün değil, hafif tık verip geç
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
    _asistanMesaji = '$urunAdi, ${fiyat.toStringAsFixed(2)} lira. Sepete eklemek için ekrana çift dokunun.';
    notifyListeners();

    _asistan.titret(TitresimTuru.radarKilitlendi);
    if (profil.sesliAsistanAcik) {
      await _asistan.konus(_asistanMesaji);
    }
  }

  /// Görme engelli kullanıcının ekrana ÇİFT DOKUNMA jesti
  Future<void> ekranaCiftDokunuldu({
    required SepetYoneticisi sepet,
    required ProfilModeli profil,
  }) async {
    if (_sonBulunanUrun == null) {
      _asistanMesaji = 'Sepete eklenecek ürün bulunamadı. Lütfen önce etiketi taratın.';
      notifyListeners();
      _asistan.titret(TitresimTuru.hata);
      if (profil.sesliAsistanAcik) await _asistan.konus(_asistanMesaji);
      return;
    }

    sepet.urunEkle(_sonBulunanUrun!.kopyala(adet: _seciliAdet));
    _asistan.titret(TitresimTuru.basari);

    final eklenen = _sonBulunanUrun!;
    _asistanMesaji =
        '${eklenen.ad} sepete eklendi. Toplam sepet tutarı ${sepet.toplamTutar.toStringAsFixed(2)} lira.';
    
    _sonBulunanUrun = null;
    _seciliAdet = 1;
    _durum = RadarDurumu.taraniyor;
    notifyListeners();

    if (profil.sesliAsistanAcik) {
      await _asistan.konus(_asistanMesaji);
    }
  }

  /// Sağa kaydırma veya vazgeçme jesti
  Future<void> ekranKaydirildi(ProfilModeli profil) async {
    _sonBulunanUrun = null;
    _seciliAdet = 1;
    _durum = RadarDurumu.taraniyor;
    _asistanMesaji = 'Yeni ürün için tarama yapılıyor.';
    notifyListeners();
    _asistan.titret(TitresimTuru.hafif);

    if (profil.sesliAsistanAcik) {
      await _asistan.konus(_asistanMesaji);
    }
  }

  @override
  void dispose() {
    _asistan.durdur();
    super.dispose();
  }
}
