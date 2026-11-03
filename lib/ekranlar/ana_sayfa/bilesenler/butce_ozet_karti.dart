import 'package:flutter/material.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/bilesenler/fiyat_etiketi.dart';

/// Tasarimdaki ust butce ozet karti bileseni
class ButceOzetKarti extends StatelessWidget {
  final double harcanan;
  final double butce;
  final int fisSayisi;
  final double buHaftaHarcanan;
  final Color? vurguRengi;
  final String? donemEtiketi;
  final int? kalanGun;
  final VoidCallback? onKayitliFisTap;
  final VoidCallback? onBuHaftaTap;

  const ButceOzetKarti({
    super.key,
    required this.harcanan,
    required this.butce,
    this.fisSayisi = 0,
    this.buHaftaHarcanan = 0.0,
    this.vurguRengi,
    this.donemEtiketi,
    this.kalanGun,
    this.onKayitliFisTap,
    this.onBuHaftaTap,
  });

  @override
  Widget build(BuildContext context) {
    final yuzde = butce > 0 ? (harcanan / butce).clamp(0.0, 1.0) : 0.0;
    final kalan = butce - harcanan;
    final etkinVurgu = vurguRengi ?? UygulamaRenkleri.anaZumrut;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: etkinVurgu),
                    const SizedBox(width: 6),
                    Text(
                      donemEtiketi != null ? 'Dönem: $donemEtiketi' : 'Bu Ay Harcanan',
                      style: MetinStilleri.aciklama(renk: Colors.white),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Bütçe: ${butce.toStringAsFixed(0)} ₺',
                    style: MetinStilleri.aciklama(renk: Colors.white70),
                  ),
                  if (kalanGun != null)
                    Text(
                      '$kalanGun gün kaldı',
                      style: TextStyle(
                        color: etkinVurgu,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          FiyatEtiketi(
            tutar: harcanan,
            boyut: 34,
            renk: Colors.white,
          ),
          const SizedBox(height: Olculer.boslukOrta),
          ClipRRect(
            borderRadius: BorderRadius.circular(Olculer.yariCapTam),
            child: LinearProgressIndicator(
              value: yuzde,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(etkinVurgu),
            ),
          ),
          const SizedBox(height: Olculer.boslukKucuk),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '%${(yuzde * 100).toInt()} kullanıldı',
                style: MetinStilleri.aciklama(renk: etkinVurgu),
              ),
              Text(
                'Kalan: ${kalan.toStringAsFixed(2)} ₺',
                style: MetinStilleri.aciklama(renk: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          Row(
            children: [
              Expanded(
                child: _KucukIstatistikKutusu(
                  baslik: 'Kayıtlı Fiş',
                  deger: '$fisSayisi Adet',
                  ikon: Icons.receipt_long_rounded,
                  onTap: onKayitliFisTap,
                ),
              ),
              const SizedBox(width: Olculer.boslukOrta),
              Expanded(
                child: _KucukIstatistikKutusu(
                  baslik: 'Bu Hafta',
                  deger: '${buHaftaHarcanan.toStringAsFixed(2)} ₺',
                  ikon: Icons.calendar_today_rounded,
                  onTap: onBuHaftaTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KucukIstatistikKutusu extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final VoidCallback? onTap;

  const _KucukIstatistikKutusu({
    required this.baslik,
    required this.deger,
    required this.ikon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Olculer.boslukOrta,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(ikon, size: 20, color: Colors.white70),
              const SizedBox(width: Olculer.boslukKucuk),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik, style: MetinStilleri.aciklama(renk: Colors.white54), maxLines: 1),
                    Text(deger, style: MetinStilleri.govdeKalin(renk: Colors.white), maxLines: 1),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
