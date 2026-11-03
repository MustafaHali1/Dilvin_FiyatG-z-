import 'package:flutter/material.dart';
import '../modeller/urun_modeli.dart';

/// Alışveriş sepetini ve canlı toplam hesabını yöneten ViewModel
class SepetYoneticisi extends ChangeNotifier {
  final List<UrunModeli> _urunler = [];

  List<UrunModeli> get urunler => List.unmodifiable(_urunler);

  double get araToplam =>
      _urunler.fold(0.0, (toplam, urun) => toplam + urun.toplamTutar);

  double get genelToplam => araToplam;
  double get toplamTutar => genelToplam;

  int get urunCesitSayisi => _urunler.length;
  int get toplamUrunAdedi =>
      _urunler.fold(0, (toplam, urun) => toplam + urun.adet);

  void urunEkle(UrunModeli yeniUrun) {
    _urunler.add(yeniUrun);
    notifyListeners();
  }

  void adetArtir(String urunId) {
    final index = _urunler.indexWhere((u) => u.id == urunId);
    if (index != -1) {
      final urun = _urunler[index];
      _urunler[index] = urun.kopyala(adet: urun.adet + 1);
      notifyListeners();
    }
  }

  void adetAzalt(String urunId) {
    final index = _urunler.indexWhere((u) => u.id == urunId);
    if (index != -1) {
      final urun = _urunler[index];
      if (urun.adet > 1) {
        _urunler[index] = urun.kopyala(adet: urun.adet - 1);
      } else {
        _urunler.removeAt(index);
      }
      notifyListeners();
    }
  }

  void urunSil(String urunId) {
    _urunler.removeWhere((u) => u.id == urunId);
    notifyListeners();
  }

  void sepetiBosalt() {
    _urunler.clear();
    notifyListeners();
  }

  void sepetiTemizle() => sepetiBosalt();
}
