import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../bilesenler/kamera_hedef_maskesi.dart';
import '../../bilesenler/durum_rozeti.dart';

/// Kolay Mod - Kamera Ekranı
/// Standart mod ile birebir aynı tam ekran odak ve maske kurallarını uygular,
/// ancak yüksek kontrastlı sarı çerçeve ve devasa dokunma alanlarına sahiptir.
class KolayModKameraView extends StatefulWidget {
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
  State<KolayModKameraView> createState() => _KolayModKameraViewState();
}

class _KolayModKameraViewState extends State<KolayModKameraView> {
  bool _flasAcik = false;

  @override
  Widget build(BuildContext context) {
    final bool kameraHazir =
        widget.cameraController != null && widget.cameraController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Yaşlı veya görme güçlüğü çeken kullanıcılar için ekrana herhangi bir yere dokunarak da çekim yapılabilir
        onTap: widget.onFotoCek,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Canlı Tam Ekran Kamera Önizlemesi
            if (kameraHazir)
              CameraPreview(widget.cameraController!)
            else
              const Center(
                child: Text(
                  'Kamera Başlatılıyor...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

            // 2. Dış Alanı Karartan Hedef Çerçevesi (Sarı Yüksek Kontrast Maskesi)
            const KameraHedefMaskesi(
              cerceveRengi: UygulamaRenkleri.kolayModSari,
              genislik: 300,
              yukseklik: 180,
              ipucuMetni: 'Fiyat etiketini sarı kutunun içine tutun',
            ),

            // 3. Üst Bar: Geri Dön, Durum Rozeti ve Flaş
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Olculer.boslukBuyuk,
                    vertical: Olculer.boslukOrta,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Geri Dön Butonu
                      ElevatedButton.icon(
                        onPressed: widget.onKapat,
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                        label: const Text(
                          'GERİ DÖN',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UygulamaRenkleri.kolayModSari,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                          ),
                        ),
                      ),
                      DurumRozeti.cevrimdisi(),
                      // Flaş Butonu
                      IconButton(
                        onPressed: () {
                          if (kameraHazir) {
                            setState(() => _flasAcik = !_flasAcik);
                            widget.cameraController!.setFlashMode(
                              _flasAcik ? FlashMode.torch : FlashMode.off,
                            );
                          }
                        },
                        icon: Icon(
                          _flasAcik ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _flasAcik ? UygulamaRenkleri.kolayModSari : Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(10),
                        ),
                        tooltip: 'Flaş',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Alt Kısım: Devasa Sarı Deklanşör Butonu
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                  child: SizedBox(
                    width: double.infinity,
                    height: 84,
                    child: ElevatedButton.icon(
                      onPressed: widget.onFotoCek,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 36),
                      label: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'FİYATI ÇEK',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '(BURAYA YA DA EKRANA DOKUNUN)',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.kolayModSari,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                        ),
                      ),
                    ),
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
