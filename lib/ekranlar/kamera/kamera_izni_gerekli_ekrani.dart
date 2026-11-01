import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';

/// Kamera izni reddedildiğinde gösterilen durum ekranı
class KameraIzniGerekliEkrani extends StatelessWidget {
  final VoidCallback onAyarlaraGit;
  final VoidCallback onGaleridenSec;
  final VoidCallback onElleGir;

  const KameraIzniGerekliEkrani({
    super.key,
    required this.onAyarlaraGit,
    required this.onGaleridenSec,
    required this.onElleGir,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_photography_rounded,
                  size: 48,
                  color: UygulamaRenkleri.tehlikeKirmizi,
                ),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              Text(
                'Kamera İznine İhtiyacımız Var',
                style: MetinStilleri.baslik1(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Olculer.boslukOrta),
              Text(
                'Fiyat etiketlerini ve reyon barkodlarını tarayabilmek için kameraya erişim izni vermen gerekiyor.',
                style: MetinStilleri.aciklama(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Olculer.boslukCokBuyuk),
              OzelButon(
                metin: 'Uygulama Ayarlarına Git',
                ikon: Icons.settings_rounded,
                onPressed: onAyarlaraGit,
              ),
              const SizedBox(height: Olculer.boslukOrta),
              OzelButon(
                metin: 'Fotoğrafı Galeriden Seç',
                tip: ButonTipi.cizgili,
                ikon: Icons.photo_library_outlined,
                onPressed: onGaleridenSec,
              ),
              const SizedBox(height: Olculer.boslukKucuk),
              TextButton(
                onPressed: onElleGir,
                child: Text('Fiyatı Elle Girmek İstiyorum', style: MetinStilleri.govdeKalin()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
