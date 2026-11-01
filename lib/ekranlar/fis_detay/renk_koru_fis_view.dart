import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/fis_modeli.dart';

/// Renk Körü Modu - Fiş Görünümü (Stitch: renk_k_r_fi_g_r_n_m birebir)
class RenkKoruFisView extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;

  const RenkKoruFisView({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
  });

  @override
  Widget build(BuildContext context) {
    const anaMavi = UygulamaRenkleri.renkKoruMavi;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Fiş Detayı [Renk Güvenli]', style: MetinStilleri.baslik2(renk: anaMavi)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        child: Container(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            border: Border.all(color: anaMavi, width: 2),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: anaMavi, size: 28),
                  SizedBox(width: 8),
                  Text('FİYATGÖZ ALIŞVERİŞ FİŞİ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: anaMavi)),
                ],
              ),
              const Divider(height: 32, thickness: 1.5, color: anaMavi),
              for (final urun in fis.urunler)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${urun.ad} x${urun.adet}', style: MetinStilleri.govdeKalin()),
                      Text('${urun.toplamTutar.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold, color: anaMavi)),
                    ],
                  ),
                ),
              const Divider(height: 32, thickness: 1.5, color: anaMavi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ÖDENECEK:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${fis.toplamTutar.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: anaMavi)),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              OzelButon(
                metin: 'PDF Paylaş / Kaydet',
                ikon: Icons.share_rounded,
                onPressed: onPaylas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
