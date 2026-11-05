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
        backgroundColor: UygulamaRenkleri.anaZumrut,
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
    final bool isKoyu = profil.karanlikModAcik;
    final Color zeminRengi = isKoyu ? const Color(0xFF0F172A) : UygulamaRenkleri.arkaPlan;
    final Color barRengi = isKoyu ? const Color(0xFF1E293B) : Colors.white;
    final Color anaYaziRengi = isKoyu ? Colors.white : UygulamaRenkleri.koyuYazi;
    final Color altYaziRengi = isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi;

    return Scaffold(
      backgroundColor: zeminRengi,
      appBar: AppBar(
        title: Text(
          'Alışveriş Sepeti (${sepet.toplamUrunAdedi} Ürün)',
          style: MetinStilleri.baslik2(renk: anaYaziRengi),
        ),
        backgroundColor: zeminRengi,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _sepetSesliKomutDinle(context),
            icon: const Icon(Icons.mic, color: UygulamaRenkleri.anaZumrut, size: 28),
            tooltip: 'Sesli Asistan ile Konuş',
          ),
          IconButton(
            onPressed: () => _sepetiSesliOku(context),
            icon: Icon(
              Icons.volume_up_rounded,
              color: isKoyu ? Colors.white : UygulamaRenkleri.anaKoyu,
              size: 28,
            ),
            tooltip: 'Toplamı Sesli Oku',
          ),
        ],
      ),
      body: sepet.urunler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: altYaziRengi,
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  Text('Sepetiniz henüz boş', style: MetinStilleri.baslik2(renk: anaYaziRengi)),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text('Fiyat okutarak ürün eklemeye başlayın', style: MetinStilleri.aciklama(renk: altYaziRengi)),
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
          color: barRengi,
          border: isKoyu ? const Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isKoyu ? 0.3 : 0.05),
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
                  Text('Genel Toplam', style: MetinStilleri.baslik2(renk: anaYaziRengi)),
                  FiyatEtiketi(
                    tutar: sepet.genelToplam,
                    boyut: 26,
                    renk: isKoyu ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.anaKoyu,
                  ),
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
