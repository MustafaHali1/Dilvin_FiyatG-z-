import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/fiyat_etiketi.dart';
import '../../modeller/fis_modeli.dart';

/// Standart Mod - Termal Fiş Görünümü (Stitch: fi_g_r_n_m_termal_fi birebir)
class StandartFisView extends StatelessWidget {
  final FisModeli fis;
  final VoidCallback onPaylas;
  final VoidCallback onSesliOku;
  final VoidCallback onSesliAsistan;

  const StandartFisView({
    super.key,
    required this.fis,
    required this.onPaylas,
    required this.onSesliOku,
    required this.onSesliAsistan,
  });

  @override
  Widget build(BuildContext context) {
    final isKoyu = Theme.of(context).brightness == Brightness.dark;
    final zeminRengi = isKoyu ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final kartRengi = isKoyu ? const Color(0xFF1E293B) : Colors.white;
    final cizgiRengi = isKoyu ? const Color(0xFF334155) : Colors.black26;
    final anaYaziRengi = isKoyu ? Colors.white : Colors.black;
    final altYaziRengi = isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi;

    return Scaffold(
      backgroundColor: zeminRengi,
      appBar: AppBar(
        title: Text('Dijital Fiş Detayı', style: MetinStilleri.baslik2(renk: anaYaziRengi)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isKoyu ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            tooltip: 'Sesli Asistan',
            onPressed: onSesliAsistan,
            icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.anaZumrut, size: 26),
          ),
          IconButton(
            tooltip: 'PDF Paylaş',
            onPressed: onPaylas,
            icon: Icon(Icons.share_rounded, color: isKoyu ? Colors.white : null),
          ),
          IconButton(
            tooltip: 'Fişi Sesli Oku',
            onPressed: onSesliOku,
            icon: Icon(Icons.volume_up_rounded, color: isKoyu ? Colors.white : null),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        child: Container(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          decoration: BoxDecoration(
            color: kartRengi,
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            border: isKoyu ? Border.all(color: const Color(0xFF334155)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isKoyu ? 0.3 : 0.06),
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
                style: MetinStilleri.baslik2(renk: anaYaziRengi).copyWith(fontFamily: 'monospace', letterSpacing: 1.2),
              ),
              Text(
                'Tarih: ${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year}',
                style: MetinStilleri.aciklama(renk: altYaziRengi).copyWith(fontFamily: 'monospace'),
              ),
              Divider(height: 32, thickness: 1, color: cizgiRengi),

              for (final urun in fis.urunler)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${urun.ad} x${urun.adet}',
                          style: MetinStilleri.govde(renk: anaYaziRengi).copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                      Text(
                        '${urun.toplamTutar.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.govdeKalin(renk: anaYaziRengi).copyWith(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),

              Divider(height: 32, thickness: 1, color: cizgiRengi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOPLAM:', style: MetinStilleri.baslik1(renk: anaYaziRengi).copyWith(fontFamily: 'monospace')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: FiyatEtiketi(tutar: fis.toplamTutar, boyut: 24),
                      ),
                    ),
                  ),
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
