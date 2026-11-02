import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../modeller/urun_modeli.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../sepet/sepet_ekrani.dart';
import '../sesli_asistan/sesli_asistan_diyalog_ekrani.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../ayarlar/ayarlar_ekrani.dart';

/// Görme Engelli / Sesli Radar ve Haptik Kamera Ekranı
/// (Stitch: sesli_radar_kamera birebir)
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _waveformTimer;
  List<double> _waveformHeights = [14, 28, 42, 24, 38, 18, 32];
  bool _fenerAcik = false;
  DateTime? _sonDokunmaZamani;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveformTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          _waveformHeights = [
            12.0 + (timer.tick % 4) * 6,
            24.0 + (timer.tick % 5) * 5,
            38.0 + (timer.tick % 3) * 6,
            20.0 + (timer.tick % 6) * 4,
            34.0 + (timer.tick % 4) * 7,
            16.0 + (timer.tick % 5) * 5,
            30.0 + (timer.tick % 3) * 8,
          ];
        });
      }
    });

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    _waveformTimer?.cancel();
    super.dispose();
  }

  void _sesliGeriBildirim(String mesaj) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFFD600),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mesaj,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sepeteEkleVeBildir() {
    final sepet = context.read<SepetYoneticisi>();
    sepet.urunEkle(
      UrunModeli(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ad: 'Sütaş Süt 1L',
        birimFiyat: 24.90,
      ),
    );
    _sesliGeriBildirim('Sütaş Süt sepete eklendi! Toplam: ${sepet.toplamTutar.toStringAsFixed(2)} ₺');
  }

  void _dokunmaIsle(BuildContext ctx) {
    final simdi = DateTime.now();
    if (_sonDokunmaZamani != null &&
        simdi.difference(_sonDokunmaZamani!) < const Duration(milliseconds: 500)) {
      _sepeteEkleVeBildir();
      _sonDokunmaZamani = null;
    } else {
      _sonDokunmaZamani = simdi;
      HapticFeedback.lightImpact();
    }
  }

  void _fenerDegistir() {
    setState(() {
      _fenerAcik = !_fenerAcik;
    });
    HapticFeedback.mediumImpact();
    _sesliGeriBildirim(_fenerAcik ? 'Kamera feneri açıldı' : 'Kamera feneri kapatıldı');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E11).withValues(alpha: 0.95),
        elevation: 4,
        toolbarHeight: 76,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD600), size: 30),
          onPressed: widget.onKapat,
          tooltip: 'Geri Dön',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD600),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SESLİ MOD AKTİF',
                  style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Sesli Radar',
              style: TextStyle(
                color: Color(0xFFE4E1E6),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFFFD600), size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AyarlarEkrani()),
              );
            },
            tooltip: 'Ayarlar ve Mod Değiştir',
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Color(0xFFFFD600), size: 30),
            onPressed: () {
              _sesliGeriBildirim('Etiket kadrajda ortalandı. Fiyat 24 lira 90 kuruş. Çift dokunarak sepete ekleyebilirsiniz.');
            },
            tooltip: 'Ekranı Sesli Tekrar Oku',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KullaniciProfiliEkrani()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFF5DC),
                child: Icon(Icons.person, color: Color(0xFF3A3000), size: 22),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            _fenerDegistir();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Canlı Bilgilendirme Kutusu (Amber Yellow Box)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD600).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up, color: Colors.black, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '“Etiket kadrajda ortalandı, otomatik çekildi”',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.black.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.straighten, color: Colors.black, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Mesafe: 15 cm',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Fiyat: 24,90 ₺',
                              style: TextStyle(
                                color: Color(0xFFFFD600),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Radar & Ses Dalgaları Çekirdek Alanı
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dönen Radar Halkaları
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animController.value * 2 * 3.14159,
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: _RadarHalkalariRessami(),
                          ),
                        );
                      },
                    ),

                    // Merkez Hedef ve Dinamik Ses Dalgaları
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0E0E11),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.filter_center_focus,
                            color: Color(0xFFFFD600),
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E11).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _waveformHeights.map((h) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD600),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                    // Alt Telemetri Rozetleri
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF353438),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.vibration, color: Color(0xFFFFD600), size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        'Haptik:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'ÇOK YAKIN',
                                    style: TextStyle(
                                      color: Color(0xFFFFD600),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1B1E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.graphic_eq, color: Color(0xFF60F587), size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        '1.200 Hz',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Kilitlendi',
                                    style: TextStyle(
                                      color: Color(0xFF60F587),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Tespit Edilen Ürün Önizleme Kartı (Dokun & Dinle)
              InkWell(
                onTap: () {
                  _sesliGeriBildirim('Tespit edilen ürün: Sütaş Tam Yağlı Süt 1 Litre. Fiyat: 24 lira 90 kuruş.');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E0E11),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TESPİT EDİLEN ÜRÜN',
                              style: TextStyle(
                                color: Color(0xFFFFD600),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.replay, color: Color(0xFFFFD600), size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Dinle',
                                style: TextStyle(
                                  color: Color(0xFFFFD600),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sütaş Süt 1L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '24,90 ₺',
                            style: TextStyle(
                              color: Color(0xFFFFD600),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.white54, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Ürün detayını dinlemek için dokunun',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Dev Dokunsal Sepete Ekleme Alanı (Tactile Zone)
              InkWell(
                onTap: () => _dokunmaIsle(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 160),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD600).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.ads_click, color: Colors.black.withValues(alpha: 0.8), size: 30),
                          const SizedBox(width: 8),
                          const Text(
                            'HER YERE DOKUNABİLİRSİNİZ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'SEPETE EKLEMEK İÇİN ÇİFT DOKUN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '24,90 ₺',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.record_voice_over, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sesli Onay: “Sütaş Süt sepete eklenecek”',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. Dokunsal Hareket İpuçları Kutusu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.swipe_up, color: Color(0xFFFFD600), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Yukarı Kaydır:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _fenerAcik ? 'Feneri Kapat' : 'Feneri Aç',
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF2A2A2D), height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pinch, color: Color(0xFFFFD600), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'İki Parmakla Dokun:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Yeniden Tara',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E11),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF2A2A2D),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, color: Color(0xFFFFD600), size: 32),
                    SizedBox(height: 4),
                    Text(
                      'Radar',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SepetEkrani(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Sepet',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SesliAsistanDiyalogEkrani(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Asistan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AyarlarEkrani(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Ayarlar',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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

class _RadarHalkalariRessami extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 90, paint);
    canvas.drawCircle(center, 60, paint..strokeWidth = 1.5);
    canvas.drawCircle(center, 35, paint..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
