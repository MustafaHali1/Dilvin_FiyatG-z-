import 'dart:io';
import 'package:image/image.dart' as img;

/// Çekilen tam ekran fotoğrafı doğrudan hedef kutusunun sınırlarına göre fiziksel olarak kırpan servis
class ResimKirpmaServisi {
  /// Görseli merkezdeki hedef kutusuna göre jilet gibi kırpar (Crop)
  /// [oransalGenislik]: Hedef kutusunun genişlik oranı (%75)
  /// [oransalYukseklik]: Hedef kutusunun yükseklik oranı (%38)
  static Future<String> hedefKutusunuKirp(
    String kaynakYol, {
    double oransalGenislik = 0.75,
    double oransalYukseklik = 0.38,
  }) async {
    try {
      final dosya = File(kaynakYol);
      if (!await dosya.exists()) return kaynakYol;

      final dosyaBytes = await dosya.readAsBytes();
      final orijinalResim = img.decodeImage(dosyaBytes);
      if (orijinalResim == null) return kaynakYol;

      final genislik = orijinalResim.width;
      final yukseklik = orijinalResim.height;

      // Kırpılacak kutunun boyutları
      final kirpmaGenislik = (genislik * oransalGenislik).round();
      final kirpmaYukseklik = (yukseklik * oransalYukseklik).round();

      // Tam merkezleme koordinatları
      final kirpmaX = ((genislik - kirpmaGenislik) / 2).round().clamp(0, genislik);
      final kirpmaY = ((yukseklik - kirpmaYukseklik) / 2).round().clamp(0, yukseklik);

      // Fiziksel kırpma
      final kirpilmisResim = img.copyCrop(
        orijinalResim,
        x: kirpmaX,
        y: kirpmaY,
        width: kirpmaGenislik,
        height: kirpmaYukseklik,
      );

      final yeniYol = kaynakYol.replaceAll('.jpg', '_kirpilmis.jpg');
      final yeniDosya = File(yeniYol);
      await yeniDosya.writeAsBytes(img.encodeJpg(kirpilmisResim, quality: 92));

      return yeniYol;
    } catch (_) {
      // Hata durumunda güvenli fallback
      return kaynakYol;
    }
  }
}
