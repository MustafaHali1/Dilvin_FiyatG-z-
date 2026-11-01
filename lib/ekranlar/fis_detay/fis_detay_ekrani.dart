import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/bilesenler/ozel_buton.dart';
import 'package:fiyatgoz/bilesenler/fiyat_etiketi.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';

/// Gercek termal kagit fis gorunumundeki detay sayfasi
class FisDetayEkrani extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;

  const FisDetayEkrani({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Dijital Fiş Detayı', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: onPaylas,
            icon: const Icon(Icons.share_rounded),
          ),
          IconButton(
            onPressed: onSesliOku,
            icon: const Icon(Icons.volume_up_rounded),
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
              const Icon(Icons.receipt_rounded, size: 48, color: UygulamaRenkleri.anaZumrut),
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

              // Urun Kalemleri
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
                  FiyatEtiketi(tutar: fis.toplamTutar, boyut: 24),
                ],
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              OzelButon(
                metin: 'PDF Olarak Kaydet / Paylaş',
                ikon: Icons.picture_as_pdf_rounded,
                onPressed: onPaylas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
