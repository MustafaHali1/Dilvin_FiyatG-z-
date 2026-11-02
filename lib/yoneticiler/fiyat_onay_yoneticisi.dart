import 'package:flutter/material.dart';
import '../modeller/fiyat_tanima_sonucu.dart';
import '../servisler/fiyat_tanima_servisi.dart';

/// Fiyat Onay ekranının iş mantığını ve ML Kit OCR durumunu yöneten ViewModel
class FiyatOnayYoneticisi extends ChangeNotifier {
  final FiyatTanimaServisi _ocrServisi = FiyatTanimaServisi();

  bool _yukleniyor = false;
  String? _resimYolu;
  FiyatTanimaSonucu? _sonuc;
  int _adet = 1;
  double? _seciliFiyat;

  late final TextEditingController urunAdiDenetleyici;
  late final TextEditingController fiyatDenetleyici;

  FiyatOnayYoneticisi({String? resimYolu}) {
    urunAdiDenetleyici = TextEditingController();
    fiyatDenetleyici = TextEditingController();
    _resimYolu = resimYolu;

    if (resimYolu != null && resimYolu.isNotEmpty) {
      resimdenTani(resimYolu);
    } else {
      // Resim yoksa (örnek veya boş)
      urunAdiDenetleyici.text = 'Market Ürünü';
      _seciliFiyat = 24.90;
      fiyatDenetleyici.text = '24.90';
    }
  }

  bool get yukleniyor => _yukleniyor;
  String? get resimYolu => _resimYolu;
  FiyatTanimaSonucu? get sonuc => _sonuc;
  int get adet => _adet;
  double? get seciliFiyat => _seciliFiyat;
  List<double> get adayFiyatlar => _sonuc?.adayFiyatlar ?? [];

  /// Görseli ML Kit OCR ile tarar ve alanları otomatik doldurur
  Future<void> resimdenTani(String path, {bool merkezOdakli = true}) async {
    _yukleniyor = true;
    _resimYolu = path;
    notifyListeners();

    try {
      final res = await _ocrServisi.resmiTara(path, merkezOdakli: merkezOdakli);
      _sonuc = res;

      if (res.basarili && res.tespitEdilenFiyat != null) {
        _seciliFiyat = res.tespitEdilenFiyat;
        fiyatDenetleyici.text = res.tespitEdilenFiyat!.toStringAsFixed(2);
      } else {
        _seciliFiyat = null;
        fiyatDenetleyici.text = '';
      }

      if (res.tespitEdilenUrunAdi != null && res.tespitEdilenUrunAdi!.isNotEmpty) {
        urunAdiDenetleyici.text = res.tespitEdilenUrunAdi!;
      } else {
        urunAdiDenetleyici.text = 'Market Ürünü';
      }

      _yukleniyor = false;
      notifyListeners();
    } catch (e) {
      _sonuc = FiyatTanimaSonucu.bos(hata: e.toString());
      _yukleniyor = false;
      notifyListeners();
    }
  }

  /// Kullanıcı aday çiplerinden birine dokunduğunda fiyatı günceller
  void fiyatSec(double yeniFiyat) {
    _seciliFiyat = yeniFiyat;
    fiyatDenetleyici.text = yeniFiyat.toStringAsFixed(2);
    notifyListeners();
  }

  void adetArtir() {
    _adet++;
    notifyListeners();
  }

  void adetAzalt() {
    if (_adet > 1) {
      _adet--;
      notifyListeners();
    }
  }

  /// Onaylanan ürünü sepete göndermek üzere hazırlar
  Map<String, dynamic>? onayVerisiHazirla() {
    final ad = urunAdiDenetleyici.text.trim();
    final hamFiyat = fiyatDenetleyici.text.replaceAll(',', '.').trim();
    final fiyat = double.tryParse(hamFiyat);

    if (ad.isEmpty || fiyat == null || fiyat <= 0) {
      return null;
    }

    return {
      'ad': ad,
      'birimFiyat': fiyat,
      'adet': _adet,
      'resimYolu': _resimYolu,
    };
  }

  @override
  void dispose() {
    urunAdiDenetleyici.dispose();
    fiyatDenetleyici.dispose();
    super.dispose();
  }
}
