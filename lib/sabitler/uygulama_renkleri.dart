import 'package:flutter/material.dart';
import '../modeller/profil_modeli.dart';

/// FiyatGoz Tasarim Sistemi Renk Sabitleri
class UygulamaRenkleri {
  // Ana Zumrut Yesili Paleti (ASCII identifier)
  static const Color anaZumrut = Color(0xFF10B981);
  static const Color anaKoyu = Color(0xFF059669);
  static const Color anaAcik = Color(0xFFD1FAE5);

  // Notr Renkler
  static const Color arkaPlan = Color(0xFFF8FAFC);
  static const Color kartBeyaz = Color(0xFFFFFFFF);
  static const Color koyuYazi = Color(0xFF0F172A);
  static const Color griYazi = Color(0xFF64748B);
  static const Color cizgi = Color(0xFFE2E8F0);

  // Durum Renkleri
  static const Color uyariTuruncu = Color(0xFFF59E0B);
  static const Color tehlikeKirmizi = Color(0xFFEF4444);
  static const Color basari = Color(0xFF10B981);
  static const Color bilgiMavi = Color(0xFF3B82F6);

  // Kolay Mod (Yuksek Kontrast)
  static const Color kolayModSiyah = Color(0xFF000000);
  static const Color kolayModSari = Color(0xFFFFD600);
  static const Color kolayModBeyaz = Color(0xFFFFFFFF);

  // Renk Koru Guvenli Palet (Deuteranopia / Protanopia / Tritanopia)
  static const Color renkKoruMavi = Color(0xFF0072B2);
  static const Color renkKoruTuruncu = Color(0xFFE69F00);
  static const Color renkKoruSari = Color(0xFFF0E442);
}

/// Bilimsel Okabe-Ito Renk Körlüğü Palet Sistemi
/// Kullanıcının seçtiği renk körlüğü türüne göre dinamik renkler sunar.
class RenkKorluguPaleti {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final String turAdi;
  final String turAciklamasi;

  const RenkKorluguPaleti({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.turAdi,
    required this.turAciklamasi,
  });

  // 1. Deuteranopia (Yeşil Körlüğü)
  static const deuteranopia = RenkKorluguPaleti(
    primary: Color(0xFF0072B2),   // Koyu Mavi
    secondary: Color(0xFFE69F00), // Turuncu
    success: Color(0xFF0072B2),
    error: Color(0xFFCC79A7),     // Magenta / Gül Kurusu
    warning: Color(0xFFE69F00),   // Turuncu
    info: Color(0xFF56B4E9),      // Açık Mavi
    turAdi: 'Deuteranopi',
    turAciklamasi: 'Yeşil Körlüğü',
  );

  // 2. Protanopia (Kırmızı Körlüğü)
  static const protanopia = RenkKorluguPaleti(
    primary: Color(0xFF0072B2),   // Koyu Mavi (Kırmızı körü için yeşil yerine güvenli mavi)
    secondary: Color(0xFFE69F00), // Turuncu
    success: Color(0xFF0072B2),   // Koyu Mavi
    error: Color(0xFFCC79A7),     // Magenta / Gül Kurusu
    warning: Color(0xFFE69F00),   // Turuncu
    info: Color(0xFF56B4E9),      // Açık Mavi
    turAdi: 'Protanopi',
    turAciklamasi: 'Kırmızı Körlüğü',
  );

  // 3. Tritanopia (Mavi-Sarı Körlüğü)
  static const tritanopia = RenkKorluguPaleti(
    primary: Color(0xFFD55E00),   // Kızıl / Koyu Turuncu
    secondary: Color(0xFF009E73), // Zümrüt Yeşili
    success: Color(0xFF009E73),   // Zümrüt Yeşili
    error: Color(0xFFD55E00),     // Kızıl
    warning: Color(0xFFCC79A7),   // Magenta / Pembe
    info: Color(0xFF009E73),      // Zümrüt Yeşili
    turAdi: 'Tritanopi',
    turAciklamasi: 'Mavi-Sarı Körlüğü',
  );

  static RenkKorluguPaleti getir(RenkKorluguTuru tur) {
    switch (tur) {
      case RenkKorluguTuru.deuteranopi:
        return deuteranopia;
      case RenkKorluguTuru.protanopi:
        return protanopia;
      case RenkKorluguTuru.tritanopi:
        return tritanopia;
    }
  }
}
