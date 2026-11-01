import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/fiyat_etiketi.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import 'bilesenler/sepet_urun_karti.dart';

/// Standart Mod - Sepet Ekranı (Stitch: sepetim_standart_mod birebir)
class StandartSepetView extends StatelessWidget {
  final SepetYoneticisi sepet;
  final VoidCallback onUrunEkle;
  final VoidCallback onAlisverisiBitir;

  const StandartSepetView({
    super.key,
    required this.sepet,
    required this.onUrunEkle,
    required this.onAlisverisiBitir,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Alışveriş Sepeti (${sepet.toplamUrunAdedi} Ürün)', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.volume_up_rounded, color: UygulamaRenkleri.anaKoyu),
            tooltip: 'Toplamı Sesli Oku',
          ),
        ],
      ),
      body: sepet.urunler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: UygulamaRenkleri.griYazi),
                  const SizedBox(height: Olculer.boslukOrta),
                  Text('Sepetiniz henüz boş', style: MetinStilleri.baslik2()),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text('Fiyat okutarak ürün eklemeye başlayın', style: MetinStilleri.aciklama()),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              itemCount: sepet.urunler.length,
              itemBuilder: (context, index) {
                final urun = sepet.urunler[index];
                return SepetUrunKarti(
                  urun: urun,
                  onArtir: () => sepet.adetArtir(urun.id),
                  onAzalt: () => sepet.adetAzalt(urun.id),
                  onSil: () => sepet.urunSil(urun.id),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Genel Toplam', style: MetinStilleri.baslik2()),
                  FiyatEtiketi(tutar: sepet.genelToplam, boyut: 26, renk: UygulamaRenkleri.anaKoyu),
                ],
              ),
              const SizedBox(height: Olculer.boslukOrta),
              Row(
                children: [
                  Expanded(
                    child: OzelButon(
                      metin: 'Ürün Ekle',
                      ikon: Icons.add_a_photo_outlined,
                      tip: ButonTipi.cizgili,
                      onPressed: onUrunEkle,
                    ),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  Expanded(
                    child: OzelButon(
                      metin: 'Alışverişi Bitir',
                      ikon: Icons.receipt_long_rounded,
                      onPressed: sepet.urunler.isEmpty ? null : onAlisverisiBitir,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
