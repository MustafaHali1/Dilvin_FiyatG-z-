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
    final profil = context.watch<ProfilYoneticisi>().profil;
    final isKoyu = profil.karanlikModAcik;
    final seciliFiyat = yonetici.seciliFiyat;
    final adaylar = yonetici.adayFiyatlar;

    final Color zemin = isKoyu ? const Color(0xFF0F172A) : UygulamaRenkleri.arkaPlan;
    final Color inputZemin = isKoyu ? const Color(0xFF1E293B) : Colors.white;
    final Color inputBorder = isKoyu ? const Color(0xFF334155) : UygulamaRenkleri.cizgi;
    final Color anaYazi = isKoyu ? Colors.white : Colors.black87;
    final Color altYazi = isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi;

    return Scaffold(
      backgroundColor: zemin,
      appBar: AppBar(
        title: Text('Fiyat Onayı', style: MetinStilleri.baslik2(renk: anaYazi)),
        backgroundColor: zemin,
        elevation: 0,
        iconTheme: IconThemeData(color: isKoyu ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            tooltip: 'Sesli Asistan',
            icon: Icon(
              yonetici.dinleniyor
                  ? Icons.mic
                  : (profil.sesliAsistanAcik
                      ? Icons.mic_none_rounded
                      : Icons.mic_off_rounded),
              color: yonetici.dinleniyor ? Colors.red : UygulamaRenkleri.anaZumrut,
            ),
            onPressed: () {
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
            icon: Icon(Icons.close_rounded, color: isKoyu ? Colors.white : null),
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
                color: isKoyu ? const Color(0xFF1E293B) : UygulamaRenkleri.anaAcik,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: UygulamaRenkleri.anaZumrut),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: UygulamaRenkleri.anaZumrut),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Etiket yapay zekâ ile taranıyor...',
                      style: TextStyle(
                        color: isKoyu ? Colors.white : UygulamaRenkleri.anaKoyu,
                        fontWeight: FontWeight.bold,
                      ),
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
              color: isKoyu ? const Color(0xFF1E293B) : UygulamaRenkleri.anaKoyu,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: isKoyu ? Border.all(color: const Color(0xFF334155)) : null,
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
            style: TextStyle(color: anaYazi),
            decoration: InputDecoration(
              labelText: 'Ürün Adı',
              labelStyle: TextStyle(color: altYazi),
              filled: true,
              fillColor: inputZemin,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: inputBorder),
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),

          // 5. Birim Fiyat Düzenleme Kutusu
          TextField(
            controller: yonetici.fiyatDenetleyici,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: anaYazi),
            onChanged: (val) {
              final d = double.tryParse(val.replaceAll(',', '.'));
              if (d != null) yonetici.fiyatSec(d);
            },
            decoration: InputDecoration(
              labelText: 'Birim Fiyat (₺)',
              labelStyle: TextStyle(color: altYazi),
              filled: true,
              fillColor: inputZemin,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: inputBorder),
              ),
            ),
          ),

          // 6. Algılanan Aday Fiyat Çipleri (Varsa)
          if (adaylar.length > 1) ...[
            const SizedBox(height: Olculer.boslukOrta),
            Text('Algılanan Diğer Fiyatlar:', style: MetinStilleri.aciklama(renk: altYazi)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: adaylar.map((f) {
                final secili = (seciliFiyat != null && (seciliFiyat - f).abs() < 0.01);
                return ChoiceChip(
                  label: Text('${f.toStringAsFixed(2)} ₺'),
                  selected: secili,
                  selectedColor: isKoyu ? UygulamaRenkleri.anaZumrut.withValues(alpha: 0.3) : UygulamaRenkleri.anaAcik,
                  backgroundColor: isKoyu ? const Color(0xFF1E293B) : null,
                  labelStyle: TextStyle(
                    color: secili
                        ? (isKoyu ? Colors.white : UygulamaRenkleri.anaKoyu)
                        : (isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.koyuYazi),
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
              color: inputZemin,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: inputBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adet Seçimi', style: MetinStilleri.govdeKalin(renk: anaYazi)),
                Row(
                  children: [
                    IconButton(
                      onPressed: yonetici.adet > 1 ? yonetici.adetAzalt : null,
                      icon: Icon(Icons.remove_circle_outline, color: isKoyu ? Colors.white70 : null),
                    ),
                    Text('${yonetici.adet}', style: MetinStilleri.baslik2(renk: anaYazi)),
                    IconButton(
                      onPressed: yonetici.adetArtir,
                      icon: Icon(Icons.add_circle_outline, color: isKoyu ? Colors.white70 : null),
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
