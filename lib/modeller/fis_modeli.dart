import 'urun_modeli.dart';

/// Kaydedilen bir alışveriş fişi modeli
class FisModeli {
  final String id;
  final String aciklama;
  final String marketAdi;
  final DateTime tarih;
  final List<UrunModeli> urunler;
  final double? ozelToplamTutar;
  final double? ozelToplamIndirim;

  const FisModeli({
    required this.id,
    required this.aciklama,
    this.marketAdi = 'Market',
    required this.tarih,
    required this.urunler,
    this.ozelToplamTutar,
    this.ozelToplamIndirim,
  });

  String get magazaAdi => marketAdi;

  double get toplamTutar {
    if (ozelToplamTutar != null) return ozelToplamTutar!;
    return urunler.fold(0.0, (toplam, urun) => toplam + urun.toplamTutar);
  }

  double get toplamIndirim {
    if (ozelToplamIndirim != null) return ozelToplamIndirim!;
    return urunler.fold(
      0.0,
      (toplam, urun) =>
          toplam +
          (urun.indirimliMi && urun.eskiFiyat != null
              ? (urun.eskiFiyat! - urun.birimFiyat) * urun.adet
              : 0.0),
    );
  }

  int get toplamUrunAdedi =>
      urunler.fold(0, (toplam, urun) => toplam + urun.adet);

  FisModeli kopyala({
    String? id,
    String? aciklama,
    String? marketAdi,
    DateTime? tarih,
    List<UrunModeli>? urunler,
    double? ozelToplamTutar,
    double? ozelToplamIndirim,
  }) {
    return FisModeli(
      id: id ?? this.id,
      aciklama: aciklama ?? this.aciklama,
      marketAdi: marketAdi ?? this.marketAdi,
      tarih: tarih ?? this.tarih,
      urunler: urunler ?? this.urunler,
      ozelToplamTutar: ozelToplamTutar ?? this.ozelToplamTutar,
      ozelToplamIndirim: ozelToplamIndirim ?? this.ozelToplamIndirim,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'market_adi': marketAdi,
      'aciklama': aciklama,
      'tarih': tarih.toIso8601String(),
      'toplam_tutar': toplamTutar,
      'toplam_indirim': toplamIndirim,
    };
  }

  Map<String, dynamic> haritayaDonustur() => toMap();

  factory FisModeli.fromMap(
    Map<String, dynamic> map, {
    List<UrunModeli> urunler = const [],
  }) {
    return FisModeli(
      id: map['id'] as String,
      marketAdi: map['market_adi'] as String? ?? 'Market',
      aciklama: map['aciklama'] as String? ?? '',
      tarih: map['tarih'] != null
          ? DateTime.tryParse(map['tarih'] as String) ?? DateTime.now()
          : DateTime.now(),
      urunler: urunler,
      ozelToplamTutar: (map['toplam_tutar'] as num?)?.toDouble(),
      ozelToplamIndirim: (map['toplam_indirim'] as num?)?.toDouble(),
    );
  }
}
