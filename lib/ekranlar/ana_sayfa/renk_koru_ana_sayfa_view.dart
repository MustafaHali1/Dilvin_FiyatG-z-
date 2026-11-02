import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/profil_yoneticisi.dart';

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
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);

    final anaRenk = palet.primary;
    final ikincilRenk = palet.secondary;
    final uyariRenk = palet.warning;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // Üst Header (Dinamik Palet & Simge Vurgulu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: anaRenk, borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                      child: const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FiyatGöz', style: MetinStilleri.baslik1(renk: anaRenk)),
                        Text('RENK GÜVENLİ ARAYÜZ (${palet.turAdi.toUpperCase()})', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onSesliAsistanAc,
                  icon: const Icon(Icons.mic_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: anaRenk),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Çizgili Bütçe Gösterge Kartı
            Container(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                border: Border.all(color: anaRenk, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: anaRenk.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(Olculer.yariCapTam)),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: anaRenk, size: 16),
                            const SizedBox(width: 4),
                            const Text('Bu Ay Harcanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text('Hedef: ${profil.aylikButce.toStringAsFixed(0)} ₺', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  const Text('3.482,50 ₺', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: Olculer.boslukOrta),
                  // İki Renkli Güvenli Çubuk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                    child: LinearProgressIndicator(
                      value: 0.70,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(anaRenk),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('%70 Dolu [✓ Güvenli]', style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold)),
                      Text('Kalan: +1.517,50 ₺', style: TextStyle(color: uyariRenk, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Renk Körü Büyük Aksiyon Butonu
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              renk: anaRenk,
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
                  decoration: BoxDecoration(border: Border.all(color: anaRenk), borderRadius: BorderRadius.circular(4)),
                  child: Text('2 Fiş Kayıtlı', style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            _RenkKoruFisKarti(
              ad: 'Migros Haftalık Alışveriş',
              market: 'Migros',
              fiyat: '648,75 ₺',
              urunSayisi: 8,
              vurguRengi: anaRenk,
              ikincilRenk: ikincilRenk,
              onTap: onAyarlaraGit,
            ),
            _RenkKoruFisKarti(
              ad: 'BİM Temizlik ve Kahvaltı',
              market: 'BİM',
              fiyat: '342,10 ₺',
              urunSayisi: 4,
              vurguRengi: anaRenk,
              ikincilRenk: ikincilRenk,
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
  final Color vurguRengi;
  final Color ikincilRenk;
  final VoidCallback onTap;

  const _RenkKoruFisKarti({
    required this.ad,
    required this.market,
    required this.fiyat,
    required this.urunSayisi,
    required this.vurguRengi,
    required this.ikincilRenk,
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
        border: Border.all(color: vurguRengi, width: 2), // Kalın çerçeve
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: vurguRengi.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
            ),
            child: Icon(Icons.receipt_long_rounded, color: vurguRengi),
          ),
          const SizedBox(width: Olculer.boslukOrta),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad, style: MetinStilleri.govdeKalin()),
                Row(
                  children: [
                    Text('[$market]', style: TextStyle(fontWeight: FontWeight.bold, color: vurguRengi)),
                    const SizedBox(width: 6),
                    Text('$urunSayisi ürün', style: MetinStilleri.aciklama()),
                  ],
                ),
              ],
            ),
          ),
          Text(fiyat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: vurguRengi),
        ],
      ),
    );
  }
}
