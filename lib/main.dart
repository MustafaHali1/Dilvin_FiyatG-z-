import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sabitler/uygulama_renkleri.dart';
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
import 'bilesenler/sesli_asistan_sayfasi.dart';
import 'modeller/fis_modeli.dart';
import 'modeller/profil_modeli.dart';

void main() {
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
    return MaterialApp(
      title: 'FiyatGöz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: UygulamaRenkleri.anaZumrut,
        scaffoldBackgroundColor: UygulamaRenkleri.arkaPlan,
      ),
      home: const UygulamaGirisKontrolcusu(),
    );
  }
}

/// Ilk acilista Onboarding ve Test akislarini yoneten ara katman
class UygulamaGirisKontrolcusu extends StatefulWidget {
  const UygulamaGirisKontrolcusu({super.key});

  @override
  State<UygulamaGirisKontrolcusu> createState() => _UygulamaGirisKontrolcusuState();
}

class _UygulamaGirisKontrolcusuState extends State<UygulamaGirisKontrolcusu> {
  bool _kurulumTamamlandi = false;

  @override
  Widget build(BuildContext context) {
    if (!_kurulumTamamlandi) {
      return OnboardingEkrani(
        onTamamlandi: () {
          final profil = context.read<ProfilYoneticisi>().profil;
          if (profil.profilTuru == ProfilTuru.kolayMod) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OkumaTestiEkrani(
                  onSecildi: (boyut) {
                    Navigator.of(context).pop();
                    setState(() => _kurulumTamamlandi = true);
                  },
                ),
              ),
            );
          } else if (profil.profilTuru == ProfilTuru.renkKoruModu) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RenkKorluguSecimEkrani(
                  onSecildi: (tur) {
                    Navigator.of(context).pop();
                    setState(() => _kurulumTamamlandi = true);
                  },
                  onTestBaslat: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RenkTestiSorusuEkrani(
                          onTestTamamlandi: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            setState(() => _kurulumTamamlandi = true);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            setState(() => _kurulumTamamlandi = true);
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
          onGaleridenSec: () {},
          onFotoCekildi: () {
            Navigator.of(context).pop();
            _fiyatOnaySayfasiniAc(context);
          },
        ),
      ),
    );
  }

  void _fiyatOnaySayfasiniAc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FiyatOnayEkrani(
          onTekrarCek: () => Navigator.of(context).pop(),
          onOnaylandi: () {
            Navigator.of(context).pop();
            setState(() => _seciliSayfa = 1);
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
