import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';

/// Renk Körü Modu - Sepet Ekranı (Stitch: renk_k_r_sepetim birebir)
class RenkKoruSepetView extends StatelessWidget {
  final SepetYoneticisi sepet;
  final VoidCallback onUrunEkle;
  final VoidCallback onAlisverisiBitir;

  const RenkKoruSepetView({
    super.key,
    required this.sepet,
    required this.onUrunEkle,
    required this.onAlisverisiBitir,
  });

  @override
  Widget build(BuildContext context) {
    const anaMavi = UygulamaRenkleri.renkKoruMavi; // #0072B2
    const uyariTuruncu = UygulamaRenkleri.renkKoruTuruncu; // #E69F00

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Sepetim [Renk Güvenli]', style: MetinStilleri.baslik2(renk: anaMavi)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.volume_up_rounded, color: anaMavi),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // ⚠️ Çizgili Desenli Bütçe Uyarı Bandı (Renk Körü İçin Özel Tasarım)
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: uyariTuruncu.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: uyariTuruncu, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: uyariTuruncu, size: 32),
                SizedBox(width: Olculer.boslukOrta),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DİKKAT: BÜTÇE LİMİTİ YAKLAŞTI',
                        style: TextStyle(fontWeight: FontWeight.w900, color: uyariTuruncu),
                      ),
                      Text(
                        'Aylık sepet hedefinin %70\'ine ulaştın.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Ürün Listesi (Kalın Mavi Çerçeveli)
          for (final urun in sepet.urunler)
            Container(
              margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: anaMavi, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(urun.ad, style: MetinStilleri.govdeKalin()),
                        Text(
                          '${urun.birimFiyat.toStringAsFixed(2)} ₺ x ${urun.adet} Adet',
                          style: MetinStilleri.aciklama(),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: anaMavi),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => sepet.adetAzalt(urun.id),
                        icon: const Icon(Icons.remove_circle_outline, color: anaMavi),
                      ),
                      Text('${urun.adet}', style: MetinStilleri.govdeKalin()),
                      IconButton(
                        onPressed: () => sepet.adetArtir(urun.id),
                        icon: const Icon(Icons.add_circle, color: anaMavi),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: anaMavi.withValues(alpha: 0.3), width: 2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ödenecek Tutar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${sepet.genelToplam.toStringAsFixed(2)} ₺',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: anaMavi),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukOrta),
              OzelButon(
                metin: 'Alışverişi Bitir ve Fiş Al',
                ikon: Icons.check_circle_outline,
                onPressed: sepet.urunler.isEmpty ? null : onAlisverisiBitir,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
