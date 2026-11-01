import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'uygulama_renkleri.dart';

/// Tipografi ve Metin Stilleri Sınıfı
class MetinStilleri {
  static TextStyle devBaslik({Color renk = UygulamaRenkleri.koyuYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: renk,
        letterSpacing: -0.5,
      );

  static TextStyle baslik1({Color renk = UygulamaRenkleri.koyuYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: renk,
      );

  static TextStyle baslik2({Color renk = UygulamaRenkleri.koyuYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: renk,
      );

  static TextStyle govde({Color renk = UygulamaRenkleri.koyuYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: renk,
      );

  static TextStyle govdeKalin({Color renk = UygulamaRenkleri.koyuYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: renk,
      );

  static TextStyle aciklama({Color renk = UygulamaRenkleri.griYazi}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: renk,
      );

  static TextStyle fiyat({Color renk = UygulamaRenkleri.koyuYazi, double boyut = 22}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: boyut,
        fontWeight: FontWeight.w800,
        color: renk,
      );

  // Kolay Mod Stilleri
  static TextStyle kolayModDev({Color renk = UygulamaRenkleri.kolayModSari}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: renk,
      );

  static TextStyle kolayModBaslik({Color renk = UygulamaRenkleri.kolayModBeyaz}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: renk,
      );

  static TextStyle kolayModGovde({Color renk = UygulamaRenkleri.kolayModBeyaz}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: renk,
      );
}
