import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/fiyat_onay_yoneticisi.dart';
import 'standart_fiyat_onay_view.dart';
import 'kolay_mod_fiyat_onay_view.dart';
import 'renk_koru_fiyat_onay_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Fiyat Onay tasarımını ekrana getiren dinamik bağlayıcı
class FiyatOnayEkrani extends StatelessWidget {
  final String? resimYolu;
  final ValueChanged<Map<String, dynamic>> onOnaylandi;
  final VoidCallback onTekrarCek;

  const FiyatOnayEkrani({
    super.key,
    this.resimYolu,
    required this.onOnaylandi,
    required this.onTekrarCek,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FiyatOnayYoneticisi(resimYolu: resimYolu),
      child: Consumer<ProfilYoneticisi>(
        builder: (context, profilYoneticisi, _) {
          final profil = profilYoneticisi.profil;

          switch (profil.profilTuru) {
            case ProfilTuru.kolayMod:
            case ProfilTuru.gormeEngelliModu:
              return KolayModFiyatOnayView(
                resimYolu: resimYolu,
                onOnaylandi: onOnaylandi,
                onTekrarCek: onTekrarCek,
              );
            case ProfilTuru.renkKoruModu:
              return RenkKoruFiyatOnayView(
                resimYolu: resimYolu,
                onOnaylandi: onOnaylandi,
                onTekrarCek: onTekrarCek,
              );
            case ProfilTuru.standart:
              return StandartFiyatOnayView(
                resimYolu: resimYolu,
                onOnaylandi: onOnaylandi,
                onTekrarCek: onTekrarCek,
              );
          }
        },
      ),
    );
  }
}
