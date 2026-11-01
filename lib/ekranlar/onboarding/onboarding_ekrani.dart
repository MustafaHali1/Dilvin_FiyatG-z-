import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import 'bilesenler/profil_secim_karti.dart';

/// "Seni nasıl tanıyalım?" Karşılama ve Onboarding Ekranı
class OnboardingEkrani extends StatefulWidget {
  final VoidCallback onTamamlandi;

  const OnboardingEkrani({
    super.key,
    required this.onTamamlandi,
  });

  @override
  State<OnboardingEkrani> createState() => _OnboardingEkraniState();
}

class _OnboardingEkraniState extends State<OnboardingEkrani> {
  ProfilTuru _seciliProfil = ProfilTuru.standart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Olculer.boslukOrta),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: UygulamaRenkleri.anaAcik,
                  borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                ),
                child: Text(
                  'KİŞİSELLEŞTİRME',
                  style: MetinStilleri.aciklama(renk: UygulamaRenkleri.anaKoyu).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: Olculer.boslukOrta),
              Text('Seni nasıl tanıyalım?', style: MetinStilleri.devBaslik()),
              const SizedBox(height: 6),
              Text(
                'Alışveriş deneyimini gözlerine ve ihtiyaçlarına en uygun şekilde özelleştirelim.',
                style: MetinStilleri.aciklama(),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),

              // Sesli Asistan Bilgilendirme Kartı (Tasarımda olan mavi kart)
              Container(
                padding: const EdgeInsets.all(Olculer.boslukOrta),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: UygulamaRenkleri.anaZumrut,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: Olculer.boslukOrta),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sesli Asistan Her Modda Aktif', style: MetinStilleri.govdeKalin()),
                          Text(
                            'Hangi modu seçersen seç; reyonlarda fiyatları sesli dinleyebilirsin.',
                            style: MetinStilleri.aciklama(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Olculer.boslukBuyuk),

              // Profil Seçim Kartları
              Expanded(
                child: ListView(
                  children: [
                    ProfilSecimKarti(
                      baslik: 'Standart',
                      aciklama: 'Herkes için klasik ve dengeli görünüm. Standart yazı boyutu.',
                      ikon: Icons.grid_view_rounded,
                      rozetMetni: 'Önerilen',
                      seciliMi: _seciliProfil == ProfilTuru.standart,
                      onSecildi: () => setState(() => _seciliProfil = ProfilTuru.standart),
                    ),
                    ProfilSecimKarti(
                      baslik: 'Kolay Mod',
                      aciklama: 'Büyük yazı, yüksek kontrast (yaşlılar ve az görenler için konforlu).',
                      ikon: Icons.text_fields_rounded,
                      seciliMi: _seciliProfil == ProfilTuru.kolayMod,
                      onSecildi: () => setState(() => _seciliProfil = ProfilTuru.kolayMod),
                    ),
                    ProfilSecimKarti(
                      baslik: 'Renk Körü Modu',
                      aciklama: 'Renge bağımlı olmayan, simge ve desen destekli özel renk paleti.',
                      ikon: Icons.visibility_rounded,
                      seciliMi: _seciliProfil == ProfilTuru.renkKoruModu,
                      onSecildi: () => setState(() => _seciliProfil = ProfilTuru.renkKoruModu),
                    ),
                  ],
                ),
              ),

              Center(
                child: Text(
                  'Bunu daha sonra Ayarlar\'dan dilediğin zaman değiştirebilirsin.',
                  style: MetinStilleri.aciklama(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Olculer.boslukOrta),
              OzelButon(
                metin: 'Devam Et',
                ikon: Icons.arrow_forward_rounded,
                onPressed: () {
                  context.read<ProfilYoneticisi>().profilAyarla(_seciliProfil);
                  widget.onTamamlandi();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
