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

  Map<String, dynamic> haritayaDonustur() {
    return {
      'id': id,
      'ad': ad,
      'birim_fiyat': birimFiyat,
      'eski_fiyat': eskiFiyat,
      'adet': adet,
      'gorsel_yolu': gorselYolu,
      'ai_tanidi': yapayZekaIleTanindi ? 1 : 0,
    };
  }

  factory UrunModeli.haritadanOlustur(Map<String, dynamic> harita) {
    return UrunModeli(
      id: harita['id'] as String,
      ad: harita['ad'] as String,
      birimFiyat: (harita['birim_fiyat'] as num).toDouble(),
      eskiFiyat: harita['eski_fiyat'] != null ? (harita['eski_fiyat'] as num).toDouble() : null,
      adet: harita['adet'] as int? ?? 1,
      gorselYolu: harita['gorsel_yolu'] as String?,
      yapayZekaIleTanindi: (harita['ai_tanidi'] as int? ?? 0) == 1,
    );
  }
}
