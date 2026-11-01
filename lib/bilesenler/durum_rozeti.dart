import 'package:flutter/material.dart';
import '../sabitler/uygulama_renkleri.dart';
import '../sabitler/olculer.dart';
import '../sabitler/metin_stilleri.dart';

/// İndirimli, Çevrimdışı veya AI durumlarını gösteren atomik etiket
class DurumRozeti extends StatelessWidget {
  final String metin;
  final IconData? ikon;
  final Color arkaPlan;
  final Color yaziRengi;

  const DurumRozeti({
    super.key,
    required this.metin,
    this.ikon,
    this.arkaPlan = UygulamaRenkleri.anaAcik,
    this.yaziRengi = UygulamaRenkleri.anaKoyu,
  });

  factory DurumRozeti.indirimli() {
    return const DurumRozeti(
      metin: 'İndirimli',
      ikon: Icons.local_offer_rounded,
      arkaPlan: Color(0xFFFEF3C7),
      yaziRengi: Color(0xFFD97706),
    );
  }

  factory DurumRozeti.yapayZeka() {
    return const DurumRozeti(
      metin: 'Yapay zekâ ile tanındı',
      ikon: Icons.auto_awesome_rounded,
      arkaPlan: Color(0xFFECFDF5),
      yaziRengi: Color(0xFF059669),
    );
  }

  factory DurumRozeti.cevrimdisi() {
    return const DurumRozeti(
      metin: 'Çevrimdışı mod',
      ikon: Icons.cloud_off_rounded,
      arkaPlan: Color(0xFFF1F5F9),
      yaziRengi: Color(0xFF475569),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: arkaPlan,
        borderRadius: BorderRadius.circular(Olculer.yariCapTam),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 14, color: yaziRengi),
            const SizedBox(width: 4),
          ],
          Text(
            metin,
            style: MetinStilleri.aciklama(renk: yaziRengi).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
