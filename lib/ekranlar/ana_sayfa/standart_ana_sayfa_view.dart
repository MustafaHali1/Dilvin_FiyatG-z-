import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/urun_modeli.dart';
import 'bilesenler/butce_ozet_karti.dart';
import 'bilesenler/fis_karti.dart';

/// Standart Mod - Ana Sayfa (Stitch: ana_sayfa_standart_mod birebir)
class StandartAnaSayfaView extends StatefulWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const StandartAnaSayfaView({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  State<StandartAnaSayfaView> createState() => _StandartAnaSayfaViewState();
}

class _StandartAnaSayfaViewState extends State<StandartAnaSayfaView> {
  String _seciliFiltre = 'Tümü';
  String _arama = '';

  final filtreler = ['Tümü', 'Kasım 2026', 'Ekim 2026', 'Eylül 2026'];

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
    FisModeli(
      id: '3',
      aciklama: 'A101 Manav & Süt',
      marketAdi: 'A101',
      tarih: DateTime.now().subtract(const Duration(days: 7)),
      urunler: [
        const UrunModeli(id: '3', ad: 'Yumurta', birimFiyat: 64.90, adet: 1),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtrelenmis = ornekFisler.where((f) {
      if (_arama.isEmpty) return true;
      return f.aciklama.toLowerCase().contains(_arama.toLowerCase()) ||
          f.marketAdi.toLowerCase().contains(_arama.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // Üst Header
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
                    IconButton(
                      onPressed: widget.onSesliAsistanAc,
                      icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.anaZumrut, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.anaAcik,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onAyarlaraGit,
                      icon: const Icon(Icons.tune_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Bütçe Özet Kartı
            const ButceOzetKarti(harcanan: 3482.50, butce: 5000.00),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Arama Çubuğu
            TextField(
              onChanged: (val) => setState(() => _arama = val),
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
            const SizedBox(height: Olculer.boslukOrta),

            // Ay Filtreleme Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filtreler.map((filtre) {
                  final secili = _seciliFiltre == filtre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filtre),
                      selected: secili,
                      selectedColor: UygulamaRenkleri.anaAcik,
                      labelStyle: TextStyle(
                        color: secili ? UygulamaRenkleri.anaKoyu : UygulamaRenkleri.koyuYazi,
                        fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _seciliFiltre = filtre),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Büyük Yeni Alışveriş Başlat Butonu
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
            for (final fis in filtrelenmis) FisKarti(fis: fis),
          ],
        ),
      ),
    );
  }
}
