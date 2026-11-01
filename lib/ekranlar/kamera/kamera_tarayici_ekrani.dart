import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/durum_rozeti.dart';
import '../../servisler/kamera_servisi.dart';
import 'kamera_izni_gerekli_ekrani.dart';

/// Gerçek kamera görüntüsünü canlı veren ve çekim yapan arayüz
class KameraTarayiciEkrani extends StatefulWidget {
  final ValueChanged<String> onFotoCekildi; // Çekilen resmin yerel dosya yolu
  final VoidCallback onKapat;

  const KameraTarayiciEkrani({
    super.key,
    required this.onFotoCekildi,
    required this.onKapat,
  });

  @override
  State<KameraTarayiciEkrani> createState() => _KameraTarayiciEkraniState();
}

class _KameraTarayiciEkraniState extends State<KameraTarayiciEkrani> {
  CameraController? _kameraDenetleyici;
  bool _izinVerildi = false;
  bool _yukleniyor = true;
  bool _flasAcik = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _kamerayiHazirla();
  }

  Future<void> _kamerayiHazirla() async {
    final izinDurumu = await Permission.camera.request();
    if (!izinDurumu.isGranted) {
      if (mounted) {
        setState(() {
          _izinVerildi = false;
          _yukleniyor = false;
        });
      }
      return;
    }

    _izinVerildi = true;
    final kamera = KameraServisi.varsayilanArkaKamera;
    if (kamera != null) {
      _kameraDenetleyici = CameraController(
        kamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _kameraDenetleyici!.initialize();
      } catch (e) {
        debugPrint('Kamera hatası: $e');
      }
    }

    if (mounted) {
      setState(() => _yukleniyor = false);
    }
  }

  @override
  void dispose() {
    _kameraDenetleyici?.dispose();
    super.dispose();
  }

  Future<void> _fotoCek() async {
    if (_kameraDenetleyici == null || !_kameraDenetleyici!.value.isInitialized) return;
    if (_kameraDenetleyici!.value.isTakingPicture) return;

    try {
      final XFile dosya = await _kameraDenetleyici!.takePicture();
      widget.onFotoCekildi(dosya.path);
    } catch (e) {
      debugPrint('Fotoğraf çekme hatası: $e');
    }
  }

  Future<void> _galeridenSec() async {
    final XFile? secilen = await _picker.pickImage(source: ImageSource.gallery);
    if (secilen != null) {
      widget.onFotoCekildi(secilen.path);
    }
  }

  Future<void> _flasDegistir() async {
    if (_kameraDenetleyici == null || !_kameraDenetleyici!.value.isInitialized) return;
    setState(() => _flasAcik = !_flasAcik);
    await _kameraDenetleyici!.setFlashMode(
      _flasAcik ? FlashMode.torch : FlashMode.off,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: UygulamaRenkleri.anaZumrut),
        ),
      );
    }

    if (!_izinVerildi) {
      return KameraIzniGerekliEkrani(
        onAyarlaraGit: () => openAppSettings(),
        onGaleridenSec: _galeridenSec,
        onElleGir: widget.onKapat,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Canlı Kamera Önizlemesi
          if (_kameraDenetleyici != null && _kameraDenetleyici!.value.isInitialized)
            CameraPreview(_kameraDenetleyici!)
          else
            const Center(
              child: Text(
                'Kamera başlatılamadı',
                style: TextStyle(color: Colors.white),
              ),
            ),

          // 2. Üst Kontroller
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Olculer.boslukBuyuk,
                vertical: Olculer.boslukOrta,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: widget.onKapat,
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                      ),
                      DurumRozeti.cevrimdisi(),
                      IconButton(
                        onPressed: _flasDegistir,
                        icon: Icon(
                          _flasAcik ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _flasAcik ? UygulamaRenkleri.kolayModSari : Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Ortadaki Yeşil Tarama Çerçevesi
          Center(
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(
                  color: UygulamaRenkleri.anaZumrut,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                      ),
                      child: Text(
                        'Fiyat etiketini çerçeveye hizala',
                        style: MetinStilleri.aciklama(renk: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Alt Deklanşör ve Galeri Alanı
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _galeridenSec,
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                    GestureDetector(
                      onTap: _fotoCek,
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
                            decoration: const BoxDecoration(
                              color: UygulamaRenkleri.anaZumrut,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Simetri dengeleyici
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
