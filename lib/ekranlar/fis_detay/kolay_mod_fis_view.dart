import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../modeller/fis_modeli.dart';

/// Kolay Mod - Fiş Görünümü (Stitch: kolay_mod_fi_g_r_n_m_dijital_fi birebir)
class KolayModFisView extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;
  final VoidCallback onSesliAsistan;

  const KolayModFisView({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
    required this.onSesliAsistan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('DİJİTAL FİŞ', style: MetinStilleri.kolayModBaslik()),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sesli Asistan',
            onPressed: onSesliAsistan,
            icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.kolayModSari, size: 30),
          ),
          IconButton(
            tooltip: 'Sesli Oku',
            onPressed: onSesliOku,
            icon: const Icon(Icons.volume_up_rounded, color: UygulamaRenkleri.kolayModSari, size: 30),
          ),
          IconButton(
            tooltip: 'Paylaş',
            onPressed: onPaylas,
            icon: const Icon(Icons.share_rounded, color: UygulamaRenkleri.kolayModSari, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        child: Container(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
            border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.receipt_rounded, size: 54, color: UygulamaRenkleri.kolayModSari),
                    const SizedBox(height: 8),
                    Text(
                      'FİYATGÖZ FİŞİ',
                      style: MetinStilleri.kolayModBaslik(renk: UygulamaRenkleri.kolayModSari),
                    ),
                    Text(
                      'Tarih: ${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year}',
                      style: MetinStilleri.govde(renk: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Divider(height: 36, thickness: 2, color: Colors.white24),

              // Kalemler
              for (final urun in fis.urunler)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${urun.ad} (x${urun.adet})',
                          style: MetinStilleri.kolayModGovde(),
                        ),
                      ),
                      Text(
                        '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.kolayModBaslik(renk: UygulamaRenkleri.kolayModSari),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 36, thickness: 2, color: Colors.white24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOPLAM:', style: MetinStilleri.kolayModBaslik()),
                  Text(
                    '${fis.toplamTutar.toStringAsFixed(2)} ₺',
                    style: MetinStilleri.kolayModDev(),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukCokBuyuk),

              // 2 Devasa Buton
              SizedBox(
                height: 72,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSesliOku,
                  icon: const Icon(Icons.volume_up, color: Colors.black, size: 30),
                  label: const Text('FİŞİ BAŞTAN SONA OKU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari),
                ),
              ),
              const SizedBox(height: Olculer.boslukOrta),
              SizedBox(
                height: 72,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPaylas,
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  label: const Text('FİŞİ KAYDET / PAYLAŞ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
