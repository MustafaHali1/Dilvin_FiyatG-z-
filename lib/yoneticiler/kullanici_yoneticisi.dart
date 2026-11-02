import 'package:flutter/material.dart';
import '../modeller/kullanici_modeli.dart';
import '../servisler/veritabani_servisi.dart';

/// Kullanıcı profil bilgilerini ve indirim bülteni tercihlerini SQLite üzerinden yöneten ViewModel
class KullaniciYoneticisi extends ChangeNotifier {
  final VeritabaniServisi _db = VeritabaniServisi();

  KullaniciModeli _kullanici = KullaniciModeli.varsayilan();
  bool _yuklendi = false;

  KullaniciYoneticisi() {
    yukle();
  }

  KullaniciModeli get kullanici => _kullanici;
  bool get yuklendi => _yuklendi;

  Future<void> yukle() async {
    try {
      final k = await _db.kullaniciGetir();
      _kullanici = k;
      _yuklendi = true;
      notifyListeners();
    } catch (_) {
      _yuklendi = true;
      notifyListeners();
    }
  }

  Future<void> profiliGuncelle({
    String? adSoyad,
    String? eposta,
    bool? epostaBulteniAktif,
  }) async {
    _kullanici = _kullanici.kopyala(
      adSoyad: adSoyad,
      eposta: eposta,
      epostaBulteniAktif: epostaBulteniAktif,
    );
    notifyListeners();

    try {
      await _db.kullaniciKaydet(_kullanici);
    } catch (_) {}
  }
}
