import 'package:flutter/material.dart';
import '../modeller/profil_modeli.dart';

/// Kullanıcı profilini ve mod geçişlerini yöneten merkezi ViewModel
class ProfilYoneticisi extends ChangeNotifier {
  ProfilModeli _profil = const ProfilModeli();

  ProfilModeli get profil => _profil;
  ProfilTuru get aktifMod => _profil.profilTuru;
  bool get kolayMod => _profil.profilTuru == ProfilTuru.kolayMod;
  bool get renkKoruModu => _profil.profilTuru == ProfilTuru.renkKoruModu;
  bool get gormeEngelliModu => _profil.profilTuru == ProfilTuru.gormeEngelliModu;

  void profilAyarla(ProfilTuru yeniTur) {
    _profil = _profil.kopyala(profilTuru: yeniTur);
    notifyListeners();
  }

  void renkKorluguTuruAyarla(RenkKorluguTuru tur) {
    _profil = _profil.kopyala(renkKorluguTuru: tur);
    notifyListeners();
  }

  void yaziBoyutuAyarla(double yeniBoyut) {
    _profil = _profil.kopyala(yaziBoyutu: yeniBoyut);
    notifyListeners();
  }

  void kontrastAyarla(String kontrast) {
    _profil = _profil.kopyala(kontrastTuru: kontrast);
    notifyListeners();
  }

  void butceAyarla(double yeniButce) {
    _profil = _profil.kopyala(aylikButce: yeniButce);
    notifyListeners();
  }

  void sesliAsistanDegistir(bool acik) {
    _profil = _profil.kopyala(sesliAsistanAcik: acik);
    notifyListeners();
  }

  void titresimDegistir(bool acik) {
    _profil = _profil.kopyala(titresimAcik: acik);
    notifyListeners();
  }
}
