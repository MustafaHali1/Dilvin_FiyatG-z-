import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/profil_modeli.dart';

/// Renk körlüğü türü seçim veya test yönlendirme ekranı
class RenkKorluguSecimEkrani extends StatefulWidget {
  final ValueChanged<RenkKorluguTuru> onSecildi;
  final VoidCallback onTestBaslat;

  const RenkKorluguSecimEkrani({
    super.key,
    required this.onSecildi,
    required this.onTestBaslat,
  });

  @override
  State<RenkKorluguSecimEkrani> createState() => _RenkKorluguSecimEkraniState();
}

class _RenkKorluguSecimEkraniState extends State<RenkKorluguSecimEkrani> {
  RenkKorluguTuru _seciliTur = RenkKorluguTuru.deuteranopi;

  @override
  Widget build(BuildContext context) {
    final palet = RenkKorluguPaleti.getir(_seciliTur);

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Renk Körlüğü Türü', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sana en uygun renk paletini ayarlayabilmemiz için türünü seç:',
                style: MetinStilleri.govde(),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              // 1. Deuteranopi (Yeşil Körlüğü): Mavi, Turuncu, Pembe
              _TurKarti(
                baslik: 'Yeşili ayırt edemiyorum',
                turAdi: 'Deuteranopi (Mavi, Turuncu, Pembe)',
                ornekRenkler: const [
                  Color(0xFF0072B2), // Mavi
                  Color(0xFFE69F00), // Turuncu
                  Color(0xFFCC79A7), // Pembe (Magenta)
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.deuteranopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.deuteranopi),
              ),
              // 2. Protanopi (Kırmızı Körlüğü): Koyu Mavi, Açık Mavi, Turuncu
              _TurKarti(
                baslik: 'Kırmızıyı ayırt edemiyorum',
                turAdi: 'Protanopi (Koyu Mavi, Açık Mavi, Turuncu)',
                ornekRenkler: const [
                  Color(0xFF0072B2), // Koyu Mavi
                  Color(0xFF56B4E9), // Açık Mavi
                  Color(0xFFE69F00), // Turuncu
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.protanopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.protanopi),
              ),
              // 3. Tritanopi (Mavi-Sarı Körlüğü): Zümrüt Yeşili, Kızıl, Pembe
              _TurKarti(
                baslik: 'Mavi ve sarıyı ayırt edemiyorum',
                turAdi: 'Tritanopi (Zümrüt, Kızıl, Pembe)',
                ornekRenkler: const [
                  Color(0xFF009E73), // Zümrüt Yeşili
                  Color(0xFFD55E00), // Kızıl Turuncu
                  Color(0xFFCC79A7), // Pembe
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.tritanopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.tritanopi),
              ),
              const Spacer(),
              // Test Butonu (Seçili palet rengiyle)
              OzelButon(
                metin: 'Bilmiyorum, Test Yapalım',
                tip: ButonTipi.cizgili,
                ikon: Icons.quiz_outlined,
                renk: palet.primary,
                onPressed: widget.onTestBaslat,
              ),
              const SizedBox(height: Olculer.boslukOrta),
              // Devam Butonu (Seçili palet rengiyle)
              OzelButon(
                metin: 'Bu Paletle Devam Et',
                ikon: Icons.check_rounded,
                renk: palet.primary,
                onPressed: () => widget.onSecildi(_seciliTur),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurKarti extends StatelessWidget {
  final String baslik;
  final String turAdi;
  final List<Color> ornekRenkler;
  final bool seciliMi;
  final VoidCallback onDokunuldu;

  const _TurKarti({
    required this.baslik,
    required this.turAdi,
    required this.ornekRenkler,
    required this.seciliMi,
    required this.onDokunuldu,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDokunuldu,
      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
      child: Container(
        margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seciliMi ? ornekRenkler.first.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
          border: Border.all(
            color: seciliMi ? ornekRenkler.first : UygulamaRenkleri.cizgi,
            width: seciliMi ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Expanded ile sararak sağdaki taşmaları kesin olarak engelliyoruz
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    baslik,
                    style: MetinStilleri.govdeKalin(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    turAdi,
                    style: MetinStilleri.aciklama(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Palet renk halkaları
            Row(
              mainAxisSize: MainAxisSize.min,
              children: ornekRenkler
                  .map((c) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 8),
            Icon(
              seciliMi ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: seciliMi ? ornekRenkler.first : UygulamaRenkleri.griYazi,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
