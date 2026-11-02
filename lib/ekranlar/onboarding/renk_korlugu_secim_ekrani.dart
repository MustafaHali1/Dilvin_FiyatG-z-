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
              _TurKarti(
                baslik: 'Yeşili ayırt edemiyorum',
                turAdi: 'Deuteranopi (En Yaygın)',
                ornekRenkler: const [
                  Color(0xFF0072B2), // Primary
                  Color(0xFFE69F00), // Secondary
                  Color(0xFF56B4E9), // Info
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.deuteranopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.deuteranopi),
              ),
              _TurKarti(
                baslik: 'Kırmızıyı ayırt edemiyorum',
                turAdi: 'Protanopi',
                ornekRenkler: const [
                  Color(0xFF009E73), // Primary
                  Color(0xFF56B4E9), // Secondary
                  Color(0xFFD55E00), // Error
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.protanopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.protanopi),
              ),
              _TurKarti(
                baslik: 'Mavi ve sarıyı ayırt edemiyorum',
                turAdi: 'Tritanopi',
                ornekRenkler: const [
                  Color(0xFFD55E00), // Primary
                  Color(0xFF009E73), // Secondary
                  Color(0xFFCC79A7), // Warning
                ],
                seciliMi: _seciliTur == RenkKorluguTuru.tritanopi,
                onDokunuldu: () => setState(() => _seciliTur = RenkKorluguTuru.tritanopi),
              ),
              const Spacer(),
              OzelButon(
                metin: 'Bilmiyorum, Test Yapalım',
                tip: ButonTipi.cizgili,
                ikon: Icons.quiz_outlined,
                onPressed: widget.onTestBaslat,
              ),
              const SizedBox(height: Olculer.boslukOrta),
              OzelButon(
                metin: 'Bu Paletle Devam Et',
                ikon: Icons.check_rounded,
                renk: RenkKorluguPaleti.getir(_seciliTur).primary,
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
        padding: const EdgeInsets.all(Olculer.boslukOrta),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
          border: Border.all(
            color: seciliMi ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.cizgi,
            width: seciliMi ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: MetinStilleri.govdeKalin()),
                Text(turAdi, style: MetinStilleri.aciklama()),
              ],
            ),
            const Spacer(),
            Row(
              children: ornekRenkler
                  .map((c) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 12),
            Icon(
              seciliMi ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: seciliMi ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.griYazi,
            ),
          ],
        ),
      ),
    );
  }
}
