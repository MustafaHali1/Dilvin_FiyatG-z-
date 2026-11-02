import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../../yoneticiler/kullanici_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../fis_detay/fis_detay_ekrani.dart';
import '../fisler/tum_fisler_ekrani.dart';
import 'bilesenler/butce_ozet_karti.dart';
import 'bilesenler/fis_karti.dart';

/// Renk Körü Modu - Ana Sayfa
/// Standart mod ile %100 birebir aynı zengin bileşen yapısına sahiptir.
/// Tüm renkler kullanıcının seçtiği Okabe-Ito paleti ile dinamik olarak boyanır (Yeşil veya Kırmızı yasak renkler elenir).
class RenkKoruAnaSayfaView extends StatefulWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const RenkKoruAnaSayfaView({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  State<RenkKoruAnaSayfaView> createState() => _RenkKoruAnaSayfaViewState();
}

class _RenkKoruAnaSayfaViewState extends State<RenkKoruAnaSayfaView> {
  String _arama = '';
  bool _gecmisFislerAcik = true;
  int _seciliFiltreIndex = 0;

  final List<String> _filtreler = ['Tümü', 'Kasım 2026', 'Ekim 2026'];

  @override
  Widget build(BuildContext context) {
    final fisYoneticisi = context.watch<FisYoneticisi>();
    final kullaniciYoneticisi = context.watch<KullaniciYoneticisi>();
    final profilYoneticisi = context.watch<ProfilYoneticisi>();

    final palet = RenkKorluguPaleti.getir(profilYoneticisi.profil.renkKorluguTuru);
    final kullaniciAdi = kullaniciYoneticisi.kullanici.adSoyad.split(' ').first;
    final fisler = fisYoneticisi.fisler;

    final filtrelenmis = fisler.where((f) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Merhaba $kullaniciAdi 👋', style: MetinStilleri.baslik1()),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: palet.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Renk Güvenli Mod (${palet.turAdi})',
                            style: MetinStilleri.aciklama().copyWith(
                              fontWeight: FontWeight.bold,
                              color: palet.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const KullaniciProfiliEkrani(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: palet.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                  ),
                  tooltip: 'Kullanıcı Profili',
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Canlı SQLite Bütçe Özet Kartı (Palet Rengi Vurgulu)
            ButceOzetKarti(
              harcanan: fisYoneticisi.buAyHarcama,
              butce: profilYoneticisi.profil.aylikButce,
              fisSayisi: fisYoneticisi.fisSayisi,
              buHaftaHarcanan: fisYoneticisi.buHaftaHarcama,
              vurguRengi: palet.primary,
              onKayitliFisTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TumFislerEkrani(
                      baslik: 'Tüm Kayıtlı Fişler',
                      sadeceHaftalik: false,
                    ),
                  ),
                );
              },
              onBuHaftaTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TumFislerEkrani(
                      baslik: 'Bu Haftanın Fişleri',
                      sadeceHaftalik: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Arama Çubuğu
            TextField(
              onChanged: (val) => setState(() => _arama = val.trim()),
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

            // Filtre Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filtreler.length, (index) {
                  final secili = _seciliFiltreIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filtreler[index]),
                      selected: secili,
                      selectedColor: palet.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: secili ? palet.primary : UygulamaRenkleri.koyuYazi,
                        fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: secili ? palet.primary : UygulamaRenkleri.cizgi,
                      ),
                      backgroundColor: Colors.white,
                      onSelected: (val) {
                        if (val) setState(() => _seciliFiltreIndex = index);
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Büyük Yeni Alışveriş Başlat Butonu (Palet Rengi)
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              renk: palet.primary,
              onPressed: widget.onKameraAc,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Geçmiş Fişler Başlığı (Açılır-Kapanır Tırnaklı Accordion)
            InkWell(
              onTap: () => setState(() => _gecmisFislerAcik = !_gecmisFislerAcik),
              borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Geçmiş Fişler', style: MetinStilleri.baslik2()),
                        const SizedBox(width: 6),
                        Icon(
                          _gecmisFislerAcik ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: palet.primary,
                          size: 28,
                        ),
                      ],
                    ),
                    Text('${filtrelenmis.length} Fiş', style: MetinStilleri.aciklama()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            if (_gecmisFislerAcik) ...[
              if (filtrelenmis.isEmpty)
                Container(
                  padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    border: Border.all(color: UygulamaRenkleri.cizgi),
                  ),
                  child: Center(
                    child: Text('Kayıtlı fiş bulunmuyor.', style: MetinStilleri.aciklama()),
                  ),
                )
              else ...[
                // En fazla son 3 fiş
                for (final fis in filtrelenmis.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Olculer.boslukOrta),
                    child: FisKarti(
                      fis: fis,
                      vurguRengi: palet.primary,
                      onDokunuldu: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FisDetayEkrani(fis: fis),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: Olculer.boslukKucuk),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TumFislerEkrani(baslik: 'Tüm Geçmiş Fişler'),
                      ),
                    );
                  },
                  icon: Icon(Icons.receipt_long_rounded, color: palet.primary),
                  label: Text(
                    'Tüm Fişleri Gör',
                    style: TextStyle(color: palet.primary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palet.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
