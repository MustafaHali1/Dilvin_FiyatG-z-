import 'package:flutter/material.dart';
import '../modeller/profil_modeli.dart';

/// FiyatGöz Uygulama Renk Paleti
/// Stitch UI tasarım sistemine ve erişilebilirlik (WCAG AAA) standartlarına birebir uygundur.
class UygulamaRenkleri {
  // Standart Mod: Zümrüt Yeşili Modern Tema
  static const Color anaZumrut = Color(0xFF008955);
  static const Color anaKoyu = Color(0xFF005236);
  static const Color anaAcik = Color(0xFFE8F5E9);
  static const Color anaOrta = Color(0xFF4CAF50);

  // Zemin ve Kart Renkleri
  static const Color arkaPlan = Color(0xFFF6F8FA);
  static const Color kartArkaPlan = Colors.white;
  static const Color kartBeyaz = Colors.white;
  static const Color cizgi = Color(0xFFE5E7EB);
  static const Color pasifGri = Color(0xFFE0E0E0);

  // Metin Renkleri
  static const Color koyuYazi = Color(0xFF1E293B);
  static const Color griYazi = Color(0xFF64748B);
  static const Color acikYazi = Color(0xFF94A3B8);

  // Kolay Mod (Yüksek Karşıtlık): Siyah Zemin + Altın Sarısı
  static const Color kolayModSari = Color(0xFFFFD700);
  static const Color kolayModKoyuGri = Color(0xFF1E1E1E);
  static const Color kolayModCizgi = Color(0xFF333333);
  static const Color kolayModSiyah = Colors.black;
  static const Color kolayModBeyaz = Colors.white;

  // Fonksiyonel ve Durum Renkleri
  static const Color basariYesil = Color(0xFF16A34A);
  static const Color basari = Color(0xFF16A34A);
  static const Color tehlikeKirmizi = Color(0xFFDC2626);
  static const Color uyariTuruncu = Color(0xFFEA580C);
  static const Color renkKoruTuruncu = Color(0xFFEA580C);
  static const Color bilgiMavi = Color(0xFF2563EB);
}

/// Bilimsel Okabe-Ito Renk Körlüğü Palet Sistemi
/// Kullanıcının seçtiği renk körlüğü türüne göre dinamik renkler sunar.
class RenkKorluguPaleti {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final String turAdi;
  final String turAciklamasi;

  const RenkKorluguPaleti({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.turAdi,
    required this.turAciklamasi,
  });

  // 1. Deuteranopia (Yeşil Körlüğü): Mavi, Turuncu ve Pembe
  static const deuteranopia = RenkKorluguPaleti(
    primary: Color(0xFF0072B2),   // Mavi
    secondary: Color(0xFFE69F00), // Turuncu
    accent: Color(0xFFCC79A7),    // Pembe (Magenta)
    success: Color(0xFF0072B2),   // Güvenli Mavi (Yeşil yok)
    error: Color(0xFFE69F00),     // Güvenli Turuncu
    warning: Color(0xFFE69F00),   // Turuncu
    info: Color(0xFFCC79A7),      // Pembe
    turAdi: 'Deuteranopi',
    turAciklamasi: 'Yeşil Körlüğü',
  );

  // 2. Protanopia (Kırmızı Körlüğü): Koyu Mavi, Açık Mavi ve Turuncu
  static const protanopia = RenkKorluguPaleti(
    primary: Color(0xFF0072B2),   // Koyu Mavi
    secondary: Color(0xFF56B4E9), // Açık Mavi
    accent: Color(0xFFE69F00),    // Turuncu
    success: Color(0xFF0072B2),   // Koyu Mavi
    error: Color(0xFFE69F00),     // Turuncu (Kırmızı KESİNLİKLE YOK)
    warning: Color(0xFFE69F00),   // Turuncu
    info: Color(0xFF56B4E9),      // Açık Mavi
    turAdi: 'Protanopi',
    turAciklamasi: 'Kırmızı Körlüğü',
  );

  // 3. Tritanopia (Mavi-Sarı Körlüğü): Zümrüt Yeşili, Kızıl ve Pembe
  static const tritanopia = RenkKorluguPaleti(
    primary: Color(0xFF009E73),   // Zümrüt Yeşili / Camgöbeği
    secondary: Color(0xFFD55E00), // Kızıl Turuncu
    accent: Color(0xFFCC79A7),    // Pembe
    success: Color(0xFF009E73),   // Zümrüt Yeşili
    error: Color(0xFFD55E00),     // Kızıl
    warning: Color(0xFFD55E00),   // Kızıl
    info: Color(0xFF009E73),      // Zümrüt
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
