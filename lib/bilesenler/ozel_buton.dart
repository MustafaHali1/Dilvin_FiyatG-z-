import 'package:flutter/material.dart';
import '../sabitler/uygulama_renkleri.dart';
import '../sabitler/olculer.dart';
import '../sabitler/metin_stilleri.dart';

enum ButonTipi { dolu, cizgili, acik, tehlike }

/// Tum uygulamada kullanilan tek ve moduler buton class'i
class OzelButon extends StatelessWidget {
  final String metin;
  final VoidCallback? onPressed;
  final IconData? ikon;
  final ButonTipi tip;
  final bool kolayMod;
  final bool yukleniyor;

  const OzelButon({
    super.key,
    required this.metin,
    this.onPressed,
    this.ikon,
    this.tip = ButonTipi.dolu,
    this.kolayMod = false,
    this.yukleniyor = false,
  });

  @override
  Widget build(BuildContext context) {
    final double yukseklik = kolayMod
        ? Olculer.kolayModButonYukseklik
        : Olculer.standartButonYukseklik;

    Color arkaPlan;
    Color yaziRengi;
    BorderSide cerceve = BorderSide.none;

    if (kolayMod) {
      arkaPlan = UygulamaRenkleri.kolayModSari;
      yaziRengi = UygulamaRenkleri.kolayModSiyah;
    } else {
      switch (tip) {
        case ButonTipi.dolu:
          arkaPlan = UygulamaRenkleri.anaZumrut;
          yaziRengi = Colors.white;
          break;
        case ButonTipi.cizgili:
          arkaPlan = Colors.transparent;
          yaziRengi = UygulamaRenkleri.anaZumrut;
          cerceve = const BorderSide(color: UygulamaRenkleri.anaZumrut, width: 1.5);
          break;
        case ButonTipi.acik:
          arkaPlan = UygulamaRenkleri.anaAcik;
          yaziRengi = UygulamaRenkleri.anaKoyu;
          break;
        case ButonTipi.tehlike:
          arkaPlan = UygulamaRenkleri.tehlikeKirmizi;
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
          elevation: tip == ButonTipi.dolu && !kolayMod ? 2 : 0,
          side: cerceve,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              kolayMod ? Olculer.yariCapBuyuk : Olculer.yariCapOrta,
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
                      size: kolayMod ? 28 : 20,
                      color: yaziRengi,
                    ),
                    const SizedBox(width: Olculer.boslukKucuk),
                  ],
                  Text(
                    metin,
                    style: kolayMod
                        ? MetinStilleri.kolayModGovde(renk: yaziRengi)
                        : MetinStilleri.govdeKalin(renk: yaziRengi),
                  ),
                ],
              ),
      ),
    );
  }
}
