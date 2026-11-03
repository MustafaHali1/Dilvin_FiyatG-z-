import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/profil_modeli.dart';
import '../../modeller/urun_modeli.dart';
import '../../servisler/fis_pdf_servisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../sesli_asistan/sesli_asistan_diyalog_ekrani.dart';
import '../sesli_asistan/sesli_asistan_paneli.dart';
import 'standart_fis_view.dart';
import 'kolay_mod_fis_view.dart';
import 'renk_koru_fis_view.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Fiş tasarımını ekrana getiren dinamik bağlayıcı
class FisDetayEkrani extends StatelessWidget {
  final FisModeli? fis;
  final VoidCallback? onPaylas;
  final VoidCallback? onSesliOku;
  final VoidCallback? onSesliAsistan;

  const FisDetayEkrani({
    super.key,
    this.fis,
    this.onPaylas,
    this.onSesliOku,
    this.onSesliAsistan,
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
        () async {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fiş PDF olarak oluşturuluyor ve paylaşılıyor...')),
          );
          await FisPdfServisi.fisiPdfOlarakPaylas(etkinFis);
        };

    final etkinSesliOku = onSesliOku ??
        () async {
          if (!profil.sesliAsistanAcik) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesli okuma ayarlardan kapalı.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          HapticFeedback.heavyImpact();
          final asistan = SesliAsistanServisi();
          final urunMetni = etkinFis.urunler
              .map((u) => '${u.adet} adet ${u.ad}, ${u.toplamTutar.toStringAsFixed(2)} lira')
              .join('. ');
          final metin =
              '${etkinFis.marketAdi} fişi. Toplam tutar: ${etkinFis.toplamTutar.toStringAsFixed(2)} lira. Alınan ürünler: $urunMetni.';
          await asistan.konus(metin);
        };

    final etkinSesliAsistan = onSesliAsistan ??
        () {
          if (!profil.sesliAsistanAcik) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesli Asistan ayarlardan kapalı.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          if (profil.profilTuru == ProfilTuru.gormeEngelliModu) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SesliAsistanDiyalogEkrani(),
              ),
            );
          } else {
            SesliAsistanPaneli.goster(context);
          }
        };

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
      case ProfilTuru.gormeEngelliModu:
        return KolayModFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
          onSesliAsistan: etkinSesliAsistan,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
          onSesliAsistan: etkinSesliAsistan,
        );
      case ProfilTuru.standart:
        return StandartFisView(
          fis: etkinFis,
          onPaylas: etkinPaylas,
          onSesliOku: etkinSesliOku,
          onSesliAsistan: etkinSesliAsistan,
        );
    }
  }
}
