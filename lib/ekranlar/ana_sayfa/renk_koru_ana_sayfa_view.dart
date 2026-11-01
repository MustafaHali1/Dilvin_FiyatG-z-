import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';

/// Renk Körü Modu - Ana Sayfa (Stitch: renk_k_r_ana_sayfa birebir)
class RenkKoruAnaSayfaView extends StatelessWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const RenkKoruAnaSayfaView({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  Widget build(BuildContext context) {
    const anaMavi = UygulamaRenkleri.renkKoruMavi; // #0072B2
    const uyariTuruncu = UygulamaRenkleri.renkKoruTuruncu; // #E69F00

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // Üst Header (Mavi & Simge Vurgulu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: anaMavi, borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                      child: const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FiyatGöz', style: MetinStilleri.baslik1(renk: anaMavi)),
                        Text('RENK GÜVENLİ ARAYÜZ (DEUTERANOPI)', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onSesliAsistanAc,
                  icon: const Icon(Icons.mic_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: anaMavi),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Mavi & Çizgili Bütçe Gösterge Kartı
            Container(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                border: Border.all(color: anaMavi, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: anaMavi.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(Olculer.yariCapTam)),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: anaMavi, size: 16),
                            SizedBox(width: 4),
                            Text('Bu Ay Harcanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Text('Hedef: 5.000 ₺', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  const Text('3.482,50 ₺', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: Olculer.boslukOrta),
                  // Zebra Çizgili / İki Renkli Güvenli Çubuk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                    child: LinearProgressIndicator(
                      value: 0.70,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(anaMavi),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('%70 Dolu [✓ Güvenli]', style: TextStyle(color: anaMavi, fontWeight: FontWeight.bold)),
                      Text('Kalan: +1.517,50 ₺', style: TextStyle(color: uyariTuruncu, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Mavi Renk Körü Büyük Buton
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              onPressed: onKameraAc,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Geçmiş Fişler (Her kartta ikon ve kalın kenarlık)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Geçmiş Fişler', style: MetinStilleri.baslik2()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(border: Border.all(color: anaMavi), borderRadius: BorderRadius.circular(4)),
                  child: const Text('2 Fiş Kayıtlı', style: TextStyle(color: anaMavi, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            _RenkKoruFisKarti(
              ad: 'Migros Haftalık Alışveriş',
              market: 'Migros',
              fiyat: '648,75 ₺',
              urunSayisi: 8,
              onTap: onAyarlaraGit,
            ),
            _RenkKoruFisKarti(
              ad: 'BİM Temizlik ve Kahvaltı',
              market: 'BİM',
              fiyat: '342,10 ₺',
              urunSayisi: 4,
              onTap: onAyarlaraGit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RenkKoruFisKarti extends StatelessWidget {
  final String ad;
  final String market;
  final String fiyat;
  final int urunSayisi;
  final VoidCallback onTap;

  const _RenkKoruFisKarti({
    required this.ad,
    required this.market,
    required this.fiyat,
    required this.urunSayisi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
      padding: const EdgeInsets.all(Olculer.boslukOrta),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(color: UygulamaRenkleri.renkKoruMavi, width: 2), // Kalın çerçeve
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UygulamaRenkleri.renkKoruMavi.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: UygulamaRenkleri.renkKoruMavi),
          ),
          const SizedBox(width: Olculer.boslukOrta),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad, style: MetinStilleri.govdeKalin()),
                Row(
                  children: [
                    Text('[$market]', style: const TextStyle(fontWeight: FontWeight.bold, color: UygulamaRenkleri.renkKoruMavi)),
                    const SizedBox(width: 6),
                    Text('$urunSayisi ürün', style: MetinStilleri.aciklama()),
                  ],
                ),
              ],
            ),
          ),
          Text(fiyat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: UygulamaRenkleri.renkKoruMavi),
        ],
      ),
    );
  }
}
