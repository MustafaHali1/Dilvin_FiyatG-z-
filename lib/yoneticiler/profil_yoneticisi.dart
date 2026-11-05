import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modeller/profil_modeli.dart';
import '../sabitler/uygulama_renkleri.dart';

/// Kullanıcı profilini, renk körlüğü türünü ve mod geçişlerini
/// SharedPreferences ile kalıcı olarak yöneten merkezi ViewModel
class ProfilYoneticisi extends ChangeNotifier {
  ProfilModeli _profil = const ProfilModeli();
  bool _kurulumTamamlandi = false;
  bool _yuklendi = false;

  static const String _keyProfilTuru = 'ayar_profil_turu';
  static const String _keyRenkKoruTuru = 'ayar_renk_koru_turu';
  static const String _keyAylikButce = 'ayar_aylik_butce';
  static const String _keyButceBaslangic = 'ayar_butce_baslangic';
  static const String _keyButceBitis = 'ayar_butce_bitis';
  static const String _keyKurulumTamamlandi = 'ayar_kurulum_tamamlandi';
  static const String _keySesliAsistan = 'ayar_sesli_asistan';
  static const String _keyTitresim = 'ayar_titresim';
  static const String _keyYaziBoyutu = 'ayar_yazi_boyutu';
  static const String _keyKaranlikMod = 'ayar_karanlik_mod';

  ProfilYoneticisi() {
    _tercihleriYukle();
  }

  ProfilModeli get profil => _profil;
  bool get kurulumTamamlandi => _kurulumTamamlandi;
  bool get yuklendi => _yuklendi;
  ProfilTuru get aktifMod => _profil.profilTuru;
  bool get kolayMod => _profil.profilTuru == ProfilTuru.kolayMod;
  bool get renkKoruModu => _profil.profilTuru == ProfilTuru.renkKoruModu;
  bool get gormeEngelliModu => _profil.profilTuru == ProfilTuru.gormeEngelliModu;

  /// Aktif renk körlüğü türüne göre tam renk paleti
  RenkKorluguPaleti get renkPaleti => RenkKorluguPaleti.getir(_profil.renkKorluguTuru);

  Future<void> _tercihleriYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilIndex = prefs.getInt(_keyProfilTuru);
      final renkKoruIndex = prefs.getInt(_keyRenkKoruTuru);
      final butce = prefs.getDouble(_keyAylikButce);
      final baslangicStr = prefs.getString(_keyButceBaslangic);
      final bitisStr = prefs.getString(_keyButceBitis);
      final kurulum = prefs.getBool(_keyKurulumTamamlandi);
      final sesli = prefs.getBool(_keySesliAsistan);
      final titresim = prefs.getBool(_keyTitresim);
      final yaziBoyutu = prefs.getDouble(_keyYaziBoyutu);
      final karanlik = prefs.getBool(_keyKaranlikMod);

      DateTime? baslangicTarihi;
      if (baslangicStr != null) {
        try { baslangicTarihi = DateTime.parse(baslangicStr); } catch (_) {}
      }

      DateTime? bitisTarihi;
      if (bitisStr != null) {
        try { bitisTarihi = DateTime.parse(bitisStr); } catch (_) {}
      }

      _profil = _profil.kopyala(
        profilTuru: profilIndex != null && profilIndex < ProfilTuru.values.length
            ? ProfilTuru.values[profilIndex]
            : ProfilTuru.standart,
        renkKorluguTuru: renkKoruIndex != null && renkKoruIndex < RenkKorluguTuru.values.length
            ? RenkKorluguTuru.values[renkKoruIndex]
            : RenkKorluguTuru.deuteranopi,
        aylikButce: butce ?? 5000.0,
        butceBaslangicTarihi: baslangicTarihi,
        butceBitisTarihi: bitisTarihi,
        sesliAsistanAcik: sesli ?? true,
        titresimAcik: titresim ?? true,
        yaziBoyutu: yaziBoyutu ?? 16.0,
        karanlikModAcik: karanlik ?? false,
      );

      _kurulumTamamlandi = kurulum ?? false;
      _yuklendi = true;
      notifyListeners();
    } catch (_) {
      _yuklendi = true;
      notifyListeners();
    }
  }

  Future<void> profilAyarla(ProfilTuru yeniTur) async {
    _profil = _profil.kopyala(profilTuru: yeniTur);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyProfilTuru, yeniTur.index);
    } catch (_) {}
  }

  Future<void> renkKorluguTuruAyarla(RenkKorluguTuru tur) async {
    _profil = _profil.kopyala(renkKorluguTuru: tur);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyRenkKoruTuru, tur.index);
    } catch (_) {}
  }

  Future<void> kurulumTamamlandiAyarla(bool tamamlandi) async {
    _kurulumTamamlandi = tamamlandi;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyKurulumTamamlandi, tamamlandi);
    } catch (_) {}
  }

  Future<void> yaziBoyutuAyarla(double yeniBoyut) async {
    _profil = _profil.kopyala(yaziBoyutu: yeniBoyut);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyYaziBoyutu, yeniBoyut);
    } catch (_) {}
  }

  void kontrastAyarla(String kontrast) {
    _profil = _profil.kopyala(kontrastTuru: kontrast);
    notifyListeners();
  }

  Future<void> butceAyarla(double yeniButce) async {
    _profil = _profil.kopyala(aylikButce: yeniButce);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyAylikButce, yeniButce);
    } catch (_) {}
  }

  Future<void> butceAraligiAyarla({
    required double yeniButce,
    required DateTime baslangic,
    required DateTime bitis,
  }) async {
    _profil = _profil.kopyala(
      aylikButce: yeniButce,
      butceBaslangicTarihi: baslangic,
      butceBitisTarihi: bitis,
    );
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyAylikButce, yeniButce);
      await prefs.setString(_keyButceBaslangic, baslangic.toIso8601String());
      await prefs.setString(_keyButceBitis, bitis.toIso8601String());
    } catch (_) {}
  }

  Future<void> sesliAsistanDegistir(bool acik) async {
    _profil = _profil.kopyala(sesliAsistanAcik: acik);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySesliAsistan, acik);
    } catch (_) {}
  }

  Future<void> titresimDegistir(bool acik) async {
    _profil = _profil.kopyala(titresimAcik: acik);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyTitresim, acik);
    } catch (_) {}
  }

  Future<void> karanlikModAyarla(bool acik) async {
    _profil = _profil.kopyala(karanlikModAcik: acik);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyKaranlikMod, acik);
    } catch (_) {}
  }
}
