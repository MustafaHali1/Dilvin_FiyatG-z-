import 'dart:io';
import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/durum_rozeti.dart';

/// Yapay zeka veya OCR ile okunan fiyatin onaylandigi ara yuz
class FiyatOnayEkrani extends StatefulWidget {
  final String? resimYolu;
  final ValueChanged<Map<String, dynamic>> onOnaylandi;
  final VoidCallback onTekrarCek;

  const FiyatOnayEkrani({
    super.key,
    this.resimYolu,
    required this.onOnaylandi,
    required this.onTekrarCek,
  });

  @override
  State<FiyatOnayEkrani> createState() => _FiyatOnayEkraniState();
}

class _FiyatOnayEkraniState extends State<FiyatOnayEkrani> {
  int _adet = 1;
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
    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Fiyat Onayı', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // Çekilen Resim Önizlemesi (Varsa)
          if (widget.resimYolu != null && File(widget.resimYolu!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.file(
                  File(widget.resimYolu!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (widget.resimYolu != null) const SizedBox(height: Olculer.boslukOrta),

          // AI Tanima Sonuc Karti
          Container(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            decoration: BoxDecoration(
              color: UygulamaRenkleri.anaKoyu,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DurumRozeti.yapayZeka(),
                    DurumRozeti.indirimli(),
                  ],
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text(
                  'TESPİT EDİLEN ÜRÜN',
                  style: MetinStilleri.aciklama(renk: Colors.white70),
                ),
                Text(
                  _urunAdiDenetleyici.text,
                  style: MetinStilleri.baslik1(renk: Colors.white),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Row(
                  children: [
                    Text(
                      '${_seciliFiyat.toStringAsFixed(2)} ₺',
                      style: MetinStilleri.devBaslik(renk: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '29,90 ₺',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withValues(alpha: 0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Ürün Adı ve Fiyat Düzenleme Alanı
          TextField(
            controller: _urunAdiDenetleyici,
            decoration: InputDecoration(
              labelText: 'Ürün Adı',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Adet Secimi
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: UygulamaRenkleri.cizgi),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adet Seçimi', style: MetinStilleri.govdeKalin()),
                Row(
                  children: [
                    IconButton(
                      onPressed: _adet > 1 ? () => setState(() => _adet--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_adet', style: MetinStilleri.baslik2()),
                    IconButton(
                      onPressed: () => setState(() => _adet++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Alt Aksiyon Butonlari
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
