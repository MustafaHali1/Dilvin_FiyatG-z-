import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/bilesenler/fiyat_etiketi.dart';
import 'package:fiyatgoz/modeller/urun_modeli.dart';

/// Sepetteki tek bir urun satiri karti
class SepetUrunKarti extends StatelessWidget {
  final UrunModeli urun;
  final VoidCallback onArtir;
  final VoidCallback onAzalt;
  final VoidCallback onSil;

  const SepetUrunKarti({
    super.key,
    required this.urun,
    required this.onArtir,
    required this.onAzalt,
    required this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
      padding: const EdgeInsets.all(Olculer.boslukOrta),
      decoration: BoxDecoration(
        color: UygulamaRenkleri.kartBeyaz,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(color: UygulamaRenkleri.cizgi),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: UygulamaRenkleri.griYazi,
            ),
          ),
          const SizedBox(width: Olculer.boslukOrta),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  urun.ad,
                  style: MetinStilleri.govdeKalin(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${urun.birimFiyat.toStringAsFixed(2)} ₺ × ${urun.adet} adet',
                  style: MetinStilleri.aciklama(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FiyatEtiketi(tutar: urun.toplamTutar, boyut: 16),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                  border: Border.all(color: UygulamaRenkleri.cizgi),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onAzalt,
                      borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Text(
                      '${urun.adet}',
                      style: MetinStilleri.govdeKalin().copyWith(fontSize: 13),
                    ),
                    InkWell(
                      onTap: onArtir,
                      borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
  }
}
