import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../bilesenler/durum_rozeti.dart';
import '../../yoneticiler/fiyat_onay_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';

/// Standart Mod - Fiyat Onay Ekranı (Stitch: fiyat_onay_s_ta_s_t_1l birebir)
class StandartFiyatOnayView extends StatelessWidget {
  final String? resimYolu;
  final ValueChanged<Map<String, dynamic>> onOnaylandi;
  final VoidCallback onTekrarCek;

  const StandartFiyatOnayView({
    super.key,
    this.resimYolu,
    required this.onOnaylandi,
    required this.onTekrarCek,
  });

  @override
  Widget build(BuildContext context) {
    final yonetici = context.watch<FiyatOnayYoneticisi>();
    final seciliFiyat = yonetici.seciliFiyat;
    final adaylar = yonetici.adayFiyatlar;

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Fiyat Onayı', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sesli Asistan',
            icon: Icon(
              yonetici.dinleniyor
                  ? Icons.mic
                  : (context.watch<ProfilYoneticisi>().profil.sesliAsistanAcik
                      ? Icons.mic_none_rounded
                      : Icons.mic_off_rounded),
              color: yonetici.dinleniyor ? Colors.red : UygulamaRenkleri.anaZumrut,
            ),
            onPressed: () {
              final profil = context.read<ProfilYoneticisi>().profil;
              if (!profil.sesliAsistanAcik) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesli Asistan ayarlardan kapalı.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              yonetici.sesliKomutDinle(
                onOnayla: () {
                  final veri = yonetici.onayVerisiHazirla();
                  if (veri != null) onOnaylandi(veri);
                },
                onIptal: onTekrarCek,
              );
            },
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // 1. Çekilen Fotoğraf Önizlemesi
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

          // 2. OCR Tarama Durumu Göstergesi
          if (yonetici.yukleniyor) ...[
            Container(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: UygulamaRenkleri.anaAcik,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: UygulamaRenkleri.anaZumrut),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: UygulamaRenkleri.anaKoyu),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Etiket yapay zekâ ile taranıyor...',
                      style: TextStyle(color: UygulamaRenkleri.anaKoyu, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),
          ],

          // 3. Tespit Edilen Ürün ve Fiyat Vurgu Kartı
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
                    if (adaylar.length > 1) DurumRozeti.indirimli(),
                  ],
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text('TESPİT EDİLEN ÜRÜN', style: MetinStilleri.aciklama(renk: Colors.white70)),
                Text(
                  yonetici.urunAdiDenetleyici.text.isNotEmpty
                      ? yonetici.urunAdiDenetleyici.text
                      : 'Ürün Adı Bekleniyor',
                  style: MetinStilleri.baslik1(renk: Colors.white),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      seciliFiyat != null
                          ? '${seciliFiyat.toStringAsFixed(2)} ₺'
                          : 'Fiyat Bekleniyor',
                      style: MetinStilleri.devBaslik(renk: Colors.white),
                    ),
                    if (adaylar.length > 1) ...[
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${adaylar[1].toStringAsFixed(2)} ₺',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.6),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 4. Ürün Adı Düzenleme Kutusu
          TextField(
            controller: yonetici.urunAdiDenetleyici,
            decoration: InputDecoration(
              labelText: 'Ürün Adı',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),

          // 5. Birim Fiyat Düzenleme Kutusu
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
            ),
          ),

          // 6. Algılanan Aday Fiyat Çipleri (Varsa)
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
                  selectedColor: UygulamaRenkleri.anaAcik,
                  labelStyle: TextStyle(
                    color: secili ? UygulamaRenkleri.anaKoyu : UygulamaRenkleri.koyuYazi,
                    fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => yonetici.fiyatSec(f),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: Olculer.boslukBuyuk),

          // 7. Adet Seçimi
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
                      onPressed: yonetici.adet > 1 ? yonetici.adetAzalt : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${yonetici.adet}', style: MetinStilleri.baslik2()),
                    IconButton(
                      onPressed: yonetici.adetArtir,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 8. Alt Aksiyon Butonları
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
                  onPressed: () {
                    final veri = yonetici.onayVerisiHazirla();
                    if (veri != null) {
                      onOnaylandi(veri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen geçerli bir ürün adı ve fiyat giriniz.'),
                          backgroundColor: UygulamaRenkleri.tehlikeKirmizi,
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
