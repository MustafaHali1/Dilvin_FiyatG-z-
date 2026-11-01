import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';

/// Onboarding sirasinda gosterilen buyuk secim karti
class ProfilSecimKarti extends StatelessWidget {
  final String baslik;
  final String aciklama;
  final IconData ikon;
  final bool seciliMi;
  final String? rozetMetni;
  final VoidCallback onSecildi;

  const ProfilSecimKarti({
    super.key,
    required this.baslik,
    required this.aciklama,
    required this.ikon,
    required this.seciliMi,
    this.rozetMetni,
    required this.onSecildi,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSecildi,
      borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
          border: Border.all(
            color: seciliMi ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.cizgi,
            width: seciliMi ? 2.5 : 1,
          ),
          boxShadow: [
            if (seciliMi)
              BoxShadow(
                color: UygulamaRenkleri.anaZumrut.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: seciliMi
                    ? UygulamaRenkleri.anaZumrut
                    : UygulamaRenkleri.anaAcik,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              ),
              child: Icon(
                ikon,
                size: 28,
                color: seciliMi ? Colors.white : UygulamaRenkleri.anaKoyu,
              ),
            ),
            const SizedBox(width: Olculer.boslukBuyuk),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(baslik, style: MetinStilleri.baslik2()),
                      if (rozetMetni != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: UygulamaRenkleri.anaAcik,
                            borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                          ),
                          child: Text(
                            rozetMetni!,
                            style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(aciklama, style: MetinStilleri.aciklama()),
                ],
              ),
            ),
            Icon(
              seciliMi ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: seciliMi ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.griYazi,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
