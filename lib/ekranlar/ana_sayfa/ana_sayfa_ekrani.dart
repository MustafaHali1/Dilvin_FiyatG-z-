import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/bilesenler/ozel_buton.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';
import 'package:fiyatgoz/modeller/urun_modeli.dart';
import 'bilesenler/butce_ozet_karti.dart';
import 'bilesenler/fis_karti.dart';

/// Ana Sayfa (Tasarim sistemine tam uyumlu temiz ekran)
class AnaSayfaEkrani extends StatelessWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;

  const AnaSayfaEkrani({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
  });

  @override
  Widget build(BuildContext context) {
    final ornekFisler = [
      FisModeli(
        id: '1',
        aciklama: 'Migros Haftalık Alışveriş',
        marketAdi: 'Migros',
        tarih: DateTime.now(),
        urunler: [
          const UrunModeli(id: '1', ad: 'Süt', birimFiyat: 24.90, adet: 2),
        ],
      ),
      FisModeli(
        id: '2',
        aciklama: 'BİM Temizlik ve Kahvaltı',
        marketAdi: 'BİM',
        tarih: DateTime.now().subtract(const Duration(days: 3)),
        urunler: [
          const UrunModeli(id: '2', ad: 'Peynir', birimFiyat: 148.70, adet: 1),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Merhaba 👋', style: MetinStilleri.baslik1()),
                    const SizedBox(height: 2),
                    Text(
                      'Alışveriş harcamalarını kolayca takip et',
                      style: MetinStilleri.aciklama(),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),
            const ButceOzetKarti(
              harcanan: 3482.50,
              butce: 5000.00,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              onPressed: onKameraAc,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Geçmiş Fişler', style: MetinStilleri.baslik2()),
                Text('Tümünü Gör', style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu)),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),
            for (final fis in ornekFisler) FisKarti(fis: fis),
          ],
        ),
      ),
    );
  }
}
