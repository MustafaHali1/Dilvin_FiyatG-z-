import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../sesli_asistan/sesli_asistan_diyalog_ekrani.dart';

/// Kolay Mod - Kamera Ekranı (Stitch: kolay_mod_kamera birebir)
class KolayModKameraView extends StatelessWidget {
  final CameraController? cameraController;
  final VoidCallback onFotoCek;
  final VoidCallback onKapat;

  const KolayModKameraView({
    super.key,
    required this.cameraController,
    required this.onFotoCek,
    required this.onKapat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Üst Bar: Kapatma Butonu ve Başlık
            Padding(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onKapat,
                    icon: const Icon(Icons.arrow_back, color: UygulamaRenkleri.kolayModSari, size: 28),
                    label: Text('GERİ DÖN', style: MetinStilleri.kolayModBaslik()),
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
                    icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.kolayModSari, size: 34),
                  ),
                ],
              ),
            ),

            // Sesli Rehber Kutusu (Sarı Kart)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk),
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: UygulamaRenkleri.kolayModSari,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              ),
              child: const Row(
                children: [
                  Icon(Icons.volume_up_rounded, color: Colors.black, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SESLİ REHBER', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                        Text('« Etiket algılandı, otomatik çekiliyor... »', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // Canlı Kamera Önizlemesi (Yarım Ekran)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                  border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: cameraController != null && cameraController!.value.isInitialized
                    ? CameraPreview(cameraController!)
                    : const Center(child: Text('Kamera Hazır', style: TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // DEKORATİF / BASILABİLİR DEVASA SARI DEKLANŞÖR ALANI (72dp+)
            Padding(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onFotoCek,
                  icon: const Icon(Icons.camera_alt, color: Colors.black, size: 36),
                  label: const Text('FİYATI ÇEK\n(BURAYA YA DA EKRANA DOKUNUN)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UygulamaRenkleri.kolayModSari,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
