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
  String _arama = '';
  bool _gecmisFislerAcik = true;

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
            // Üst Header (Taşmasız, yalın ve modern profil başlığı)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Merhaba $kullaniciAdi 👋', style: MetinStilleri.baslik1()),
                      const SizedBox(height: 2),
                      Text(
                        'Alışveriş harcamalarını kolayca takip et',
                        style: MetinStilleri.aciklama(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Canlı SQLite Bütçe Özet Kartı (Kayıtlı Fiş ve Bu Hafta Tıklanabilir)
            ButceOzetKarti(
              harcanan: fisYoneticisi.donemHarcamasi(profilYoneticisi.profil),
              butce: profilYoneticisi.profil.aylikButce,
              fisSayisi: fisYoneticisi.fisSayisi,
              buHaftaHarcanan: fisYoneticisi.buHaftaHarcama,
              donemEtiketi: profilYoneticisi.profil.butceDonemiFormatli,
              kalanGun: profilYoneticisi.profil.kalanGunSayisi,
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
                hintText: 'Fiş veya market ara...',
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

            // Büyük Yeni Alışveriş Başlat Butonu
            OzelButon(
              metin: 'Yeni Alışveriş Başlat',
              ikon: Icons.camera_alt_rounded,
              onPressed: widget.onKameraAc,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // Geçmiş Fişler Başlığı (Açılır-Kapanır Tırnaklı Accordion)
            InkWell(
              onTap: () => setState(() => _gecmisFislerAcik = !_gecmisFislerAcik),
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Text('Geçmiş Fişler', style: MetinStilleri.baslik2()),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _gecmisFislerAcik ? 0.0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: UygulamaRenkleri.anaZumrut,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filtrelenmis.length} Fiş',
                      style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu),
                    ),
                  ],
                ),
              ),
            ),

            // Fiş Listesi (Sadece Son 3 Fiş veya Boş Durum)
            if (_gecmisFislerAcik) ...[
              const SizedBox(height: Olculer.boslukOrta),
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
              else ...[
                // Sadece son 3 fişi göster
                for (final fis in filtrelenmis.take(3))
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
                if (filtrelenmis.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TumFislerEkrani(
                                baslik: 'Tüm Kayıtlı Fişler',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text('Tüm Fişleri Gör (${filtrelenmis.length})'),
                        style: TextButton.styleFrom(
                          foregroundColor: UygulamaRenkleri.anaZumrut,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
