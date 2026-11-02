/// Sepete eklenen veya fişte yer alan tek bir ürün
class UrunModeli {
  final String id;
  final String ad;
  final double birimFiyat;
  final double? eskiFiyat; // İndirimli ürünler için
  final int adet;
  final String? gorselYolu;
  final bool yapayZekaIleTanindi;

  const UrunModeli({
    required this.id,
    required this.ad,
    required this.birimFiyat,
    this.eskiFiyat,
    this.adet = 1,
    this.gorselYolu,
    this.yapayZekaIleTanindi = false,
  });

  double get toplamTutar => birimFiyat * adet;
  double get fiyat => birimFiyat;
  bool get indirimliMi => eskiFiyat != null && eskiFiyat! > birimFiyat;

  UrunModeli kopyala({
    String? id,
    String? ad,
    double? birimFiyat,
    double? eskiFiyat,
    int? adet,
    String? gorselYolu,
    bool? yapayZekaIleTanindi,
  }) {
    return UrunModeli(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      eskiFiyat: eskiFiyat ?? this.eskiFiyat,
      adet: adet ?? this.adet,
      gorselYolu: gorselYolu ?? this.gorselYolu,
      yapayZekaIleTanindi: yapayZekaIleTanindi ?? this.yapayZekaIleTanindi,
    );
  }

  Map<String, dynamic> toMap({String? fisId}) {
    return {
      'id': id,
      'fis_id': ?fisId,
      'ad': ad,
      'birim_fiyat': birimFiyat,
      'eski_fiyat': eskiFiyat,
      'adet': adet,
      'gorsel_yolu': gorselYolu,
      'ai_tanidi': yapayZekaIleTanindi ? 1 : 0,
    };
  }

  Map<String, dynamic> haritayaDonustur() => toMap();

  factory UrunModeli.fromMap(Map<String, dynamic> map) {
    return UrunModeli(
      id: map['id'] as String,
      ad: map['ad'] as String,
      birimFiyat: (map['birim_fiyat'] as num).toDouble(),
      eskiFiyat: map['eski_fiyat'] != null ? (map['eski_fiyat'] as num).toDouble() : null,
      adet: map['adet'] as int? ?? 1,
      gorselYolu: map['gorsel_yolu'] as String?,
      yapayZekaIleTanindi: (map['ai_tanidi'] as int? ?? 0) == 1,
    );
  }

  factory UrunModeli.haritadanOlustur(Map<String, dynamic> harita) =>
      UrunModeli.fromMap(harita);
}
