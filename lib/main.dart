import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sabitler/tema_fabrikasi.dart';
import 'servisler/kamera_servisi.dart';
import 'yoneticiler/sepet_yoneticisi.dart';
import 'yoneticiler/profil_yoneticisi.dart';
import 'ekranlar/onboarding/onboarding_ekrani.dart';
import 'ekranlar/onboarding/okuma_testi_ekrani.dart';
import 'ekranlar/onboarding/renk_korlugu_secim_ekrani.dart';
import 'ekranlar/onboarding/renk_testi_sorusu_ekrani.dart';
import 'ekranlar/ana_sayfa/ana_sayfa_ekrani.dart';
import 'ekranlar/sepet/sepet_ekrani.dart';
import 'ekranlar/kamera/kamera_tarayici_ekrani.dart';
import 'ekranlar/fiyat_onay/fiyat_onay_ekrani.dart';
import 'ekranlar/fis_detay/fis_detay_ekrani.dart';
import 'ekranlar/ayarlar/ayarlar_ekrani.dart';
import 'ekranlar/kamera/gorme_engelli_radar_kamera_view.dart';
import 'ekranlar/sepet/gorme_engelli_sepet_view.dart';
import 'ekranlar/sesli_asistan/sesli_asistan_diyalog_ekrani.dart';
import 'bilesenler/sesli_asistan_sayfasi.dart';
import 'modeller/fis_modeli.dart';
import 'modeller/urun_modeli.dart';
import 'modeller/profil_modeli.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KameraServisi.baslat();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfilYoneticisi()),
        ChangeNotifierProvider(create: (_) => SepetYoneticisi()),
      ],
      child: const FiyatGozUygulamasi(),
    ),
  );
}

class FiyatGozUygulamasi extends StatelessWidget {
  const FiyatGozUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilYoneticisi>().profil;

    return MaterialApp(
      title: 'FiyatGöz',
      debugShowCheckedModeBanner: false,
      theme: TemaFabrikasi.olustur(profil),
      home: const UygulamaGirisKontrolcusu(),
    );
  }
}

/// Ilk acilista Onboarding ve Test akislarini yoneten ara katman
class UygulamaGirisKontrolcusu extends StatelessWidget {
  const UygulamaGirisKontrolcusu({super.key});

  @override
  Widget build(BuildContext context) {
    final yonetici = context.watch<ProfilYoneticisi>();

    if (!yonetici.yuklendi) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!yonetici.kurulumTamamlandi) {
      return OnboardingEkrani(
        onTamamlandi: () {
          final profil = yonetici.profil;
          if (profil.profilTuru == ProfilTuru.kolayMod) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OkumaTestiEkrani(
                  onSecildi: (boyut) {
                    Navigator.of(context).pop();
                    yonetici.kurulumTamamlandiAyarla(true);
                  },
                ),
              ),
            );
          } else if (profil.profilTuru == ProfilTuru.renkKoruModu) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RenkKorluguSecimEkrani(
                  onSecildi: (tur) {
                    yonetici.renkKorluguTuruAyarla(tur);
                    Navigator.of(context).pop();
                    yonetici.kurulumTamamlandiAyarla(true);
                  },
                  onTestBaslat: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RenkTestiSorusuEkrani(
                          onTestTamamlandi: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            yonetici.kurulumTamamlandiAyarla(true);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            yonetici.kurulumTamamlandiAyarla(true);
          }
        },
      );
    }

    return const AnaGezintiIskeleti();
  }
}

/// Sayfalar arasi alt gezinmeyi saglayan temiz navigasyon sinifi
class AnaGezintiIskeleti extends StatefulWidget {
  const AnaGezintiIskeleti({super.key});

  @override
  State<AnaGezintiIskeleti> createState() => _AnaGezintiIskeletiState();
}

class _AnaGezintiIskeletiState extends State<AnaGezintiIskeleti> {
  int _seciliSayfa = 0;

  @override
  Widget build(BuildContext context) {
    final sepet = context.watch<SepetYoneticisi>();
    final profil = context.watch<ProfilYoneticisi>().profil;

    // Görme Engelli Modu: Kendi dev taktil 3 butonlu alt navigasyonuna sahiptir
    if (profil.profilTuru == ProfilTuru.gormeEngelliModu) {
      if (_seciliSayfa == 0) {
        return GormeEngelliRadarKameraView(
          cameraController: null,
          onFotoCek: () => _kameraSayfasiniAc(context),
          onKapat: () => setState(() => _seciliSayfa = 2),
        );
      } else if (_seciliSayfa == 1) {
        return const GormeEngelliSepetView();
      } else {
        return const AyarlarEkrani();
      }
    }

    final sayfalar = [
      AnaSayfaEkrani(
        onKameraAc: () => _kameraSayfasiniAc(context),
        onSepeteGit: () => setState(() => _seciliSayfa = 1),
        onSesliAsistanAc: () => _sesliAsistaniAc(context),
        onAyarlaraGit: () => setState(() => _seciliSayfa = 2),
      ),
      SepetEkrani(
        onUrunEkle: () => _kameraSayfasiniAc(context),
        onAlisverisiBitir: () => _fisDetaySayfasiniAc(context, sepet),
      ),
      const AyarlarEkrani(),
    ];

    return Scaffold(
      body: sayfalar[_seciliSayfa],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliSayfa,
        onDestinationSelected: (index) => setState(() => _seciliSayfa = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${sepet.toplamUrunAdedi}'),
              isLabelVisible: sepet.toplamUrunAdedi > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('${sepet.toplamUrunAdedi}'),
              isLabelVisible: sepet.toplamUrunAdedi > 0,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Sepet',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  void _kameraSayfasiniAc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KameraTarayiciEkrani(
          onKapat: () => Navigator.of(context).pop(),
          onFotoCekildi: (resimYolu) {
            Navigator.of(context).pop();
            _fiyatOnaySayfasiniAc(context, resimYolu);
          },
        ),
      ),
    );
  }

  void _fiyatOnaySayfasiniAc(BuildContext context, String resimYolu) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FiyatOnayEkrani(
          resimYolu: resimYolu,
          onTekrarCek: () {
            Navigator.of(context).pop();
            _kameraSayfasiniAc(context);
          },
          onOnaylandi: (veri) {
            final yeniUrun = UrunModeli(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              ad: veri['ad'] as String,
              birimFiyat: veri['birimFiyat'] as double,
              adet: veri['adet'] as int,
              gorselYolu: veri['resimYolu'] as String?,
              yapayZekaIleTanindi: true,
            );
            context.read<SepetYoneticisi>().urunEkle(yeniUrun);
            Navigator.of(context).pop();
            setState(() => _seciliSayfa = 1); // Sepete gec
          },
        ),
      ),
    );
  }

  void _fisDetaySayfasiniAc(BuildContext context, SepetYoneticisi sepet) {
    final ornekFis = FisModeli(
      id: 'FG-84920',
      aciklama: 'Migros Haftalık Alışveriş',
      tarih: DateTime.now(),
      urunler: sepet.urunler,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FisDetayEkrani(
          fis: ornekFis,
          onPaylas: () {},
          onSesliOku: () {},
        ),
      ),
    );
  }

  void _sesliAsistaniAc(BuildContext context) {
    final profil = context.read<ProfilYoneticisi>().profil;
    if (profil.profilTuru == ProfilTuru.gormeEngelliModu) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SesliAsistanDiyalogEkrani(),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SesliAsistanSayfasi(
        onHizliKomut: (komut) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
