import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'package:flutter/services.dart';
import '../../modeller/urun_modeli.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import 'standart_fis_view.dart';
import 'kolay_mod_fis_view.dart';
import 'renk_koru_fis_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Fiş tasarımını ekrana getiren dinamik bağlayıcı
class FisDetayEkrani extends StatelessWidget {
  final FisModeli? fis;
  final VoidCallback? onPaylas;
  final VoidCallback? onSesliOku;

  const FisDetayEkrani({
    super.key,
    this.fis,
    this.onPaylas,
    this.onSesliOku,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final sepet = context.watch<SepetYoneticisi>();

    final etkinFis = fis ??
        FisModeli(
          id: 'FIS-10492',
          aciklama: 'Migros Haftalık Alışveriş',
          marketAdi: 'Migros Jet - Kadıköy',
          tarih: DateTime.now(),
          urunler: sepet.urunler.isNotEmpty
              ? sepet.urunler
              : [
                  const UrunModeli(id: '1', ad: 'Sütaş Tam Yağlı Süt 1L', birimFiyat: 24.90),
                  const UrunModeli(id: '2', ad: 'Ekmek 200g', birimFiyat: 10.00),
                  const UrunModeli(id: '3', ad: 'Pınar Süzme Peynir 500g', birimFiyat: 63.50),
                ],
        );

    final etkinPaylas = onPaylas ??
        () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fiş PDF olarak dışa aktarıldı ve paylaşıldı.')),
          );
        };

    final etkinSesliOku = onSesliOku ??
        () {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFFFD600),
              content: Text(
                'Fiş okunuyor: ${etkinFis.magazaAdi}, Toplam Tutar: ${etkinFis.toplamTutar.toStringAsFixed(2)} TL. ${etkinFis.urunler.length} kalem ürün alındı.',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        };

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
      case ProfilTuru.gormeEngelliModu:
        return KolayModFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
        );
      case ProfilTuru.standart:
        return StandartFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
        );
    }
  }
}
