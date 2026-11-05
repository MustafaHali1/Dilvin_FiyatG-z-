import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/bilesenler/fiyat_etiketi.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';

/// Ana sayfadaki fis ogesi karti
class FisKarti extends StatelessWidget {
  final FisModeli fis;
  final Color? vurguRengi;
  final VoidCallback? onDokunuldu;

  const FisKarti({
    super.key,
    required this.fis,
    this.vurguRengi,
    this.onDokunuldu,
  });

  @override
  Widget build(BuildContext context) {
    final isKoyu = Theme.of(context).brightness == Brightness.dark;
    final etkinVurgu = vurguRengi ?? (isKoyu ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.anaKoyu);
    final zeminRengi = vurguRengi != null
        ? vurguRengi!.withValues(alpha: 0.1)
        : (isKoyu ? const Color(0xFF334155) : UygulamaRenkleri.anaAcik);

    return InkWell(
      onTap: onDokunuldu,
      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
      child: Container(
        margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
        padding: const EdgeInsets.all(Olculer.boslukOrta),
        decoration: BoxDecoration(
          color: isKoyu ? const Color(0xFF1E293B) : UygulamaRenkleri.kartBeyaz,
          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
          border: Border.all(color: isKoyu ? const Color(0xFF334155) : UygulamaRenkleri.cizgi),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: zeminRengi,
                borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: etkinVurgu,
              ),
            ),
            const SizedBox(width: Olculer.boslukOrta),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fis.aciklama,
                    style: MetinStilleri.govdeKalin(
                      renk: isKoyu ? Colors.white : UygulamaRenkleri.koyuYazi,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isKoyu ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fis.marketAdi,
                          style: MetinStilleri.aciklama(
                            renk: isKoyu ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${fis.toplamUrunAdedi} ürün',
                        style: MetinStilleri.aciklama(
                          renk: isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FiyatEtiketi(tutar: fis.toplamTutar, boyut: 17),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi,
            ),
          ],
        ),
      ),
    );
  }
}
