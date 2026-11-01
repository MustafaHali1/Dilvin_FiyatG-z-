import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';

/// Yaşlılar veya görme güçlüğü çekenler için harf boyutu test adımı
class OkumaTestiEkrani extends StatefulWidget {
  final ValueChanged<double> onSecildi;

  const OkumaTestiEkrani({super.key, required this.onSecildi});

  @override
  State<OkumaTestiEkrani> createState() => _OkumaTestiEkraniState();
}

class _OkumaTestiEkraniState extends State<OkumaTestiEkrani> {
  int _seciliIndex = 2; // Varsayılan orta büyüklük

  final List<double> _boyutlar = [16.0, 20.0, 24.0, 30.0, 38.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Kolay Mod Kurulumu (1/3)', style: MetinStilleri.baslik2(renk: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rahatça okuyabildiğin en küçük satıra dokun:',
                style: MetinStilleri.kolayModGovde(),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),
              Expanded(
                child: ListView.builder(
                  itemCount: _boyutlar.length,
                  itemBuilder: (context, index) {
                    final boyut = _boyutlar[index];
                    final secili = _seciliIndex == index;

                    return InkWell(
                      onTap: () => setState(() => _seciliIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
                        padding: const EdgeInsets.all(Olculer.boslukOrta),
                        decoration: BoxDecoration(
                          color: secili ? UygulamaRenkleri.kolayModSari : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                          border: Border.all(
                            color: secili ? Colors.white : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Süt 24,90 ₺',
                              style: TextStyle(
                                fontSize: boyut,
                                fontWeight: FontWeight.bold,
                                color: secili ? Colors.black : Colors.white,
                              ),
                            ),
                            if (secili)
                              const Icon(Icons.check_circle, color: Colors.black, size: 28),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              OzelButon(
                metin: 'Bu Boyut Uygun',
                kolayMod: true,
                onPressed: () => widget.onSecildi(_boyutlar[_seciliIndex]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
