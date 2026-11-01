import 'dart:io';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';

/// Kolay Mod - Fiyat Onay Ekranı (Stitch: kolay_mod_fiyat_onay birebir)
class KolayModFiyatOnayView extends StatefulWidget {
  final String? resimYolu;
  final ValueChanged<Map<String, dynamic>> onOnaylandi;
  final VoidCallback onTekrarCek;

  const KolayModFiyatOnayView({
    super.key,
    this.resimYolu,
    required this.onOnaylandi,
    required this.onTekrarCek,
  });

  @override
  State<KolayModFiyatOnayView> createState() => _KolayModFiyatOnayViewState();
}

class _KolayModFiyatOnayViewState extends State<KolayModFiyatOnayView> {
  int _adet = 1;
  final double _seciliFiyat = 24.90;
  final TextEditingController _urunAdiDenetleyici =
      TextEditingController(text: 'Sütaş Tam Yağlı Süt (1 Litre)');

  @override
  void dispose() {
    _urunAdiDenetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('FİYAT VE ÜRÜN ONAYI', style: MetinStilleri.kolayModBaslik()),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // Resim Varsa
          if (widget.resimYolu != null && File(widget.resimYolu!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.file(File(widget.resimYolu!), fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Devasa Sarı Kutu: Ürün ve Fiyat
          Container(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: UygulamaRenkleri.kolayModSari, size: 28),
                    const SizedBox(width: 8),
                    Text('ONAYLANAN ÜRÜN', style: MetinStilleri.aciklama(renk: Colors.white70).copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _urunAdiDenetleyici.text,
                  style: MetinStilleri.kolayModBaslik(renk: Colors.white),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text('Kasa Fiyatı:', style: MetinStilleri.govde(renk: Colors.white70)),
                Text('${_seciliFiyat.toStringAsFixed(2)} ₺', style: MetinStilleri.kolayModDev()),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Adet Seçimi (Büyük Butonlar)
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KAÇ ADET ALIYORSUNUZ?', style: MetinStilleri.govdeKalin(renk: Colors.white)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _adet > 1 ? () => setState(() => _adet--) : null,
                      icon: const Icon(Icons.remove, size: 30),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E), foregroundColor: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$_adet', style: MetinStilleri.kolayModBaslik()),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _adet++),
                      icon: const Icon(Icons.add, size: 30),
                      style: IconButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari, foregroundColor: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 2 Büyük Aksiyon Butonu
          SizedBox(
            height: 72,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onOnaylandi({
                  'ad': _urunAdiDenetleyici.text,
                  'birimFiyat': _seciliFiyat,
                  'adet': _adet,
                  'resimYolu': widget.resimYolu,
                });
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.black, size: 30),
              label: Text('SEPETE EKLE (${(_seciliFiyat * _adet).toStringAsFixed(2)} ₺)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              onPressed: widget.onTekrarCek,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('TEKRAR ÇEK / FARKLI ÜRÜN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E)),
            ),
          ),
        ],
      ),
    );
  }
}
