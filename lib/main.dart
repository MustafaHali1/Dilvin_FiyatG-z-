import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/yoneticiler/sepet_yoneticisi.dart';
import 'package:fiyatgoz/yoneticiler/profil_yoneticisi.dart';
import 'package:fiyatgoz/ekranlar/ana_sayfa/ana_sayfa_ekrani.dart';
import 'package:fiyatgoz/ekranlar/sepet/sepet_ekrani.dart';
import 'package:fiyatgoz/ekranlar/fiyat_onay/fiyat_onay_ekrani.dart';
import 'package:fiyatgoz/ekranlar/fis_detay/fis_detay_ekrani.dart';
import 'package:fiyatgoz/modeller/fis_modeli.dart';

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
      home: const AnaGezintiIskeleti(),
    );
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
        onKameraAc: () => _fiyatOnaySayfasiniAc(context),
        onSepeteGit: () => setState(() => _seciliSayfa = 1),
      ),
      SepetEkrani(
        onUrunEkle: () => _fiyatOnaySayfasiniAc(context),
        onAlisverisiBitir: () => _fisDetaySayfasiniAc(context, sepet),
      ),
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
        ],
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
}
