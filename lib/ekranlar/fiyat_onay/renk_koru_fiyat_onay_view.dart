import 'dart:io';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';

/// Renk Körü Modu - Fiyat Onay Ekranı (Stitch: renk_k_r_fiyat_onay birebir)
class RenkKoruFiyatOnayView extends StatefulWidget {
  final String? resimYolu;
  final ValueChanged<Map<String, dynamic>> onOnaylandi;
  final VoidCallback onTekrarCek;

  const RenkKoruFiyatOnayView({
    super.key,
    this.resimYolu,
    required this.onOnaylandi,
    required this.onTekrarCek,
  });

  @override
  State<RenkKoruFiyatOnayView> createState() => _RenkKoruFiyatOnayViewState();
}

class _RenkKoruFiyatOnayViewState extends State<RenkKoruFiyatOnayView> {
  final int _adet = 1;
  double _seciliFiyat = 24.90;
  final TextEditingController _urunAdiDenetleyici =
      TextEditingController(text: 'Sütaş Tam Yağlı Süt 1L');
  final TextEditingController _fiyatDenetleyici =
      TextEditingController(text: '24.90');

  @override
  void dispose() {
    _urunAdiDenetleyici.dispose();
    _fiyatDenetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const anaMavi = UygulamaRenkleri.renkKoruMavi;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Fiyat Onayı [Renk Güvenli]', style: MetinStilleri.baslik2(renk: anaMavi)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          if (widget.resimYolu != null && File(widget.resimYolu!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              child: Image.file(File(widget.resimYolu!), height: 140, fit: BoxFit.cover),
            ),
          const SizedBox(height: Olculer.boslukOrta),

          // Mavi Çerçeveli Onay Kartı
          Container(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: Border.all(color: anaMavi, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: anaMavi, size: 24),
                    SizedBox(width: 8),
                    Text('TESPİT EDİLEN ÜRÜN VE FİYAT', style: TextStyle(color: anaMavi, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_urunAdiDenetleyici.text, style: MetinStilleri.baslik1()),
                const SizedBox(height: 8),
                Text('${_seciliFiyat.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: anaMavi)),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          TextField(
            controller: _urunAdiDenetleyici,
            decoration: InputDecoration(
              labelText: 'Ürün Adı',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),
          TextField(
            controller: _fiyatDenetleyici,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final d = double.tryParse(val.replaceAll(',', '.'));
              if (d != null) setState(() => _seciliFiyat = d);
            },
            decoration: InputDecoration(
              labelText: 'Birim Fiyat (₺)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          Row(
            children: [
              Expanded(
                child: OzelButon(
                  metin: 'Tekrar Çek',
                  tip: ButonTipi.cizgili,
                  onPressed: widget.onTekrarCek,
                ),
              ),
              const SizedBox(width: Olculer.boslukOrta),
              Expanded(
                child: OzelButon(
                  metin: 'Sepete Ekle',
                  onPressed: () {
                    widget.onOnaylandi({
                      'ad': _urunAdiDenetleyici.text,
                      'birimFiyat': _seciliFiyat,
                      'adet': _adet,
                      'resimYolu': widget.resimYolu,
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
