import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';

/// Kolay Mod - Ana Sayfa (Stitch: kolay_mod_ana_sayfa birebir)
class KolayModAnaSayfaView extends StatelessWidget {
  final VoidCallback onKameraAc;
  final VoidCallback onSepeteGit;
  final VoidCallback onSesliAsistanAc;
  final VoidCallback onAyarlaraGit;

  const KolayModAnaSayfaView({
    super.key,
    required this.onKameraAc,
    required this.onSepeteGit,
    required this.onSesliAsistanAc,
    required this.onAyarlaraGit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // Üst Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_rounded, color: UygulamaRenkleri.kolayModSari, size: 36),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FiyatGöz', style: MetinStilleri.kolayModBaslik()),
                        Text(
                          'KOLAY MOD / YÜKSEK KARŞITLIK',
                          style: MetinStilleri.aciklama(renk: Colors.white70).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onSesliAsistanAc,
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.black, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: UygulamaRenkleri.kolayModSari,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 1. Durum Kartı (Yaşlı & Yüksek Kontrast Aktif)
            Container(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.elderly_rounded, color: UygulamaRenkleri.kolayModSari, size: 32),
                          const SizedBox(width: 8),
                          Text('KOLAY MOD: ANA SAYFA', style: MetinStilleri.govdeKalin(renk: Colors.white)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: UygulamaRenkleri.kolayModSari,
                          borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text('Aktif', style: MetinStilleri.aciklama(renk: Colors.black).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Büyük Yazı & Yüksek Karşıtlık Açık', style: MetinStilleri.aciklama(renk: Colors.white)),
                        InkWell(
                          onTap: onAyarlaraGit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('A+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 2. Büyük Harcama Kartı (Siyah Kutu + Sarı Devasa Rakam)
            Container(
              padding: const EdgeInsets.all(Olculer.boslukBuyuk),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BU AY HARCANAN', style: MetinStilleri.govdeKalin(renk: Colors.white)),
                      IconButton(
                        onPressed: onSesliAsistanAc,
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.black),
                        style: IconButton.styleFrom(backgroundColor: UygulamaRenkleri.kolayModSari),
                      ),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text('3.482,50 ₺', style: MetinStilleri.kolayModDev()),
                  const SizedBox(height: Olculer.boslukOrta),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aylık Bütçe Limiti:', style: MetinStilleri.govde(renk: Colors.white70)),
                      Text('5.000,00 ₺', style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.kolayModSari)),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                    child: const LinearProgressIndicator(
                      value: 0.70,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(UygulamaRenkleri.kolayModSari),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text('Kalan Bütçe: +1.517,50 ₺', style: MetinStilleri.govdeKalin(renk: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 3. İki Tane Dev Aksiyon Butonu
            // A) FİYAT OKU (Kamera) Butonu
            InkWell(
              onTap: onKameraAc,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              child: Container(
                height: 84,
                padding: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk),
                decoration: BoxDecoration(
                  color: UygulamaRenkleri.kolayModSari,
                  borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: UygulamaRenkleri.kolayModSari, size: 32),
                    ),
                    const SizedBox(width: Olculer.boslukOrta),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FİYAT OKU', style: MetinStilleri.kolayModBaslik(renk: Colors.black)),
                          const Text('Kamerayı Barkoda Tutun', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 36),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            // B) Sepetime Git Butonu
            InkWell(
              onTap: onSepeteGit,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: Olculer.boslukBuyuk),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7FF),
                  borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(color: Color(0xFF005236), shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: Olculer.boslukOrta),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sepetime Git', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                          const Text('4 Ürün • 287,40 ₺', style: TextStyle(color: Color(0xFF005236), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 36),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 4. Son Alışverişler (2 Büyük Kart)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SON ALIŞVERİŞLER', style: MetinStilleri.kolayModBaslik()),
                Text('2 Kayıt', style: MetinStilleri.govde(renk: Colors.white70)),
              ],
            ),
            const SizedBox(height: Olculer.boslukOrta),

            _KolayModFisKarti(
              ad: 'Migros Alışverişi',
              tarihFiyat: 'Dün • 648,75 ₺',
              fisNo: 'Fiş #841',
              onSesliDinle: onSesliAsistanAc,
              onDetay: onAyarlaraGit,
            ),
            _KolayModFisKarti(
              ad: 'BİM Market',
              tarihFiyat: '28 Ekim • 342,10 ₺',
              fisNo: 'Fiş #840',
              onSesliDinle: onSesliAsistanAc,
              onDetay: onAyarlaraGit,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // En Altta SESLİ YARDIM AL Butonu
            InkWell(
              onTap: onSesliAsistanAc,
              borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                  border: Border.all(color: UygulamaRenkleri.kolayModSari, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded, color: UygulamaRenkleri.kolayModSari, size: 32),
                    const SizedBox(width: 12),
                    Text('SESLİ YARDIM AL', style: MetinStilleri.kolayModBaslik(renk: UygulamaRenkleri.kolayModSari)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KolayModFisKarti extends StatelessWidget {
  final String ad;
  final String tarihFiyat;
  final String fisNo;
  final VoidCallback onSesliDinle;
  final VoidCallback onDetay;

  const _KolayModFisKarti({
    required this.ad,
    required this.tarihFiyat,
    required this.fisNo,
    required this.onSesliDinle,
    required this.onDetay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
      padding: const EdgeInsets.all(Olculer.boslukOrta),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad, style: MetinStilleri.kolayModBaslik()),
                  Text(tarihFiyat, style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.kolayModSari)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                ),
                child: Text(fisNo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSesliDinle,
                  icon: const Icon(Icons.volume_up, color: Colors.black),
                  label: const Text('Sesli Dinle', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UygulamaRenkleri.kolayModSari,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDetay,
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: const Text('Detayı Gör', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2E2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
