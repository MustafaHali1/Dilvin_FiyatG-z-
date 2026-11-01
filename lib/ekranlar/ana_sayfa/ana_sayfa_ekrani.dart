import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'standart_ana_sayfa_view.dart';
import 'kolay_mod_ana_sayfa_view.dart';
import 'renk_koru_ana_sayfa_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch tasarımını ekrana getiren dinamik bağlayıcı
class AnaSayfaEkrani extends StatelessWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const AnaSayfaEkrani({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
        return KolayModAnaSayfaView(
          onKameraAc: onKameraAc,
          onSepeteGit: onSepeteGit,
          onSesliAsistanAc: onSesliAsistanAc,
          onAyarlaraGit: onAyarlaraGit,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruAnaSayfaView(
          onKameraAc: onKameraAc,
          onSepeteGit: onSepeteGit,
          onSesliAsistanAc: onSesliAsistanAc,
          onAyarlaraGit: onAyarlaraGit,
        );
      case ProfilTuru.gormeEngelliModu:
      case ProfilTuru.standart:
        return StandartAnaSayfaView(
          onKameraAc: onKameraAc,
          onSepeteGit: onSepeteGit,
          onSesliAsistanAc: onSesliAsistanAc,
          onAyarlaraGit: onAyarlaraGit,
        );
    }
  }
}
