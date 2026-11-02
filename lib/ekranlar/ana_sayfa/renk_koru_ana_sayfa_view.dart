import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../fis_detay/fis_detay_ekrani.dart';

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
    final fisYoneticisi = context.watch<FisYoneticisi>();

    final anaRenk = palet.primary;
    final ikincilRenk = palet.secondary;
    final uyariRenk = palet.warning;

    final harcanan = fisYoneticisi.buAyHarcama;
    final butce = profil.aylikButce;
    final yuzde = butce > 0 ? (harcanan / butce) : 0.0;
    final kalan = butce - harcanan;

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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const KullaniciProfiliEkrani()),
                        );
                      },
                      icon: const Icon(Icons.person_rounded, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: anaRenk),
                      tooltip: 'Kullanıcı Profili',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onSesliAsistanAc,
                      icon: const Icon(Icons.mic_rounded, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: anaRenk),
                    ),
                  ],
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
                      Text('Hedef: ${butce.toStringAsFixed(0)} ₺', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  Text('${harcanan.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: Olculer.boslukOrta),
                  // İki Renkli Güvenli Çubuk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                    child: LinearProgressIndicator(
                      value: yuzde.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(anaRenk),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('%${(yuzde * 100).toStringAsFixed(0)} Dolu [✓ Güvenli]', style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold)),
                      Text('Kalan: ${kalan >= 0 ? "+" : ""}${kalan.toStringAsFixed(2)} ₺', style: TextStyle(color: uyariRenk, fontWeight: FontWeight.bold)),
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
                  child: Text('${fisYoneticisi.fisSayisi} Fiş Kayıtlı', style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            if (fisYoneticisi.fisler.isEmpty)
              Container(
                padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  border: Border.all(color: anaRenk, width: 1.5),
                ),
                child: Center(
                  child: Text('Kayıtlı fiş bulunmuyor.', style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold)),
                ),
              )
            else
              for (final fis in fisYoneticisi.fisler)
                _RenkKoruFisKarti(
                  ad: fis.aciklama,
                  market: fis.marketAdi,
                  fiyat: '${fis.toplamTutar.toStringAsFixed(2)} ₺',
                  urunSayisi: fis.toplamUrunAdedi,
                  vurguRengi: anaRenk,
                  ikincilRenk: ikincilRenk,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FisDetayEkrani(fis: fis)),
                    );
                  },
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
      child: Container(
        margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
        padding: const EdgeInsets.all(Olculer.boslukOrta),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
          border: Border.all(color: vurguRengi, width: 2), // Kalın kenarlıkla garanti görünürlük
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: vurguRengi.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                border: Border.all(color: vurguRengi),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: vurguRengi),
            ),
            const SizedBox(width: Olculer.boslukOrta),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad, style: MetinStilleri.govdeKalin(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: ikincilRenk.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(market, style: TextStyle(color: ikincilRenk, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text('$urunSayisi ürün', style: MetinStilleri.aciklama()),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fiyat, style: MetinStilleri.fiyat(boyut: 18, renk: vurguRengi)),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
