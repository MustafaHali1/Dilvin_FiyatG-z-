import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../../yoneticiler/kullanici_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../fis_detay/fis_detay_ekrani.dart';
import '../fisler/tum_fisler_ekrani.dart';

/// Kolay Mod - Ana Sayfa (Yüksek Kontrast, Erişilebilir, Büyük Dokunma Alanları)
class KolayModAnaSayfaView extends StatefulWidget {
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
  State<KolayModAnaSayfaView> createState() => _KolayModAnaSayfaViewState();
}

class _KolayModAnaSayfaViewState extends State<KolayModAnaSayfaView> {
  // Kullanıcının isteği: Geçmiş fişler yanındaki tırnak ile açılıp kapansın
  bool _gecmisFislerAcik = true;

  @override
  Widget build(BuildContext context) {
    final sepet = context.watch<SepetYoneticisi>();
    final fisYoneticisi = context.watch<FisYoneticisi>();
    final kullanici = context.watch<KullaniciYoneticisi>().kullanici;
    final profil = context.watch<ProfilYoneticisi>().profil;

    final String kullaniciAdi = kullanici.adSoyad.isNotEmpty
        ? kullanici.adSoyad.split(' ').first
        : 'Kullanıcı';

    final double harcananTutar = fisYoneticisi.donemHarcamasi(profil);
    final double butce = profil.aylikButce > 0 ? profil.aylikButce : 5000.0;
    final double kalanButce = fisYoneticisi.kalanButce(profil);
    final double ilerleme = fisYoneticisi.butceIlerleme(profil);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // 1. Üst Header (Yuvarlak 1 ve Yuvarlak 2 Çözümü: 0px taşma, kişi adı tebriği)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_rounded,
                        color: UygulamaRenkleri.kolayModSari,
                        size: 34,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merhaba $kullaniciAdi 👋',
                              style: MetinStilleri.kolayModBaslik().copyWith(fontSize: 22),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Alışveriş harcamalarını kolayca takip et',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KullaniciProfiliEkrani()),
                    );
                  },
                  icon: const Icon(Icons.person_rounded, color: Colors.black, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: UygulamaRenkleri.kolayModSari,
                    padding: const EdgeInsets.all(10),
                  ),
                  tooltip: 'Kullanıcı Profili',
                ),
              ],
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 2. Büyük Harcama Kartı (Canlı Veritabanı ve Bütçe Çubuğu)
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
                      Text(
                        'DÖNEM: ${profil.butceDonemiFormatli.toUpperCase()}',
                        style: MetinStilleri.govdeKalin(renk: Colors.white).copyWith(fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: UygulamaRenkleri.kolayModSari.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                          border: Border.all(color: UygulamaRenkleri.kolayModSari),
                        ),
                        child: Text(
                          '${profil.kalanGunSayisi} Gün · %${(ilerleme * 100).toInt()}',
                          style: const TextStyle(
                            color: UygulamaRenkleri.kolayModSari,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${harcananTutar.toStringAsFixed(2)} ₺',
                      style: MetinStilleri.kolayModDev(),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukOrta),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aylık Bütçe Limiti:', style: MetinStilleri.govde(renk: Colors.white70)),
                      Text(
                        '${butce.toStringAsFixed(2)} ₺',
                        style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.kolayModSari),
                      ),
                    ],
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Olculer.yariCapTam),
                    child: LinearProgressIndicator(
                      value: ilerleme,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(UygulamaRenkleri.kolayModSari),
                    ),
                  ),
                  const SizedBox(height: Olculer.boslukKucuk),
                  Text(
                    kalanButce >= 0
                        ? 'Kalan Bütçe: +${kalanButce.toStringAsFixed(2)} ₺'
                        : 'Bütçe Aşımı: ${(-kalanButce).toStringAsFixed(2)} ₺ ⚠️',
                    style: MetinStilleri.govdeKalin(
                      renk: kalanButce >= 0 ? Colors.white : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 3. İki Tane Dev Aksiyon Butonu
            // A) FİYAT OKU (Kamera) Butonu
            InkWell(
              onTap: widget.onKameraAc,
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
              onTap: widget.onSepeteGit,
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
                          Text('${sepet.toplamUrunAdedi} Ürün • ${sepet.toplamTutar.toStringAsFixed(2)} ₺', style: const TextStyle(color: Color(0xFF005236), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 36),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 4. Son Alışverişler (Accordion Tırnak + Son 3 Fiş + Tüm Fişleri Gör Butonu)
            InkWell(
              onTap: () {
                setState(() => _gecmisFislerAcik = !_gecmisFislerAcik);
              },
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('SON ALIŞVERİŞLER', style: MetinStilleri.kolayModBaslik()),
                        const SizedBox(width: 8),
                        Icon(
                          _gecmisFislerAcik ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: UygulamaRenkleri.kolayModSari,
                          size: 32,
                        ),
                      ],
                    ),
                    Text('${fisYoneticisi.fisSayisi} Fiş', style: MetinStilleri.govde(renk: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Olculer.boslukOrta),

            if (_gecmisFislerAcik) ...[
              if (fisYoneticisi.fisler.isEmpty)
                Container(
                  padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(Olculer.yariCapBuyuk),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'Kayıtlı fiş bulunmuyor.',
                      style: MetinStilleri.kolayModGovde(renk: Colors.white70),
                    ),
                  ),
                )
              else ...[
                // Yalnızca son 3 fişi gösteriyoruz (Kullanıcı talebi: son 3 göstersin)
                for (final fis in fisYoneticisi.fisler.take(3))
                  _KolayModFisKarti(
                    ad: fis.aciklama,
                    tarihFiyat: '${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year} • ${fis.toplamTutar.toStringAsFixed(2)} ₺',
                    fisNo: fis.id,
                    onSesliDinle: widget.onSesliAsistanAc,
                    onDetay: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FisDetayEkrani(fis: fis)),
                      );
                    },
                  ),
                const SizedBox(height: Olculer.boslukKucuk),
                // Tüm Fişleri Gör Butonu
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TumFislerEkrani(baslik: 'Tüm Geçmiş Fişler'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, color: UygulamaRenkleri.kolayModSari),
                  label: const Text(
                    'Tüm Fişleri Gör',
                    style: TextStyle(
                      color: UygulamaRenkleri.kolayModSari,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: UygulamaRenkleri.kolayModSari, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                    ),
                  ),
                ),
              ],
            ],

            // Alttaki gezinti çubuğunun (bottom navigation) altında kalmaması için ferah boşluk
            const SizedBox(height: 100),
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
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
              border: Border.all(color: UygulamaRenkleri.kolayModSari),
            ),
            child: const Icon(Icons.receipt_rounded, color: UygulamaRenkleri.kolayModSari, size: 28),
          ),
          const SizedBox(width: Olculer.boslukOrta),
          Expanded(
            child: InkWell(
              onTap: onDetay,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad,
                    style: MetinStilleri.kolayModGovde(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(tarihFiyat, style: MetinStilleri.govde(renk: Colors.white70)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onSesliDinle,
            icon: const Icon(Icons.volume_up_rounded, color: Colors.black, size: 26),
            style: IconButton.styleFrom(
              backgroundColor: UygulamaRenkleri.kolayModSari,
              padding: const EdgeInsets.all(8),
            ),
            tooltip: 'Sesli Dinle',
          ),
        ],
      ),
    );
  }
}
