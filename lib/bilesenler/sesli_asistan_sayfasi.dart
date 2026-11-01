import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';

/// Alttan açılan interaktif sesli asistan penceresi
class SesliAsistanSayfasi extends StatelessWidget {
  final String seslendirilenMetin;
  final String? yanitMetni;
  final bool mikrofonIzniVar;
  final ValueChanged<String> onHizliKomut;

  const SesliAsistanSayfasi({
    super.key,
    this.seslendirilenMetin = 'Toplam ne kadar?',
    this.yanitMetni = 'Sepetinde 4 ürün var, toplam 287 lira 40 kuruş.',
    this.mikrofonIzniVar = true,
    required this.onHizliKomut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Olculer.yariCapBuyuk)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Tutamaç ve Kapatma Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: UygulamaRenkleri.anaZumrut,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Sesli Asistan Aktif', style: MetinStilleri.govdeKalin()),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // Dalga ve Dinleme Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              ),
              child: Column(
                children: [
                  Text(
                    'DİNLİYORUM...',
                    style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaZumrut).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  // Ses Dalgası Temsili İkonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      7,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: 12.0 + ((index % 3) * 14.0),
                        decoration: BoxDecoration(
                          color: UygulamaRenkleri.anaZumrut,
                          borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  Text(
                    '« $seslendirilenMetin »',
                    style: MetinStilleri.govdeKalin(renk: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // Asistan Yanıt Kartı
            if (yanitMetni != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Olculer.boslukOrta),
                decoration: BoxDecoration(
                  color: UygulamaRenkleri.anaAcik,
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy_outlined, size: 18, color: UygulamaRenkleri.anaKoyu),
                        const SizedBox(width: 6),
                        Text(
                          'FİYATGÖZ ASİSTANI',
                          style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      yanitMetni!,
                      style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.koyuYazi),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Olculer.boslukOrta),
            ],

            // Hızlı Örnek Komutlar
            Text('HIZLI KOMUTLAR:', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: Olculer.boslukKucuk),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _KomutCipi(metin: 'Sepette ne var?', onTiklandi: () => onHizliKomut('Sepette ne var?')),
                _KomutCipi(metin: 'Son ürünü sil', onTiklandi: () => onHizliKomut('Son ürünü sil')),
                _KomutCipi(metin: 'Bütçemi aştım mı?', onTiklandi: () => onHizliKomut('Bütçemi aştım mı?')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KomutCipi extends StatelessWidget {
  final String metin;
  final VoidCallback onTiklandi;

  const _KomutCipi({required this.metin, required this.onTiklandi});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(metin, style: MetinStilleri.aciklama(renk: UygulamaRenkleri.koyuYazi)),
      backgroundColor: const Color(0xFFF1F5F9),
      side: const BorderSide(color: UygulamaRenkleri.cizgi),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapTam)),
      onPressed: onTiklandi,
    );
  }
}
