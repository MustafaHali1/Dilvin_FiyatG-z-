import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/fiyat_etiketi.dart';
import '../../modeller/fis_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';

/// Renk Körü Modu - Fiş Görünümü
/// Standart mod ile %100 birebir aynı yerleşime sahiptir.
/// Yeşil/kırmızı renkler seçilen Okabe-Ito paleti ile boyanır.
class RenkKoruFisView extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;
  final VoidCallback onSesliAsistan;

  const RenkKoruFisView({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
    required this.onSesliAsistan,
  });

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);
    final anaRenk = palet.primary;

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Dijital Fiş Detayı', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Paylaş',
            onPressed: onPaylas,
            icon: const Icon(Icons.share_rounded, color: Colors.black87),
          ),
          IconButton(
            tooltip: 'Sesli Oku',
            onPressed: onSesliOku,
            icon: const Icon(Icons.volume_up_rounded, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        child: Container(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_rounded, size: 48, color: anaRenk),
              const SizedBox(height: Olculer.boslukKucuk),
              Text(
                'FİYATGÖZ ALIŞVERİŞ FİŞİ',
                style: MetinStilleri.baslik2().copyWith(fontFamily: 'monospace', letterSpacing: 1.2),
              ),
              Text(
                'Tarih: ${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year}',
                style: MetinStilleri.aciklama().copyWith(fontFamily: 'monospace'),
              ),
              const Divider(height: 32, thickness: 1, color: Colors.black26),

              for (final urun in fis.urunler)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${urun.ad} x${urun.adet}',
                          style: MetinStilleri.govde().copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                      Text(
                        '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.govdeKalin().copyWith(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 32, thickness: 1, color: Colors.black26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOPLAM:', style: MetinStilleri.baslik1().copyWith(fontFamily: 'monospace')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: FiyatEtiketi(tutar: fis.toplamTutar, boyut: 24, renk: anaRenk),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              OzelButon(
                metin: 'PDF Olarak Kaydet / Paylaş',
                ikon: Icons.picture_as_pdf_rounded,
                renk: anaRenk,
                onPressed: onPaylas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
