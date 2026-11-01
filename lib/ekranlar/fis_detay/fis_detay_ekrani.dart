import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'standart_fis_view.dart';
import 'kolay_mod_fis_view.dart';
import 'renk_koru_fis_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Fiş tasarımını ekrana getiren dinamik bağlayıcı
class FisDetayEkrani extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;

  const FisDetayEkrani({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
        return KolayModFisView(
          fis: fis,
          onPaylas: onPaylas,
          onSesliOku: onSesliOku,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruFisView(
          fis: fis,
          onPaylas: onPaylas,
          onSesliOku: onSesliOku,
        );
      case ProfilTuru.gormeEngelliModu:
      case ProfilTuru.standart:
        return StandartFisView(
          fis: fis,
          onPaylas: onPaylas,
          onSesliOku: onSesliOku,
        );
    }
  }
}
