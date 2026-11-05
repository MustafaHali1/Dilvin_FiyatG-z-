import 'package:flutter/material.dart';
import '../modeller/fiyat_tanima_sonucu.dart';
import '../servisler/fiyat_tanima_servisi.dart';
import '../servisler/sesli_asistan_servisi.dart';
import '../servisler/sesli_komut_servisi.dart';

/// Fiyat Onay ekranının iş mantığını, ML Kit OCR durumunu ve Normal Mod Sesli Asistanını yöneten ViewModel
class FiyatOnayYoneticisi extends ChangeNotifier {
  final FiyatTanimaServisi _ocrServisi = FiyatTanimaServisi();
  final SesliAsistanServisi _asistan = SesliAsistanServisi();
  final SesliKomutServisi _komutServisi = SesliKomutServisi();

  bool _yukleniyor = false;
  String? _resimYolu;
  FiyatTanimaSonucu? _sonuc;
  int _adet = 1;
  double? _seciliFiyat;
  bool _dinleniyor = false;

  late final TextEditingController urunAdiDenetleyici;
  late final TextEditingController fiyatDenetleyici;

  FiyatOnayYoneticisi({String? resimYolu, bool otomatikSeslendir = true}) {
    urunAdiDenetleyici = TextEditingController();
    fiyatDenetleyici = TextEditingController();
    _resimYolu = resimYolu;

    if (resimYolu != null && resimYolu.isNotEmpty) {
      resimdenTani(resimYolu, sesliBildir: otomatikSeslendir);
    } else {
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
  bool get dinleniyor => _dinleniyor;

  /// Görseli ML Kit OCR ile tarar, alanları doldurur ve sesli okur
  Future<void> resimdenTani(
    String path, {
    bool merkezOdakli = true,
    bool sesliBildir = true,
  }) async {
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

      if (sesliBildir && res.basarili && res.tespitEdilenFiyat != null) {
        final ad = urunAdiDenetleyici.text;
        final f = res.tespitEdilenFiyat!.toStringAsFixed(2).replaceAll('.', ' lira ');
        await _asistan.konus('$ad, $f kuruş.');
      }
    } catch (e) {
      _sonuc = FiyatTanimaSonucu.bos(hata: e.toString());
      _yukleniyor = false;
      notifyListeners();
    }
  }

  /// Normal modda sesli asistanı dinletir ("2 adet", "sepete ekle", "iptal")
  Future<void> sesliKomutDinle({
    required VoidCallback onOnayla,
    required VoidCallback onIptal,
  }) async {
    _dinleniyor = true;
    notifyListeners();

    await _asistan.dinle(
      onSonuc: (metin, sonMu) async {
        if (sonMu && metin.isNotEmpty) {
          _dinleniyor = false;
          notifyListeners();

          final komut = await _komutServisi.niyetCozAkilli(metin);
          switch (komut.tur) {
            case KomutTuru.adetBelirle:
              if (komut.adet != null) {
                _adet = komut.adet!;
                notifyListeners();
                _asistan.titret(TitresimTuru.secim);
                await _asistan.konus('$_adet adet olarak güncellendi.');
              }
              break;
            case KomutTuru.sepeteEkle:
              _asistan.titret(TitresimTuru.basari);
              onOnayla();
              break;
            case KomutTuru.iptal:
              _asistan.titret(TitresimTuru.hafif);
              onIptal();
              break;
            default:
              await _asistan.konus('Anlayamadım. "Sepete ekle" veya "2 adet" diyebilirsiniz.');
              break;
          }
        }
      },
    );
  }

  /// Kullanıcı aday çiplerinden birine dokunduğunda fiyatı günceller
  void fiyatSec(double yeniFiyat) {
    _seciliFiyat = yeniFiyat;
    fiyatDenetleyici.text = yeniFiyat.toStringAsFixed(2);
    _asistan.titret(TitresimTuru.secim);
    notifyListeners();
  }

  void adetArtir() {
    _adet++;
    _asistan.titret(TitresimTuru.hafif);
    notifyListeners();
  }

  void adetAzalt() {
    if (_adet > 1) {
      _adet--;
      _asistan.titret(TitresimTuru.hafif);
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
    _asistan.durdur();
    urunAdiDenetleyici.dispose();
    fiyatDenetleyici.dispose();
    super.dispose();
  }
}
