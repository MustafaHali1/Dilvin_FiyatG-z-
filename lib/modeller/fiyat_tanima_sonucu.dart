/// ML Kit OCR ve Fiyat Algoritması çıktısı veri modeli
class FiyatTanimaSonucu {
  final double? tespitEdilenFiyat;
  final List<double> adayFiyatlar;
  final String? tespitEdilenUrunAdi;
  final double guvenSkoru; // 0.0 ile 1.0 arası
  final List<String> tumSatirlar;
  final bool basarili;
  final String? hataMesaji;

  const FiyatTanimaSonucu({
    this.tespitEdilenFiyat,
    this.adayFiyatlar = const [],
    this.tespitEdilenUrunAdi,
    this.guvenSkoru = 0.0,
    this.tumSatirlar = const [],
    required this.basarili,
    this.hataMesaji,
  });

  /// Boş / Başarısız Sonuç
  factory FiyatTanimaSonucu.bos({String? hata}) {
    return FiyatTanimaSonucu(
      tespitEdilenFiyat: null,
      adayFiyatlar: const [],
      tespitEdilenUrunAdi: null,
      guvenSkoru: 0.0,
      tumSatirlar: const [],
      basarili: false,
      hataMesaji: hata ?? 'Etikette fiyat tespit edilemedi.',
    );
  }

  /// Varsayılan test / fallback sonucu
  factory FiyatTanimaSonucu.ornek() {
    return const FiyatTanimaSonucu(
      tespitEdilenFiyat: 24.90,
      adayFiyatlar: [24.90, 29.90],
      tespitEdilenUrunAdi: 'Sütaş Tam Yağlı Süt 1L',
      guvenSkoru: 0.95,
      tumSatirlar: ['Sütaş Tam Yağlı Süt 1L', '24,90 TL', 'Eski: 29,90 TL'],
      basarili: true,
    );
  }

  FiyatTanimaSonucu kopyala({
    double? tespitEdilenFiyat,
    List<double>? adayFiyatlar,
    String? tespitEdilenUrunAdi,
    double? guvenSkoru,
    List<String>? tumSatirlar,
    bool? basarili,
    String? hataMesaji,
  }) {
    return FiyatTanimaSonucu(
      tespitEdilenFiyat: tespitEdilenFiyat ?? this.tespitEdilenFiyat,
      adayFiyatlar: adayFiyatlar ?? this.adayFiyatlar,
      tespitEdilenUrunAdi: tespitEdilenUrunAdi ?? this.tespitEdilenUrunAdi,
      guvenSkoru: guvenSkoru ?? this.guvenSkoru,
      tumSatirlar: tumSatirlar ?? this.tumSatirlar,
      basarili: basarili ?? this.basarili,
      hataMesaji: hataMesaji ?? this.hataMesaji,
    );
  }
}
