import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../servisler/sesli_komut_servisi.dart';

/// Kolay Mod - Sepet Ekranı (Stitch: kolay_mod_sepetim birebir)
class KolayModSepetView extends StatelessWidget {
  final SepetYoneticisi sepet;
  final VoidCallback onUrunEkle;
  final VoidCallback onAlisverisiBitir;

  const KolayModSepetView({
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sizi dinliyorum... ("Sepeti oku", "Bütçem ne kadar" veya "Alışverişi bitir")'),
        duration: Duration(seconds: 4),
        backgroundColor: UygulamaRenkleri.kolayModSari,
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('SEPETİM (${sepet.toplamUrunAdedi} Ürün)', style: MetinStilleri.kolayModBaslik()),
        actions: [
          IconButton(
            onPressed: () => _sepetSesliKomutDinle(context),
            icon: const Icon(Icons.mic, color: UygulamaRenkleri.kolayModSari, size: 30),
            tooltip: 'Sesli Asistan ile Konuş',
          ),
          TextButton.icon(
            onPressed: () => _sepetiSesliOku(context),
            icon: const Icon(Icons.volume_up, color: Colors.black),
            label: const Text('SESLİ OKU', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: UygulamaRenkleri.kolayModSari,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: sepet.urunler.isEmpty
          ? Center(
              child: Text(
                'Sepetiniz Boş',
                style: MetinStilleri.kolayModBaslik(renk: Colors.white70),
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
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(urun.ad, style: MetinStilleri.kolayModGovde()),
                            const SizedBox(height: 4),
                            Text(
                              '${urun.adet} Adet (${urun.birimFiyat.toStringAsFixed(2)} ₺)',
                              style: MetinStilleri.govde(renk: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.kolayModBaslik(renk: UygulamaRenkleri.kolayModSari),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => sepet.adetAzalt(urun.id),
                            icon: const Icon(Icons.remove, size: 28),
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E), foregroundColor: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${urun.adet}', style: MetinStilleri.kolayModGovde()),
                          ),
                          IconButton(
                            onPressed: () => sepet.adetArtir(urun.id),
                            icon: const Icon(Icons.add, size: 28),
                            style: IconButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari, foregroundColor: Colors.black),
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
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: UygulamaRenkleri.kolayModSari, width: 2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ÖDENECEK TUTAR', style: MetinStilleri.kolayModGovde(renk: Colors.white70)),
                  Text(
                    '${sepet.genelToplam.toStringAsFixed(2)} ₺',
                    style: MetinStilleri.kolayModDev(),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton.icon(
                        onPressed: onUrunEkle,
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                        label: const Text('FİYAT OKU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  Expanded(
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton.icon(
                        onPressed: sepet.urunler.isEmpty ? null : onAlisverisiBitir,
                        icon: const Icon(Icons.receipt, color: Colors.black, size: 28),
                        label: const Text('BİTİR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                        style: ElevatedButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari),
                      ),
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
