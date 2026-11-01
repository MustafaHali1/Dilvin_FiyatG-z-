import 'package:flutter/material.dart';
import '../modeller/urun_modeli.dart';

/// Alışveriş sepetini ve canlı toplam hesabını yöneten ViewModel
class SepetYoneticisi extends ChangeNotifier {
  final List<UrunModeli> _urunler = [
    // Stitch tasarımındaki birebir sahte veriler
    const UrunModeli(
      id: '1',
      ad: 'Sütaş Tam Yağlı Süt 1L',
      birimFiyat: 24.90,
      eskiFiyat: 29.90,
      adet: 2,
      yapayZekaIleTanindi: true,
    ),
    const UrunModeli(
      id: '2',
      ad: 'Halk Ekmek 250g',
      birimFiyat: 8.00,
      adet: 3,
    ),
    const UrunModeli(
      id: '3',
      ad: 'Gezen Tavuk Yumurtası 10\'lu',
      birimFiyat: 64.90,
      adet: 1,
    ),
    const UrunModeli(
      id: '4',
      ad: 'Ezine Beyaz Peynir 500g',
      birimFiyat: 148.70,
      adet: 1,
    ),
  ];

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
