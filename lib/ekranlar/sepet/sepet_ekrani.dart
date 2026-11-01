import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'standart_sepet_view.dart';
import 'kolay_mod_sepet_view.dart';
import 'renk_koru_sepet_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Sepet tasarımını getiren dinamik ekran
class SepetEkrani extends StatelessWidget {
  final VoidCallback onUrunEkle;
  final VoidCallback onAlisverisiBitir;

  const SepetEkrani({
    super.key,
    required this.onUrunEkle,
    required this.onAlisverisiBitir,
  });

  @override
  Widget build(BuildContext context) {
    final sepet = context.watch<SepetYoneticisi>();
    final profil = context.watch<ProfilYoneticisi>().profil;

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
        return KolayModSepetView(
          sepet: sepet,
          onUrunEkle: onUrunEkle,
          onAlisverisiBitir: onAlisverisiBitir,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruSepetView(
          sepet: sepet,
          onUrunEkle: onUrunEkle,
          onAlisverisiBitir: onAlisverisiBitir,
        );
      case ProfilTuru.gormeEngelliModu:
      case ProfilTuru.standart:
        return StandartSepetView(
          sepet: sepet,
          onUrunEkle: onUrunEkle,
          onAlisverisiBitir: onAlisverisiBitir,
        );
    }
  }
}
