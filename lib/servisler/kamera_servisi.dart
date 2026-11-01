import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Kamera donanımını yöneten servis class'ı
class KameraServisi {
  static List<CameraDescription> _kameralar = [];
  static bool _hazirMi = false;

  static bool get hazirMi => _hazirMi;
  static List<CameraDescription> get kameralar => _kameralar;

  static Future<void> baslat() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _kameralar = await availableCameras();
      _hazirMi = _kameralar.isNotEmpty;
    } catch (e) {
      debugPrint('Kamera başlatma hatası: $e');
      _hazirMi = false;
    }
  }

  static CameraDescription? get varsayilanArkaKamera {
    if (_kameralar.isEmpty) return null;
    return _kameralar.firstWhere(
      (k) => k.lensDirection == CameraLensDirection.back,
      orElse: () => _kameralar.first,
    );
  }
}
