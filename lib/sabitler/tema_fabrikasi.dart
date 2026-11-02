import 'package:flutter/material.dart';
import 'uygulama_renkleri.dart';
import '../modeller/profil_modeli.dart';

/// Kullanicinin sectigi profile gore canli Theme ureten fabrika class'i
class TemaFabrikasi {
  static ThemeData olustur(ProfilModeli profil) {
    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
        return _kolayModTemasi();
      case ProfilTuru.renkKoruModu:
        return _renkKoruTemasi(profil.renkKorluguTuru);
      case ProfilTuru.gormeEngelliModu:
        return _kolayModTemasi(); // Yüksek kontrast ve büyük odak
      case ProfilTuru.standart:
        return _standartTema();
    }
  }

  // 1. STANDART TEMA (Zumrut Yesili M3)
  static ThemeData _standartTema() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: UygulamaRenkleri.anaZumrut,
      scaffoldBackgroundColor: UygulamaRenkleri.arkaPlan,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: UygulamaRenkleri.koyuYazi,
        elevation: 0,
      ),
    );
  }

  // 2. KOLAY MOD TEMASI (Siyah Zemin, Devasa Sari Yazilar, Yuksek Kontrast)
  static ThemeData _kolayModTemasi() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: UygulamaRenkleri.kolayModSari,
        onPrimary: Colors.black,
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: UygulamaRenkleri.kolayModSari,
        elevation: 0,
      ),
    );
  }

  // 3. RENK KORU TEMASI (Dinamik Bilimsel Palet: Deuteranopia, Protanopia, Tritanopia)
  static ThemeData _renkKoruTemasi(RenkKorluguTuru tur) {
    final palet = RenkKorluguPaleti.getir(tur);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: palet.primary,
        secondary: palet.secondary,
        error: palet.error,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: UygulamaRenkleri.koyuYazi,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: palet.primary,
        elevation: 0,
      ),
    );
  }
}
