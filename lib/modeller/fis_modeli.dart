import 'urun_modeli.dart';

/// Kaydedilen bir alışveriş fişi modeli
class FisModeli {
  final String id;
  final String aciklama;
  final String marketAdi;
  final DateTime tarih;
  final List<UrunModeli> urunler;

  const FisModeli({
    required this.id,
    required this.aciklama,
    this.marketAdi = 'Market',
    required this.tarih,
    required this.urunler,
  });

  double get toplamTutar =>
      urunler.fold(0.0, (toplam, urun) => toplam + urun.toplamTutar);

  int get toplamUrunAdedi =>
      urunler.fold(0, (toplam, urun) => toplam + urun.adet);

  Map<String, dynamic> haritayaDonustur() {
    return {
      'id': id,
      'aciklama': aciklama,
      'market_adi': marketAdi,
      'tarih': tarih.toIso8601String(),
      'toplam_tutar': toplamTutar,
    };
  }
}
