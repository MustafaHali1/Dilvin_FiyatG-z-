import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/fis_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';

/// Renk Körü Modu - Fiş Görünümü (Stitch: renk_k_r_fi_g_r_n_m birebir)
class RenkKoruFisView extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;
  final VoidCallback onSesliAsistan;

  const RenkKoruFisView({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
    required this.onSesliAsistan,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);
    final anaRenk = palet.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Fiş Detayı [${palet.turAdi}]', style: MetinStilleri.baslik2(renk: anaRenk)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: anaRenk),
        actions: [
          IconButton(
            tooltip: 'Sesli Asistan',
            onPressed: onSesliAsistan,
            icon: Icon(Icons.mic_rounded, color: anaRenk),
          ),
          IconButton(
            tooltip: 'Paylaş',
            onPressed: onPaylas,
            icon: Icon(Icons.share_rounded, color: anaRenk),
          ),
          IconButton(
            tooltip: 'Sesli Oku',
            onPressed: onSesliOku,
            icon: Icon(Icons.volume_up_rounded, color: anaRenk),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        child: Container(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            border: Border.all(color: anaRenk, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: anaRenk, size: 28),
                  const SizedBox(width: 8),
                  Text('FİYATGÖZ ALIŞVERİŞ FİŞİ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: anaRenk)),
                ],
              ),
              Divider(height: 32, thickness: 1.5, color: anaRenk),
              for (final urun in fis.urunler)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${urun.ad} x${urun.adet}', style: MetinStilleri.govdeKalin()),
                      Text('${urun.toplamTutar.toStringAsFixed(2)} ₺', style: TextStyle(fontWeight: FontWeight.bold, color: anaRenk)),
                    ],
                  ),
                ),
              Divider(height: 32, thickness: 1.5, color: anaRenk),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ÖDENECEK:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${fis.toplamTutar.toStringAsFixed(2)} ₺', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: anaRenk)),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              OzelButon(
                metin: 'PDF Paylaş / Kaydet',
                ikon: Icons.share_rounded,
                renk: anaRenk,
                onPressed: onPaylas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
