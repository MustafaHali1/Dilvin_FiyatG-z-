import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/sesli_radar_yoneticisi.dart';
import '../../servisler/kamera_servisi.dart';
import '../../servisler/fiyat_tanima_servisi.dart';
import '../../servisler/resim_kirpma_servisi.dart';
import '../ayarlar/ayarlar_ekrani.dart';

/// %100 Ses ve Konuşma Odaklı Görme Engelli Radarı & Canlı Kamera Ekranı
/// Karışık butonlar, dönen çizgiler ve jest ezberleri tamamen kaldırılmıştır.
/// Kullanıcı yalnızca konuşarak asistanla diyalog kurar.
class GormeEngelliRadarKameraView extends StatefulWidget {
  final CameraController? cameraController;
  final VoidCallback onFotoCek;
  final VoidCallback onKapat;

  const GormeEngelliRadarKameraView({
    super.key,
    required this.cameraController,
    required this.onFotoCek,
    required this.onKapat,
  });

  @override
  State<GormeEngelliRadarKameraView> createState() =>
      _GormeEngelliRadarKameraViewState();
}

class _GormeEngelliRadarKameraViewState extends State<GormeEngelliRadarKameraView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _yerelKameraDenetleyici;
  bool _kameraHazir = false;
  bool _tariyor = false;
  Timer? _otomatikTaramaZamanlayici;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _kameraBaslat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profil = context.read<ProfilYoneticisi>().profil;
        final sepet = context.read<SepetYoneticisi>();
        final radar = context.read<SesliRadarYoneticisi>();
        radar.baslat(
          sesliAsistanAcik: profil.sesliAsistanAcik,
          sepet: sepet,
          profil: profil,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arka plana geçtiğinde veya kilitlendiğinde kamerayı güvenle serbest bırakıyoruz
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _otomatikTaramaZamanlayici?.cancel();
      _yerelKameraDenetleyici?.dispose();
      _yerelKameraDenetleyici = null;
      if (mounted) setState(() => _kameraHazir = false);
    } else if (state == AppLifecycleState.resumed) {
      _kameraBaslat();
    }
  }

  Future<void> _kameraBaslat() async {
    if (!mounted) return;
    if (_yerelKameraDenetleyici != null && _yerelKameraDenetleyici!.value.isInitialized) {
      if (mounted) setState(() => _kameraHazir = true);
      _otomatikTaramayiBaslat();
      return;
    }

    final kamera = KameraServisi.varsayilanArkaKamera;
    if (kamera != null) {
      final controller = CameraController(
        kamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      try {
        await controller.initialize();
        if (mounted) {
          setState(() {
            _yerelKameraDenetleyici = controller;
            _kameraHazir = true;
          });
          _otomatikTaramayiBaslat();
        } else {
          controller.dispose();
        }
      } catch (e) {
        debugPrint('Görme engelli kamera başlatma hatası: $e');
        controller.dispose();
      }
    }
  }

  /// Arka planda periyodik olarak kamerayı dinleyip etiket yakalar
  void _otomatikTaramayiBaslat() {
    _otomatikTaramaZamanlayici?.cancel();
    _otomatikTaramaZamanlayici = Timer.periodic(const Duration(milliseconds: 3500), (timer) async {
      final radar = context.read<SesliRadarYoneticisi>();
      if (!mounted ||
          _tariyor ||
          radar.konusuyor ||
          _yerelKameraDenetleyici == null ||
          !_yerelKameraDenetleyici!.value.isInitialized ||
          _yerelKameraDenetleyici!.value.isTakingPicture) {
        return;
      }

      // Eğer ürün bulunmuş ve kullanıcıdan onay bekleniyorsa taramayı beklet
      if (radar.durum == RadarDurumu.urunBulundu) return;

      _tariyor = true;
      try {
        if (_yerelKameraDenetleyici != null && _yerelKameraDenetleyici!.value.isInitialized) {
          final XFile resim = await _yerelKameraDenetleyici!.takePicture();
          final kirpilmis = await ResimKirpmaServisi.hedefKutusunuKirp(resim.path);
          final sonuc = await FiyatTanimaServisi().resmiTara(kirpilmis);

          if (mounted && sonuc.basarili && sonuc.tespitEdilenFiyat != null) {
            final profil = context.read<ProfilYoneticisi>().profil;
            final sepet = context.read<SepetYoneticisi>();
            await radar.etiketAlgilandi(sonuc, profil: profil, sepet: sepet);
          }
        }
      } catch (e) {
        debugPrint('Otomatik OCR tarama hatası: $e');
      } finally {
        _tariyor = false;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otomatikTaramaZamanlayici?.cancel();
    _pulseController.dispose();
    _yerelKameraDenetleyici?.dispose();
    _yerelKameraDenetleyici = null;
    super.dispose();
  }

  void _ekranaDokunuldu() {
    HapticFeedback.mediumImpact();
    final radar = context.read<SesliRadarYoneticisi>();
    final profil = context.read<ProfilYoneticisi>().profil;
    final sepet = context.read<SepetYoneticisi>();

    // Eğer asistan konuşmuyorsa dinlemeyi tazele
    if (!radar.konusuyor) {
      radar.dinlemeyiBaslat(sepet: sepet, profil: profil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radar = context.watch<SesliRadarYoneticisi>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _ekranaDokunuldu,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Arka Planda Canlı Kamera (Görmeyen için gereksiz yere göz almasın diye yarı saydam)
            if (_kameraHazir && _yerelKameraDenetleyici != null)
              Opacity(
                opacity: 0.35,
                child: CameraPreview(_yerelKameraDenetleyici!),
              )
            else
              Container(color: Colors.black),

            // 2. Üst Bar: Minimal ve Temiz
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.record_voice_over_rounded, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SESLİ ALIŞVERİŞ MODU',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ayarlar',
                        icon: const Icon(Icons.settings_rounded, color: Color(0xFFFFD600), size: 28),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AyarlarEkrani()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Merkez: Devasa Nabız Atan Mikrofon ve Durum
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.12);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD600).withValues(alpha: 0.5),
                                blurRadius: 28,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            radar.konusuyor
                                ? Icons.volume_up_rounded
                                : (radar.durum == RadarDurumu.dinliyor
                                    ? Icons.mic_rounded
                                    : Icons.filter_center_focus_rounded),
                            color: Colors.black,
                            size: 54,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD600), width: 1.5),
                    ),
                    child: Text(
                      radar.konusuyor
                          ? 'Asistan Konuşuyor...'
                          : (radar.durum == RadarDurumu.dinliyor
                              ? 'Sizi Dinliyorum...'
                              : 'Etiket Taranıyor...'),
                      style: const TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Alt Bölge: Az Görenler / Yanındakiler İçin 30 Punto Devasa Sarı Yazı
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD600), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (radar.kullaniciMetni.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '“${radar.kullaniciMetni}”',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFFFD600), size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            radar.asistanMesaji,
                            style: const TextStyle(
                              color: Color(0xFFFFD600),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sadece konuşarak "Evet", "Ekle", "Kalsın", "Sepette ne var" diyebilirsiniz.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
