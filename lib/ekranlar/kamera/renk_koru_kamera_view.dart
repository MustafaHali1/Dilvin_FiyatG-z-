import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';

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
    const anaMavi = UygulamaRenkleri.renkKoruMavi;

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
                    decoration: BoxDecoration(color: anaMavi, borderRadius: BorderRadius.circular(Olculer.yariCapTam)),
                    child: const Text('Renk Güvenli Kamera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Mavi Artı İbreli Hedef Çerçevesi
          Center(
            child: Container(
              width: 290,
              height: 170,
              decoration: BoxDecoration(
                border: Border.all(color: anaMavi, width: 3),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 12,
                    child: Text('Fiyat etiketini ortala', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
                  ),
                ],
              ),
            ),
          ),

          // Mavi Deklanşör Butonu
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
                        decoration: const BoxDecoration(color: anaMavi, shape: BoxShape.circle),
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
