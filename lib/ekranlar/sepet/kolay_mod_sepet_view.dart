import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../servisler/sesli_komut_servisi.dart';

/// Kolay Mod - Sepet Ekranı
/// Yaşlı ve az gören kullanıcılar için yüksek kontrastlı, harf bölünmesi olmayan
/// 2 satırlı ferah kart düzeni ve taşma yapmayan alt toplam barı.
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
      onSonuc: (metin, sonMu) async {
        if (sonMu && metin.isNotEmpty) {
          final sonuc = await komutServisi.niyetCozAkilli(
            metin,
            kalanButce: profil.aylikButce - sepet.toplamTutar,
            sepetTutar: sepet.toplamTutar,
            sepetAdet: sepet.toplamUrunAdedi,
          );
          if (sonuc.asistanCevabi != null && sonuc.asistanCevabi!.isNotEmpty) {
            asistan.konus(sonuc.asistanCevabi!);
            return;
          }
          if (!context.mounted) return;
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
        elevation: 0,
        title: Text(
          'SEPETİM (${sepet.toplamUrunAdedi})',
          style: MetinStilleri.kolayModBaslik().copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => _sepetSesliKomutDinle(context),
            icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.kolayModSari, size: 28),
            tooltip: 'Sesli Asistan',
          ),
          IconButton(
            onPressed: () => _sepetiSesliOku(context),
            icon: const Icon(Icons.volume_up_rounded, color: UygulamaRenkleri.kolayModSari, size: 28),
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
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sepetiniz Boş',
                    style: MetinStilleri.kolayModBaslik(renk: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fiyat okutarak ürün ekleyebilirsiniz.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                Olculer.boslukBuyuk,
                Olculer.boslukOrta,
                Olculer.boslukBuyuk,
                Olculer.boslukBuyuk,
              ),
              itemCount: sepet.urunler.length,
              itemBuilder: (context, index) {
                final urun = sepet.urunler[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
                  padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Satır: Ürün Adı (Geniş alan, kelime bölünmesi yok) ve Sağda Toplam Tutar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              urun.ad,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                            style: MetinStilleri.kolayModBaslik(renk: UygulamaRenkleri.kolayModSari)
                                .copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Colors.white12),
                      const SizedBox(height: 12),

                      // 2. Satır: Birim Fiyat Bilgisi ve Sağda Ferah Adet Değiştirme Butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Birim: ${urun.birimFiyat.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Eksi Butonu
                              IconButton(
                                onPressed: () => sepet.adetAzalt(urun.id),
                                icon: const Icon(Icons.remove_rounded, size: 24),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E2E2E),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(40, 40),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${urun.adet}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Artı Butonu
                              IconButton(
                                onPressed: () => sepet.adetArtir(urun.id),
                                icon: const Icon(Icons.add_rounded, size: 24),
                                style: IconButton.styleFrom(
                                  backgroundColor: UygulamaRenkleri.kolayModSari,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(40, 40),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
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
          border: Border(
            top: BorderSide(color: UygulamaRenkleri.kolayModSari, width: 2),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ödenecek Tutar Satırı (31px overflow hatası FittedBox ile kalıcı olarak önlendi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ÖDENECEK TUTAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${sepet.genelToplam.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.kolayModDev(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              // Alt Aksiyon Butonları
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: onUrunEkle,
                        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                        label: const Text(
                          'FİYAT OKU',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E2E2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: sepet.urunler.isEmpty ? null : onAlisverisiBitir,
                        icon: const Icon(Icons.receipt_long_rounded, color: Colors.black, size: 28),
                        label: const Text(
                          'BİTİR',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UygulamaRenkleri.kolayModSari,
                          disabledBackgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                          ),
                        ),
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
