import 'package:flutter/material.dart';
import '../modeller/fis_modeli.dart';
import '../modeller/urun_modeli.dart';
import '../servisler/veritabani_servisi.dart';

/// Alışveriş fişlerini ve bütçe/tasarruf istatistiklerini SQLite üzerinden yöneten ViewModel
class FisYoneticisi extends ChangeNotifier {
  final VeritabaniServisi _db = VeritabaniServisi();

  List<FisModeli> _fisler = [];
  bool _yukleniyor = true;
  double _buAyHarcama = 0.0;
  double _toplamTasarruf = 0.0;

  FisYoneticisi() {
    verileriYukle();
  }

  List<FisModeli> get fisler => List.unmodifiable(_fisler);
  bool get yukleniyor => _yukleniyor;
  double get buAyHarcama => _buAyHarcama;
  double get toplamTasarruf => _toplamTasarruf;
  int get fisSayisi => _fisler.length;

  /// Son 7 günde yapılan toplam harcama tutarı
  double get buHaftaHarcama {
    final yediGunOnce = DateTime.now().subtract(const Duration(days: 7));
    return _fisler
        .where((f) => f.tarih.isAfter(yediGunOnce))
        .fold(0.0, (toplam, f) => toplam + f.toplamTutar);
  }

  /// Son 7 günün fişleri
  List<FisModeli> get buHaftaninFisleri {
    final yediGunOnce = DateTime.now().subtract(const Duration(days: 7));
    return _fisler.where((f) => f.tarih.isAfter(yediGunOnce)).toList();
  }

  /// Veritabanındaki tüm fişleri ve aylık/tasarruf istatistiklerini yükler
  Future<void> verileriYukle() async {
    _yukleniyor = true;
    notifyListeners();

    try {
      final fisler = await _db.tumFisleriGetir();
      final buAy = await _db.buAykiToplamHarcama();
      final tasarruf = await _db.toplamTasarruf();

      _fisler = fisler;
      _buAyHarcama = buAy;
      _toplamTasarruf = tasarruf;
      _yukleniyor = false;
      notifyListeners();
    } catch (_) {
      _yukleniyor = false;
      notifyListeners();
    }
  }

  /// Sepetteki ürünlerden yeni bir fiş oluşturup SQLite veritabanına kaydeder
  Future<FisModeli> sepettenFisOlusturVeKaydet({
    required List<UrunModeli> urunler,
    String? marketAdi,
    String? aciklama,
  }) async {
    final rastgeleNo = (DateTime.now().millisecondsSinceEpoch % 90000) + 10000;
    final fisId = 'FG-$rastgeleNo';

    final yeniFis = FisModeli(
      id: fisId,
      marketAdi: marketAdi ?? 'Migros Jet',
      aciklama: aciklama ?? 'Alışveriş Fişi',
      tarih: DateTime.now(),
      urunler: List<UrunModeli>.from(urunler),
    );

    await _db.fisEkle(yeniFis);
    await verileriYukle();
    return yeniFis;
  }

  /// Tek bir fişi siler
  Future<void> fisSil(String id) async {
    await _db.fisSil(id);
    await verileriYukle();
  }

  /// Tüm fiş geçmişini temizler
  Future<void> tumFisleriTemizle() async {
    await _db.tumFisleriSil();
    await verileriYukle();
  }
}
