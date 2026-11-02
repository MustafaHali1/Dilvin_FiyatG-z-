import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/fiyat_onay_yoneticisi.dart';

/// Kolay Mod - Fiyat Onay Ekranı (Stitch: kolay_mod_fiyat_onay birebir)
class KolayModFiyatOnayView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final yonetici = context.watch<FiyatOnayYoneticisi>();
    final seciliFiyat = yonetici.seciliFiyat;
    final adaylar = yonetici.adayFiyatlar;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('FİYAT VE ÜRÜN ONAYI', style: MetinStilleri.kolayModBaslik()),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              yonetici.dinleniyor ? Icons.mic : Icons.mic_none_rounded,
              color: yonetici.dinleniyor ? Colors.red : const Color(0xFFFFD700),
              size: 32,
            ),
            onPressed: () {
              yonetici.sesliKomutDinle(
                onOnayla: () {
                  final veri = yonetici.onayVerisiHazirla();
                  if (veri != null) onOnaylandi(veri);
                },
                onIptal: onTekrarCek,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // 1. Resim Varsa
          if (resimYolu != null && File(resimYolu!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.file(File(resimYolu!), fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 2. Tarama Bildirimi
          if (yonetici.yukleniyor) ...[
            Container(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 2),
              ),
              child: const Row(
                children: [
                  CircularProgressIndicator(color: UygulamaRenkleri.kolayModSari),
                  SizedBox(width: 16),
                  Text(
                    'Etiket Okunuyor...',
                    style: TextStyle(color: UygulamaRenkleri.kolayModSari, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),
          ],

          // 3. Devasa Sarı Kutu: Ürün ve Fiyat
          Container(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            decoration: BoxDecoration(
              color: UygulamaRenkleri.kolayModSari,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.black, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'ALGILANAN BİLGİ',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text(
                  yonetici.urunAdiDenetleyici.text.isNotEmpty
                      ? yonetici.urunAdiDenetleyici.text
                      : 'Ürün Adı',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Text(
                  seciliFiyat != null
                      ? '${seciliFiyat.toStringAsFixed(2)} ₺'
                      : 'Fiyat Bekleniyor',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 3.5. Devasa Sesli Asistan Butonu (Kolay Mod Özel)
          InkWell(
            onTap: () {
              yonetici.sesliKomutDinle(
                onOnayla: () {
                  final veri = yonetici.onayVerisiHazirla();
                  if (veri != null) onOnaylandi(veri);
                },
                onIptal: onTekrarCek,
              );
            },
            borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: yonetici.dinleniyor ? Colors.red.shade900 : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                border: Border.all(
                  color: yonetici.dinleniyor ? Colors.red : UygulamaRenkleri.kolayModSari,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    yonetici.dinleniyor ? Icons.mic : Icons.mic_none_rounded,
                    color: yonetici.dinleniyor ? Colors.white : UygulamaRenkleri.kolayModSari,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      yonetici.dinleniyor ? 'DİNLİYOR... ("Sepete Ekle" deyin)' : 'SESLE ONAYLA VEYA ADET SÖYLE',
                      style: TextStyle(
                        color: yonetici.dinleniyor ? Colors.white : UygulamaRenkleri.kolayModSari,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 4. Alternatif Fiyat Çipleri (Varsa)
          if (adaylar.length > 1) ...[
            Text('DİĞER BULUNAN FİYATLAR:', style: MetinStilleri.kolayModGovde(renk: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: adaylar.map((f) {
                final secili = (seciliFiyat != null && (seciliFiyat - f).abs() < 0.01);
                return ActionChip(
                  label: Text('${f.toStringAsFixed(2)} ₺', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secili ? Colors.black : Colors.white)),
                  backgroundColor: secili ? UygulamaRenkleri.kolayModSari : const Color(0xFF2A2A2A),
                  side: BorderSide(color: secili ? Colors.white : Colors.white38, width: 2),
                  onPressed: () => yonetici.fiyatSec(f),
                );
              }).toList(),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),
          ],

          // 5. Devasa Adet Sayacı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk, vertical: Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ADET', style: MetinStilleri.kolayModBaslik()),
                Row(
                  children: [
                    IconButton(
                      onPressed: yonetici.adet > 1 ? yonetici.adetAzalt : null,
                      icon: const Icon(Icons.remove_circle, color: UygulamaRenkleri.kolayModSari, size: 44),
                    ),
                    const SizedBox(width: 8),
                    Text('${yonetici.adet}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: yonetici.adetArtir,
                      icon: const Icon(Icons.add_circle, color: UygulamaRenkleri.kolayModSari, size: 44),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // 6. Büyük Ekle ve Yeniden Çek Butonları
          OzelButon(
            metin: 'SEPETE EKLE',
            ikon: Icons.shopping_cart_rounded,
            onPressed: () {
              final veri = yonetici.onayVerisiHazirla();
              if (veri != null) {
                onOnaylandi(veri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen geçerli bir fiyat giriniz.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: Olculer.boslukOrta),
          OzelButon(
            metin: 'YENİDEN ÇEK',
            tip: ButonTipi.cizgili,
            onPressed: onTekrarCek,
          ),
        ],
      ),
    );
  }
}
