import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import 'standart_sepet_view.dart';
import 'kolay_mod_sepet_view.dart';
import 'renk_koru_sepet_view.dart';
import 'gorme_engelli_sepet_view.dart';
import '../kamera/kamera_tarayici_ekrani.dart';
import '../fis_detay/fis_detay_ekrani.dart';

/// Kullanıcının seçtiği profile göre birebir Stitch Sepet tasarımını getiren dinamik ekran
class SepetEkrani extends StatelessWidget {
  final VoidCallback? onUrunEkle;
  final VoidCallback? onAlisverisiBitir;

  const SepetEkrani({
    super.key,
    this.onUrunEkle,
    this.onAlisverisiBitir,
  });

  @override
  Widget build(BuildContext context) {
    final sepet = context.watch<SepetYoneticisi>();
    final profil = context.watch<ProfilYoneticisi>().profil;

    final varsayilanUrunEkle = onUrunEkle ??
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => KameraTarayiciEkrani(
                onFotoCekildi: (_) {},
                onKapat: () => Navigator.maybePop(ctx),
              ),
            ),
          );
        };

    final varsayilanAlisverisiBitir = onAlisverisiBitir ??
        () async {
          if (sepet.urunler.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sepetiniz boş. Fiş oluşturmak için ürün ekleyin.')),
            );
            return;
          }
          final fisYoneticisi = context.read<FisYoneticisi>();
          final yeniFis = await fisYoneticisi.sepettenFisOlusturVeKaydet(
            urunler: sepet.urunler,
            marketAdi: 'Migros Jet',
            aciklama: 'Haftalık Alışveriş Fişi',
          );
          sepet.sepetiBosalt();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => FisDetayEkrani(fis: yeniFis),
              ),
            );
          }
        };

    switch (profil.profilTuru) {
      case ProfilTuru.kolayMod:
        return KolayModSepetView(
          sepet: sepet,
          onUrunEkle: varsayilanUrunEkle,
          onAlisverisiBitir: varsayilanAlisverisiBitir,
        );
      case ProfilTuru.renkKoruModu:
        return RenkKoruSepetView(
          sepet: sepet,
          onUrunEkle: varsayilanUrunEkle,
          onAlisverisiBitir: varsayilanAlisverisiBitir,
        );
      case ProfilTuru.gormeEngelliModu:
        return const GormeEngelliSepetView();
      case ProfilTuru.standart:
        return StandartSepetView(
          sepet: sepet,
          onUrunEkle: varsayilanUrunEkle,
          onAlisverisiBitir: varsayilanAlisverisiBitir,
        );
    }
  }
}
