import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/fiyat_onay_yoneticisi.dart';

/// Renk Körü Modu - Fiyat Onay Ekranı (Stitch: renk_k_r_fiyat_onay birebir)
class RenkKoruFiyatOnayView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;
    final palet = RenkKorluguPaleti.getir(profil.renkKorluguTuru);
    final anaRenk = palet.primary;
    final ikincilRenk = palet.secondary;

    final yonetici = context.watch<FiyatOnayYoneticisi>();
    final seciliFiyat = yonetici.seciliFiyat;
    final adaylar = yonetici.adayFiyatlar;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Fiyat Onayı [${palet.turAdi}]', style: MetinStilleri.baslik2(renk: anaRenk)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: anaRenk),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // 1. Resim Varsa
          if (resimYolu != null && File(resimYolu!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.file(File(resimYolu!), fit: BoxFit.cover),
              ),
            ),
          if (resimYolu != null) const SizedBox(height: Olculer.boslukOrta),

          // 2. Tarama Durumu
          if (yonetici.yukleniyor) ...[
            Container(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: anaRenk.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: anaRenk, width: 2),
              ),
              child: Row(
                children: [
                  CircularProgressIndicator(color: anaRenk),
                  const SizedBox(width: 12),
                  Text(
                    'Etiket Taranıyor...',
                    style: TextStyle(color: anaRenk, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),
          ],

          // 3. Renk Körü Güvenli Kutu
          Container(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: Border.all(color: anaRenk, width: 3),
              boxShadow: [
                BoxShadow(
                  color: anaRenk.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: anaRenk,
                        borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('AI ALGILADI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (adaylar.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ikincilRenk.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                          border: Border.all(color: ikincilRenk),
                        ),
                        child: Text('Çoklu Fiyat', style: TextStyle(color: ikincilRenk, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text('TESPİT EDİLEN ÜRÜN', style: MetinStilleri.aciklama()),
                Text(
                  yonetici.urunAdiDenetleyici.text.isNotEmpty
                      ? yonetici.urunAdiDenetleyici.text
                      : 'Ürün Adı Bekleniyor',
                  style: MetinStilleri.baslik1(renk: anaRenk),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text(
                  seciliFiyat != null
                      ? '${seciliFiyat.toStringAsFixed(2)} ₺'
                      : 'Fiyat Bekleniyor',
                  style: MetinStilleri.devBaslik(renk: anaRenk),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 4. Form Alanları
          TextField(
            controller: yonetici.urunAdiDenetleyici,
            decoration: InputDecoration(
              labelText: 'Ürün Adı',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: anaRenk, width: 2),
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),
          TextField(
            controller: yonetici.fiyatDenetleyici,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final d = double.tryParse(val.replaceAll(',', '.'));
              if (d != null) yonetici.fiyatSec(d);
            },
            decoration: InputDecoration(
              labelText: 'Birim Fiyat (₺)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: anaRenk, width: 2),
              ),
            ),
          ),

          // 5. Aday Fiyat Çipleri (Varsa)
          if (adaylar.length > 1) ...[
            const SizedBox(height: Olculer.boslukOrta),
            Text('Algılanan Diğer Fiyatlar:', style: MetinStilleri.aciklama()),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: adaylar.map((f) {
                final secili = (seciliFiyat != null && (seciliFiyat - f).abs() < 0.01);
                return ChoiceChip(
                  label: Text('${f.toStringAsFixed(2)} ₺'),
                  selected: secili,
                  selectedColor: anaRenk.withValues(alpha: 0.2),
                  side: BorderSide(color: secili ? anaRenk : Colors.grey.shade400, width: 2),
                  labelStyle: TextStyle(
                    color: secili ? anaRenk : Colors.black87,
                    fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => yonetici.fiyatSec(f),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: Olculer.boslukBuyuk),

          // 6. Adet
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adet', style: MetinStilleri.govdeKalin()),
                Row(
                  children: [
                    IconButton(
                      onPressed: yonetici.adet > 1 ? yonetici.adetAzalt : null,
                      icon: Icon(Icons.remove_circle_outline, color: anaRenk),
                    ),
                    Text('${yonetici.adet}', style: MetinStilleri.baslik2()),
                    IconButton(
                      onPressed: yonetici.adetArtir,
                      icon: Icon(Icons.add_circle_outline, color: anaRenk),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 7. Butonlar
          Row(
            children: [
              Expanded(
                child: OzelButon(
                  metin: 'Tekrar Çek',
                  tip: ButonTipi.cizgili,
                  onPressed: onTekrarCek,
                ),
              ),
              const SizedBox(width: Olculer.boslukOrta),
              Expanded(
                child: OzelButon(
                  metin: 'Sepete Ekle',
                  renk: anaRenk,
                  onPressed: () {
                    final veri = yonetici.onayVerisiHazirla();
                    if (veri != null) {
                      onOnaylandi(veri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen geçerli bir ürün adı ve fiyat giriniz.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
