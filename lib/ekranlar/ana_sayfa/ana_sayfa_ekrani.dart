import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/urun_modeli.dart';
import 'bilesenler/butce_ozet_karti.dart';
import 'bilesenler/fis_karti.dart';

/// Ana Sayfa (Tasarim sistemine tam uyumlu temiz ekran)
class AnaSayfaEkrani extends StatefulWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const AnaSayfaEkrani({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  State<AnaSayfaEkrani> createState() => _AnaSayfaEkraniState();
}

class _AnaSayfaEkraniState extends State<AnaSayfaEkrani> {
  String _aramaMetni = '';

  @override
  Widget build(BuildContext context) {
    final ornekFisler = [
      FisModeli(
        id: '1',
        aciklama: 'Migros Haftalık Alışveriş',
        marketAdi: 'Migros',
        tarih: DateTime.now(),
        urunler: [
          const UrunModeli(id: '1', ad: 'Süt', birimFiyat: 24.90, adet: 2),
        ],
      ),
      FisModeli(
        id: '2',
        aciklama: 'BİM Temizlik ve Kahvaltı',
        marketAdi: 'BİM',
        tarih: DateTime.now().subtract(const Duration(days: 3)),
        urunler: [
          const UrunModeli(id: '2', ad: 'Peynir', birimFiyat: 148.70, adet: 1),
        ],
      ),
    ];

    final filtrelenmis = ornekFisler.where((f) {
      if (_aramaMetni.isEmpty) return true;
      return f.aciklama.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          f.marketAdi.toLowerCase().contains(_aramaMetni.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // Üst Bar: Merhaba + Sesli Asistan + Ayarlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Merhaba 👋', style: MetinStilleri.baslik1()),
                    const SizedBox(height: 2),
                    Text(
                      'Alışveriş harcamalarını kolayca takip et',
                      style: MetinStilleri.aciklama(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Şık üst mikrofon butonu (Diğer butonların üzerini kapatmaz!)
                    IconButton(
                      onPressed: widget.onSesliAsistanAc,
                      icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.anaZumrut, size: 26),
                      tooltip: 'Sesli Asistan',
                      style: IconButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.anaAcik,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onAyarlaraGit,
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Ayarlar',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Bütçe Özet Kartı
            const ButceOzetKarti(
              harcanan: 3482.50,
              butce: 5000.00,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Arama Çubuğu
            TextField(
              onChanged: (val) => setState(() => _aramaMetni = val),
              decoration: InputDecoration(
                hintText: 'Fiş ara (market, ürün)...',
                prefixIcon: const Icon(Icons.search_rounded, color: UygulamaRenkleri.griYazi),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  borderSide: const BorderSide(color: UygulamaRenkleri.cizgi),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  borderSide: const BorderSide(color: UygulamaRenkleri.cizgi),
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Hızlı Kamera Başlat Butonu
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              onPressed: widget.onKameraAc,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Geçmiş Fişler Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Geçmiş Fişler', style: MetinStilleri.baslik2()),
                Text('${filtrelenmis.length} Fiş', style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu)),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // Fiş Listesi
            if (filtrelenmis.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                child: Center(
                  child: Text(
                    '"$_aramaMetni" için fiş bulunamadı',
                    style: MetinStilleri.aciklama(),
                  ),
                ),
              )
            else
              for (final fis in filtrelenmis) FisKarti(fis: fis),
          ],
        ),
      ),
    );
  }
}
