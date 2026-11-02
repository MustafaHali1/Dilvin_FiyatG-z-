import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sabitler/tema_fabrikasi.dart';
import 'sabitler/uygulama_renkleri.dart';
import 'servisler/kamera_servisi.dart';
import 'yoneticiler/sepet_yoneticisi.dart';
import 'yoneticiler/profil_yoneticisi.dart';
import 'yoneticiler/fis_yoneticisi.dart';
import 'yoneticiler/kullanici_yoneticisi.dart';
import 'yoneticiler/sesli_radar_yoneticisi.dart';
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
import 'ekranlar/fisler/tum_fisler_ekrani.dart';
import 'ekranlar/kamera/gorme_engelli_radar_kamera_view.dart';
import 'ekranlar/sepet/gorme_engelli_sepet_view.dart';
import 'ekranlar/sesli_asistan/sesli_asistan_diyalog_ekrani.dart';
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
        ChangeNotifierProvider(create: (_) => FisYoneticisi()),
        ChangeNotifierProvider(create: (_) => KullaniciYoneticisi()),
        ChangeNotifierProvider(create: (_) => SesliRadarYoneticisi()),
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
        onSepeteGit: () => setState(() => _seciliSayfa = 2),
        onSesliAsistanAc: () => _sesliAsistaniAc(context),
        onAyarlaraGit: () => setState(() => _seciliSayfa = 3),
      ),
      TumFislerEkrani(
        onFisSecildi: (fis) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FisDetayEkrani(fis: fis),
            ),
          );
        },
      ),
      SepetEkrani(
        onUrunEkle: () => _kameraSayfasiniAc(context),
        onAlisverisiBitir: () => _fisDetaySayfasiniAc(context, sepet),
      ),
      const AyarlarEkrani(),
    ];

    final isKolayMod = profil.profilTuru == ProfilTuru.kolayMod;

    return Scaffold(
      body: sayfalar[_seciliSayfa.clamp(0, sayfalar.length - 1)],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isKolayMod ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isKolayMod ? 0.3 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Ana Sayfa
                _buildAltNavButonu(
                  index: 0,
                  ikonSecili: Icons.home_rounded,
                  ikonNormal: Icons.home_outlined,
                  etiket: 'Ana Sayfa',
                  profil: profil,
                ),

                // 2. Fişlerim (Yuvarlak 2 ve Genel Navigasyon)
                _buildAltNavButonu(
                  index: 1,
                  ikonSecili: Icons.receipt_long_rounded,
                  ikonNormal: Icons.receipt_long_outlined,
                  etiket: 'Fişlerim',
                  profil: profil,
                ),

                // 3. Ortada Göz Alıcı Sesli Asistan Mikrofon Butonu (Yuvarlak 6 Çözümü)
                GestureDetector(
                  onTap: () => _sesliAsistaniAc(context),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isKolayMod
                            ? [UygulamaRenkleri.kolayModSari, UygulamaRenkleri.kolayModSari]
                            : [const Color(0xFF10B981), const Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isKolayMod
                                  ? UygulamaRenkleri.kolayModSari
                                  : UygulamaRenkleri.anaZumrut)
                              .withValues(alpha: 0.38),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.mic_rounded,
                        color: isKolayMod ? Colors.black : Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                // 4. Sepet (Canlı Ürün Rozetiyle)
                _buildAltNavButonu(
                  index: 2,
                  ikonSecili: Icons.shopping_cart_rounded,
                  ikonNormal: Icons.shopping_cart_outlined,
                  etiket: 'Sepet',
                  rozetSayisi: sepet.toplamUrunAdedi,
                  profil: profil,
                ),

                // 5. Ayarlar
                _buildAltNavButonu(
                  index: 3,
                  ikonSecili: Icons.settings_rounded,
                  ikonNormal: Icons.settings_outlined,
                  etiket: 'Ayarlar',
                  profil: profil,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAltNavButonu({
    required int index,
    required IconData ikonSecili,
    required IconData ikonNormal,
    required String etiket,
    int? rozetSayisi,
    required ProfilModeli profil,
  }) {
    final secili = _seciliSayfa == index;
    final aktifRenk = profil.profilTuru == ProfilTuru.kolayMod
        ? UygulamaRenkleri.kolayModSari
        : UygulamaRenkleri.anaZumrut;
    final pasifRenk = profil.profilTuru == ProfilTuru.kolayMod
        ? Colors.white60
        : const Color(0xFF94A3B8);

    Widget ikon = Icon(
      secili ? ikonSecili : ikonNormal,
      color: secili ? aktifRenk : pasifRenk,
      size: 25,
    );

    if (rozetSayisi != null && rozetSayisi > 0) {
      ikon = Badge(
        label: Text('$rozetSayisi'),
        backgroundColor: Colors.redAccent,
        child: ikon,
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _seciliSayfa = index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ikon,
              const SizedBox(height: 3),
              Text(
                etiket,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: secili ? FontWeight.bold : FontWeight.w500,
                  color: secili ? aktifRenk : pasifRenk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
            setState(() => _seciliSayfa = 2); // Sepete gec
          },
        ),
      ),
    );
  }

  void _fisDetaySayfasiniAc(BuildContext context, SepetYoneticisi sepet) async {
    if (sepet.urunler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sepetiniz boş. Fiş oluşturmak için ürün ekleyin.')),
      );
      return;
    }

    final fisYoneticisi = context.read<FisYoneticisi>();
    final yeniFis = await fisYoneticisi.sepettenFisOlusturVeKaydet(
      urunler: sepet.urunler,
      marketAdi: 'Migros Jet',
      aciklama: 'Haftalık Market Alışverişi',
    );

    sepet.sepetiBosalt();

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FisDetayEkrani(
            fis: yeniFis,
          ),
        ),
      );
    }
  }

  void _sesliAsistaniAc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SesliAsistanDiyalogEkrani(),
      ),
    );
  }
}
