import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bilesenler/kamera_hedef_maskesi.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../sesli_asistan/sesli_asistan_diyalog_ekrani.dart';

/// Renk Körü Modu - Kamera Ekranı (Stitch: renk_k_r_kamera birebir)
class RenkKoruKameraView extends StatelessWidget {
  final CameraController? cameraController;
  final VoidCallback onFotoCek;
  final VoidCallback onKapat;

  const RenkKoruKameraView({
    super.key,
    required this.cameraController,
    required this.onFotoCek,
    required this.onKapat,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);
    final anaRenk = palet.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            CameraPreview(cameraController!)
          else
            const Center(child: Text('Kamera Başlatılıyor...', style: TextStyle(color: Colors.white))),

          // Üst Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onKapat,
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: anaRenk, borderRadius: BorderRadius.circular(Olculer.yariCapTam)),
                    child: Text('Kamera [${palet.turAdi}]', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    tooltip: 'Sesli Asistan',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SesliAsistanDiyalogEkrani(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // Hedef Çerçevesi ve Dış Alanı Karartan Maske (Spotlight)
          KameraHedefMaskesi(
            cerceveRengi: anaRenk,
            genislik: 300,
            yukseklik: 180,
            ipucuMetni: 'Fiyat etiketini kutuya hizalayın',
          ),

          // Deklanşör Butonu
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                child: GestureDetector(
                  onTap: onFotoCek,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(color: anaRenk, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
