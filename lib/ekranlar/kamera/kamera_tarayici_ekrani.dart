import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/durum_rozeti.dart';

/// Kamera Arayüzü (Yeşil tarama çerçevesi, uyarılar ve deklanşör)
class KameraTarayiciEkrani extends StatelessWidget {
  final VoidCallback onFotoCekildi;
  final VoidCallback onGaleridenSec;
  final VoidCallback onKapat;

  const KameraTarayiciEkrani({
    super.key,
    required this.onFotoCekildi,
    required this.onGaleridenSec,
    required this.onKapat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Arka Plan Kamera Simülasyonu (Karanlık zemin)
          Container(
            color: const Color(0xFF0F172A),
            child: Center(
              child: Icon(
                Icons.camera_alt_outlined,
                size: 96,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Üst Kontroller ve Rozetler
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Olculer.boslukBuyuk,
                vertical: Olculer.boslukOrta,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onKapat,
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                        ),
                      ),
                      DurumRozeti.cevrimdisi(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.flash_off_rounded, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukOrta),

                  // Düşük Işık / Bulanıklık Uyarısı Bandı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: UygulamaRenkleri.uyariTuruncu, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Ortam karanlık, flaşı açmayı dene',
                          style: MetinStilleri.aciklama(renk: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ortadaki Tarama Çerçevesi (Yeşil Hedef Alanı)
          Center(
            child: Container(
              width: 280,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: UygulamaRenkleri.anaZumrut,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Tarama Çizgisi
                  Container(
                    height: 2,
                    width: 260,
                    color: UygulamaRenkleri.anaZumrut.withValues(alpha: 0.8),
                  ),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                      ),
                      child: Text(
                        'Fiyat etiketini çerçeveye hizala',
                        style: MetinStilleri.aciklama(renk: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Alt Deklanşör ve Galeri Alanı
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Olculer.boslukCokBuyuk),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Galeri Butonu
                    IconButton(
                      onPressed: onGaleridenSec,
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white12,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),

                    // Büyük Deklanşör Butonu
                    GestureDetector(
                      onTap: onFotoCekildi,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: UygulamaRenkleri.anaZumrut,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),

                    // Boşluk dengeleyici
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
