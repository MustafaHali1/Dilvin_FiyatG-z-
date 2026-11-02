import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sabitler/uygulama_renkleri.dart';
import '../sabitler/olculer.dart';
import '../sabitler/metin_stilleri.dart';
import '../yoneticiler/profil_yoneticisi.dart';
import '../modeller/profil_modeli.dart';

enum ButonTipi { dolu, cizgili, acik, tehlike }

/// Modlara ve temaya duyarlı akıllı atomik buton class'ı
class OzelButon extends StatelessWidget {
  final String metin;
  final VoidCallback? onPressed;
  final IconData? ikon;
  final ButonTipi tip;
  final bool? kolayMod;
  final bool yukleniyor;
  final Color? renk;

  const OzelButon({
    super.key,
    required this.metin,
    this.onPressed,
    this.ikon,
    this.tip = ButonTipi.dolu,
    this.kolayMod,
    this.yukleniyor = false,
    this.renk,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final bool isKolayMod = kolayMod ?? (profil.profilTuru == ProfilTuru.kolayMod);
    final bool isRenkKoru = profil.profilTuru == ProfilTuru.renkKoruModu;
    final renkPaleti = isRenkKoru ? RenkKorluguPaleti.getir(profil.renkKorluguTuru) : null;

    final double yukseklik = isKolayMod
        ? Olculer.kolayModButonYukseklik
        : Olculer.standartButonYukseklik;

    Color anaRenk = renk ?? (isRenkKoru ? renkPaleti!.primary : UygulamaRenkleri.anaZumrut);
    Color acikRenk = isRenkKoru ? anaRenk.withValues(alpha: 0.15) : UygulamaRenkleri.anaAcik;
    Color koyuRenk = isRenkKoru ? anaRenk : UygulamaRenkleri.anaKoyu;

    Color arkaPlan;
    Color yaziRengi;
    BorderSide cerceve = BorderSide.none;

    if (isKolayMod) {
      arkaPlan = UygulamaRenkleri.kolayModSari;
      yaziRengi = UygulamaRenkleri.kolayModSiyah;
      cerceve = const BorderSide(color: Colors.white, width: 2);
    } else {
      switch (tip) {
        case ButonTipi.dolu:
          arkaPlan = anaRenk;
          yaziRengi = Colors.white;
          break;
        case ButonTipi.cizgili:
          arkaPlan = Colors.transparent;
          yaziRengi = anaRenk;
          cerceve = BorderSide(color: anaRenk, width: 2);
          break;
        case ButonTipi.acik:
          arkaPlan = acikRenk;
          yaziRengi = koyuRenk;
          break;
        case ButonTipi.tehlike:
          arkaPlan = isRenkKoru ? UygulamaRenkleri.renkKoruTuruncu : UygulamaRenkleri.tehlikeKirmizi;
          yaziRengi = Colors.white;
          break;
      }
    }

    return SizedBox(
      height: yukseklik,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: arkaPlan,
          foregroundColor: yaziRengi,
          elevation: isKolayMod ? 0 : 2,
          side: cerceve,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isKolayMod ? Olculer.yariCapBuyuk : Olculer.yariCapOrta,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Olculer.boslukOrta),
        ),
        onPressed: yukleniyor ? null : onPressed,
        child: yukleniyor
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(yaziRengi),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ikon != null) ...[
                    Icon(
                      ikon,
                      size: isKolayMod ? 28 : 22,
                      color: yaziRengi,
                    ),
                    const SizedBox(width: Olculer.boslukKucuk),
                  ],
                  Text(
                    metin,
                    style: isKolayMod
                        ? MetinStilleri.kolayModGovde(renk: yaziRengi)
                        : MetinStilleri.govdeKalin(renk: yaziRengi),
                  ),
                ],
              ),
      ),
    );
  }
}
