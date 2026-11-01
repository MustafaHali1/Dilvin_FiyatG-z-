import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';

/// Ishihara tarzı renk körlüğü test sorusu ekranı
class RenkTestiSorusuEkrani extends StatefulWidget {
  final VoidCallback onTestTamamlandi;

  const RenkTestiSorusuEkrani({super.key, required this.onTestTamamlandi});

  @override
  State<RenkTestiSorusuEkrani> createState() => _RenkTestiSorusuEkraniState();
}

class _RenkTestiSorusuEkraniState extends State<RenkTestiSorusuEkrani> {
  String? _secilenCevap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Renk Testi (Soru 1/3)', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          child: Column(
            children: [
              Text(
                'Dairenin içinde hangi sayıyı görüyorsun?',
                style: MetinStilleri.govdeKalin(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Olculer.boslukBuyuk),

              // Ishihara Test Dairesi Görünümü
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFE2E8F0),
                      Color(0xFFCBD5E1),
                    ],
                  ),
                  border: Border.all(color: UygulamaRenkleri.cizgi, width: 4),
                ),
                child: Center(
                  child: Text(
                    '74',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF10B981).withValues(alpha: 0.8),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),

              // Şıklar (4 seçenek)
              Row(
                children: [
                  _CevapSecenekButonu(
                    cevap: '74',
                    seciliMi: _secilenCevap == '74',
                    onTiklandi: () => setState(() => _secilenCevap = '74'),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  _CevapSecenekButonu(
                    cevap: '21',
                    seciliMi: _secilenCevap == '21',
                    onTiklandi: () => setState(() => _secilenCevap = '21'),
                  ),
                ],
              ),
              const SizedBox(height: Olculer.boslukOrta),
              Row(
                children: [
                  _CevapSecenekButonu(
                    cevap: '12',
                    seciliMi: _secilenCevap == '12',
                    onTiklandi: () => setState(() => _secilenCevap = '12'),
                  ),
                  const SizedBox(width: Olculer.boslukOrta),
                  _CevapSecenekButonu(
                    cevap: 'Göremiyorum',
                    seciliMi: _secilenCevap == 'Göremiyorum',
                    onTiklandi: () => setState(() => _secilenCevap = 'Göremiyorum'),
                  ),
                ],
              ),
              const Spacer(),
              OzelButon(
                metin: 'Sonraki Soru',
                onPressed: _secilenCevap == null ? null : widget.onTestTamamlandi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CevapSecenekButonu extends StatelessWidget {
  final String cevap;
  final bool seciliMi;
  final VoidCallback onTiklandi;

  const _CevapSecenekButonu({
    required this.cevap,
    required this.seciliMi,
    required this.onTiklandi,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTiklandi,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: seciliMi ? UygulamaRenkleri.anaZumrut : Colors.white,
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            border: Border.all(
              color: seciliMi ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.cizgi,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              cevap,
              style: MetinStilleri.govdeKalin(
                renk: seciliMi ? Colors.white : UygulamaRenkleri.koyuYazi,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
