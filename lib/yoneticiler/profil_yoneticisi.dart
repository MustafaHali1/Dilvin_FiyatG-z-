import 'package:flutter/material.dart';
import '../modeller/profil_modeli.dart';

/// Kullanıcı profilini ve erişilebilirlik ayarlarını yöneten ViewModel
class ProfilYoneticisi extends ChangeNotifier {
  ProfilModeli _profil = const ProfilModeli();

  ProfilModeli get profil => _profil;
  bool get kolayMod => _profil.profilTuru == ProfilTuru.kolayMod;
  bool get renkKoruModu => _profil.profilTuru == ProfilTuru.renkKoruModu;

  void profilAyarla(ProfilTuru yeniTur) {
    _profil = _profil.kopyala(profilTuru: yeniTur);
    notifyListeners();
  }

  void renkKorluguTuruAyarla(RenkKorluguTuru tur) {
    _profil = _profil.kopyala(renkKorluguTuru: tur);
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
