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

  @override
  Widget build(BuildContext context) {
    final fisYoneticisi = context.watch<FisYoneticisi>();
    final kullaniciYoneticisi = context.watch<KullaniciYoneticisi>();
    final profilYoneticisi = context.watch<ProfilYoneticisi>();

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Merhaba $kullaniciAdi 👋', style: MetinStilleri.baslik1()),
                    const SizedBox(height: 2),
                    Text(
                      'Alışveriş harcamalarını kolayca takip et',
                      style: MetinStilleri.aciklama(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Profil Butonu
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const KullaniciProfiliEkrani(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_rounded, color: UygulamaRenkleri.anaKoyu, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.anaAcik,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Olculer.yariCapOrta)),
                      ),
                      tooltip: 'Kullanıcı Profili',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onSesliAsistanAc,
                      icon: const Icon(Icons.mic_rounded, color: UygulamaRenkleri.anaZumrut, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
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

            // Canlı SQLite Bütçe Özet Kartı
            ButceOzetKarti(
              harcanan: fisYoneticisi.buAyHarcama,
              butce: profilYoneticisi.profil.aylikButce,
            ),
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

            // Fiş Listesi veya Boş Durum
            if (filtrelenmis.isEmpty)
              Container(
                padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  border: Border.all(color: UygulamaRenkleri.cizgi),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48, color: UygulamaRenkleri.griYazi),
                    const SizedBox(height: 8),
                    Text('Henüz Kayıtlı Fiş Yok', style: MetinStilleri.govdeKalin()),
                    const SizedBox(height: 4),
                    Text(
                      'Sepeti tamamlayıp ilk alışveriş fişinizi kaydedin.',
                      style: MetinStilleri.aciklama(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              for (final fis in filtrelenmis)
                FisKarti(
                  fis: fis,
                  onDokunuldu: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FisDetayEkrani(fis: fis),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
