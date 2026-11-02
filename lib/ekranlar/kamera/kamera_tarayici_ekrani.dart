import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../servisler/kamera_servisi.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'kamera_izni_gerekli_ekrani.dart';
import 'kolay_mod_kamera_view.dart';
import 'renk_koru_kamera_view.dart';
import 'gorme_engelli_radar_kamera_view.dart';
import '../../servisler/resim_kirpma_servisi.dart';
import '../../bilesenler/kamera_hedef_maskesi.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../bilesenler/durum_rozeti.dart';

/// Kullanıcının seçtiği profile göre birebir Kamera tasarımını ekrana getiren dinamik bağlayıcı
class KameraTarayiciEkrani extends StatefulWidget {
  final ValueChanged<String> onFotoCekildi;
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
    final izin = await Permission.camera.request();
    if (!izin.isGranted) {
      if (mounted) setState(() { _izinVerildi = false; _yukleniyor = false; });
      return;
    }

    _izinVerildi = true;
    final kamera = KameraServisi.varsayilanArkaKamera;
    if (kamera != null) {
      _kameraDenetleyici = CameraController(kamera, ResolutionPreset.high, enableAudio: false);
      try {
        await _kameraDenetleyici!.initialize();
      } catch (e) {
        debugPrint('Kamera hatasi: $e');
      }
    }

    if (mounted) setState(() => _yukleniyor = false);
  }

  @override
  void dispose() {
    _kameraDenetleyici?.dispose();
    super.dispose();
  }

  Future<void> _fotoCek() async {
    if (_kameraDenetleyici == null || !_kameraDenetleyici!.value.isInitialized) return;
    try {
      final XFile dosya = await _kameraDenetleyici!.takePicture();
      // Çekilen fotoğrafı fiziksel olarak sadece hedef kutusuna kırpıyoruz!
      final kirpilmisYol = await ResimKirpmaServisi.hedefKutusunuKirp(dosya.path);
      widget.onFotoCekildi(kirpilmisYol);
    } catch (e) {
      debugPrint('Foto çekme hatası: $e');
    }
  }

  Future<void> _galeridenSec() async {
    final XFile? secilen = await _picker.pickImage(source: ImageSource.gallery);
    if (secilen != null) widget.onFotoCekildi(secilen.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    if (!_izinVerildi) {
      return KameraIzniGerekliEkrani(
        onAyarlaraGit: () => openAppSettings(),
        onGaleridenSec: _galeridenSec,
        onElleGir: widget.onKapat,
      );
    }

    final profil = context.watch<ProfilYoneticisi>().profil;

    // 1. Kolay Mod Seçiliyse: Siyah-Sarı Devasa Deklanşörlü Kamera
    if (profil.profilTuru == ProfilTuru.kolayMod) {
      return KolayModKameraView(
        cameraController: _kameraDenetleyici,
        onFotoCek: _fotoCek,
        onKapat: widget.onKapat,
      );
    }

    // 2. Renk Körü Modu Seçiliyse: Mavi Hedef İbreli Kamera
    if (profil.profilTuru == ProfilTuru.renkKoruModu) {
      return RenkKoruKameraView(
        cameraController: _kameraDenetleyici,
        onFotoCek: _fotoCek,
        onKapat: widget.onKapat,
      );
    }

    // 3. Görme Engelli Modu Seçiliyse: Sesli Radar ve Haptik Kamera
    if (profil.profilTuru == ProfilTuru.gormeEngelliModu) {
      return GormeEngelliRadarKameraView(
        cameraController: _kameraDenetleyici,
        onFotoCek: _fotoCek,
        onKapat: widget.onKapat,
      );
    }

    // 3. Standart Mod: Canlı Yeşil Çerçeveli M3 Kamera
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_kameraDenetleyici != null && _kameraDenetleyici!.value.isInitialized)
            CameraPreview(_kameraDenetleyici!)
          else
            const Center(child: Text('Kamera Başlatılamadı', style: TextStyle(color: Colors.white))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk, vertical: Olculer.boslukOrta),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onKapat,
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                  DurumRozeti.cevrimdisi(),
                  IconButton(
                    onPressed: () {
                      if (_kameraDenetleyici != null) {
                        setState(() => _flasAcik = !_flasAcik);
                        _kameraDenetleyici!.setFlashMode(_flasAcik ? FlashMode.torch : FlashMode.off);
                      }
                    },
                    icon: Icon(_flasAcik ? Icons.flash_on : Icons.flash_off, color: _flasAcik ? Colors.yellow : Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                ],
              ),
            ),
          ),

          // Dış Alanı Karartan Hedef Çerçevesi (Spotlight Mask)
          const KameraHedefMaskesi(
            cerceveRengi: UygulamaRenkleri.anaZumrut,
            genislik: 300,
            yukseklik: 180,
            ipucuMetni: 'Fiyat etiketini çerçeveye hizala',
          ),

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
                      style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(14)),
                    ),
                    GestureDetector(
                      onTap: _fotoCek,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(color: UygulamaRenkleri.anaZumrut, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
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
