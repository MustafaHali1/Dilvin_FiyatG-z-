import 'dart:ui';

/// OCR tarafından okunan her bir satırın metnini ve koordinat kutusunu temsil eder
class MetinSatirKutusu {
  final String metin;
  final Rect kutu;

  const MetinSatirKutusu({
    required this.metin,
    required this.kutu,
  });

  double get yukseklik => kutu.height;
  double get genislik => kutu.width;
  double get alan => kutu.width * kutu.height;
  double get merkezX => kutu.left + (kutu.width / 2);
  double get merkezY => kutu.top + (kutu.height / 2);
}
