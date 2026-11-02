import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/fiyat_etiketi.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../servisler/sesli_komut_servisi.dart';

/// Renk Körü Modu - Sepet Ekranı
/// Standart mod ile %100 birebir aynı yerleşime sahiptir.
/// Yeşil ve kırmızı öğeler kullanıcının seçtiği Okabe-Ito renk paletiyle boyanır.
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

  void _sepetiSesliOku(BuildContext context) {
    final profil = context.read<ProfilYoneticisi>().profil;
    if (!profil.sesliAsistanAcik) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesli okuma ayarlardan kapalı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (sepet.urunler.isEmpty) {
      SesliAsistanServisi().konus('Sepetiniz şu anda boş.');
      return;
    }
    final urunlerMetni = sepet.urunler
        .map((u) => '${u.adet} adet ${u.ad}, ${u.toplamTutar.toStringAsFixed(2)} lira')
        .join('. ');
    final mesaj =
        'Sepetinizde ${sepet.urunCesitSayisi} çeşit ürün var. $urunlerMetni. Genel toplam ${sepet.toplamTutar.toStringAsFixed(2)} lira.';
    SesliAsistanServisi().konus(mesaj);
  }

  void _sepetSesliKomutDinle(BuildContext context) {
    final profil = context.read<ProfilYoneticisi>().profil;
    if (!profil.sesliAsistanAcik) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesli Asistan ayarlardan kapalı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final asistan = SesliAsistanServisi();
    final komutServisi = SesliKomutServisi();

    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sizi dinliyorum... ("Sepeti oku", "Bütçem ne kadar" veya "Alışverişi bitir")'),
        duration: const Duration(seconds: 4),
        backgroundColor: palet.primary,
      ),
    );

    asistan.dinle(
      onSonuc: (metin, sonMu) {
        if (sonMu && metin.isNotEmpty) {
          final sonuc = komutServisi.niyetCoz(metin);
          switch (sonuc.tur) {
            case KomutTuru.sepetOzeti:
              _sepetiSesliOku(context);
              break;
            case KomutTuru.butceSorgula:
              final harcanan = sepet.toplamTutar;
              final kalan = profil.aylikButce - harcanan;
              if (kalan >= 0) {
                asistan.konus('Toplam ${harcanan.toStringAsFixed(2)} lira harcadınız. Kalan bütçeniz ${kalan.toStringAsFixed(2)} lira.');
              } else {
                asistan.konus('Bütçenizi ${(-kalan).toStringAsFixed(2)} lira aştınız! Toplam tutar: ${harcanan.toStringAsFixed(2)} lira.');
              }
              break;
            case KomutTuru.sepeteEkle:
              asistan.konus('Alışveriş tamamlanıyor, fiş ekranına gidiliyor.');
              onAlisverisiBitir();
              break;
            default:
              asistan.konus('Anlayamadım. "Sepeti oku" veya "Bütçem ne kadar" diyebilirsiniz.');
              break;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);
    final anaRenk = palet.primary;

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text(
          'Alışveriş Sepeti (${sepet.toplamUrunAdedi} Ürün)',
          style: MetinStilleri.baslik2(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _sepetSesliKomutDinle(context),
            icon: Icon(Icons.mic_rounded, color: anaRenk),
            tooltip: 'Sesli Asistan',
          ),
          IconButton(
            onPressed: () => _sepetiSesliOku(context),
            icon: Icon(Icons.volume_up_rounded, color: anaRenk),
            tooltip: 'Sepeti Sesli Oku',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: sepet.urunler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  Text('Sepetiniz şu anda boş', style: MetinStilleri.govdeKalin()),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text('Barkod okutarak ürün ekleyebilirsiniz', style: MetinStilleri.aciklama()),
                  const SizedBox(height: Olculer.boslukBuyuk),
                  SizedBox(
                    width: 200,
                    child: OzelButon(
                      metin: 'Ürün Ekle',
                      ikon: Icons.add_shopping_cart_rounded,
                      renk: anaRenk,
                      onPressed: onUrunEkle,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              itemCount: sepet.urunler.length,
              itemBuilder: (context, index) {
                final urun = sepet.urunler[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
                  padding: const EdgeInsets.all(Olculer.boslukOrta),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    border: Border.all(color: UygulamaRenkleri.cizgi),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: anaRenk.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: anaRenk),
                      ),
                      const SizedBox(width: Olculer.boslukOrta),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(urun.ad, style: MetinStilleri.govdeKalin(), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              '${urun.birimFiyat.toStringAsFixed(2)} ₺ x ${urun.adet} adet',
                              style: MetinStilleri.aciklama(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FiyatEtiketi(tutar: urun.toplamTutar, boyut: 16),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: UygulamaRenkleri.arkaPlan,
                              borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => sepet.adetAzalt(urun.id),
                                  borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('${urun.adet}', style: MetinStilleri.govdeKalin()),
                                ),
                                InkWell(
                                  onTap: () => sepet.adetArtir(urun.id),
                                  borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.add, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  Text('Genel Toplam', style: MetinStilleri.govdeKalin()),
                  FiyatEtiketi(
                    tutar: sepet.genelToplam,
                    boyut: 24,
                    renk: anaRenk,
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              Row(
                children: [
                  Expanded(
                    child: OzelButon(
                      metin: 'Ürün Ekle',
                      tip: ButonTipi.cizgili,
                      ikon: Icons.add_a_photo_outlined,
                      renk: anaRenk,
                      onPressed: onUrunEkle,
                    ),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  Expanded(
                    child: OzelButon(
                      metin: 'Alışverişi Bitir',
                      ikon: Icons.receipt_long_rounded,
                      renk: anaRenk,
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
