import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../servisler/sesli_komut_servisi.dart';
import '../fis_detay/fis_detay_ekrani.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../ayarlar/ayarlar_ekrani.dart';
import '../kamera/kamera_tarayici_ekrani.dart';
import '../sepet/sepet_ekrani.dart';

/// Görme Engelli / Sesli Asistan Diyalog Ekranı
/// (Stitch: sesli_asistan_diyalog birebir)
class SesliAsistanDiyalogEkrani extends StatefulWidget {
  const SesliAsistanDiyalogEkrani({super.key});

  @override
  State<SesliAsistanDiyalogEkrani> createState() =>
      _SesliAsistanDiyalogEkraniState();
}

class _SesliAsistanDiyalogEkraniState extends State<SesliAsistanDiyalogEkrani> {
  bool _dinleniyor = true;
  bool _susturuldu = false;
  bool _cevapVeriyor = false;
  String _kullaniciSorusu = 'Toplam ne kadar harcadım, sepette neler var?';
  String _yakalananMetin = '';
  String _asistanCevabi =
      'Sepetinde şu an 4 farklı ürün, toplam 7 adet var. Genel tutar 287 lira 40 kuruş. Bütçe limitini 47 lira 40 kuruş aştın.';

  Timer? _waveformTimer;
  List<double> _barHeights = [18, 36, 22, 44, 28, 42, 20, 32, 16];

  @override
  void initState() {
    super.initState();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (mounted && _dinleniyor && !_susturuldu && !_cevapVeriyor) {
        setState(() {
          _barHeights = [
            16.0 + (timer.tick % 4) * 8,
            28.0 + (timer.tick % 5) * 6,
            18.0 + (timer.tick % 3) * 10,
            38.0 + (timer.tick % 6) * 5,
            24.0 + (timer.tick % 4) * 8,
            36.0 + (timer.tick % 5) * 6,
            18.0 + (timer.tick % 3) * 9,
            30.0 + (timer.tick % 4) * 7,
            14.0 + (timer.tick % 6) * 6,
          ];
        });
      }
    });

    HapticFeedback.mediumImpact();

    SesliAsistanServisi().durumDinleyicisiAyarla((durum) {
      if (!mounted || _susturuldu || _cevapVeriyor) return;
      if (durum == 'notListening' || durum == 'done') {
        if (_yakalananMetin.trim().isNotEmpty) {
          final islenecek = _yakalananMetin;
          _yakalananMetin = '';
          _komutuIsle(islenecek);
        } else if (_dinleniyor) {
          Timer(const Duration(milliseconds: 350), () {
            if (mounted && _dinleniyor && !_susturuldu && !_cevapVeriyor) {
              _canliDinlemeyiBaslat();
            }
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _canliDinlemeyiBaslat();
      }
    });
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    SesliAsistanServisi().durumDinleyicisiAyarla(null);
    SesliAsistanServisi().durdur();
    super.dispose();
  }

  Future<void> _canliDinlemeyiBaslat() async {
    final asistan = SesliAsistanServisi();

    if (!mounted || _cevapVeriyor) return;
    setState(() {
      _dinleniyor = true;
      _kullaniciSorusu = 'Sizi dinliyorum, konuşun...';
      _yakalananMetin = '';
    });

    await asistan.dinle(
      dinlemeSuresi: const Duration(seconds: 30),
      sessizlikSuresi: const Duration(seconds: 4),
      onSonuc: (metin, sonMu) async {
        if (!mounted || _cevapVeriyor) return;
        _yakalananMetin = metin;
        setState(() {
          _kullaniciSorusu = metin;
        });

        if (sonMu && metin.trim().isNotEmpty) {
          final islenecek = metin;
          _yakalananMetin = '';
          await _komutuIsle(islenecek);
        }
      },
    );
  }

  Future<void> _komutuIsle(String metin) async {
    final komutServisi = SesliKomutServisi();
    final sepet = context.read<SepetYoneticisi>();
    final profil = context.read<ProfilYoneticisi>().profil;

    final komut = komutServisi.niyetCoz(metin);
    String yanit = '';

    switch (komut.tur) {
      case KomutTuru.selamlama:
        yanit = 'Merhabalar! Alışverişinizde size yardımcı olmak için buradayım. Fiyat sorabilir, sepetinizi veya bütçenizi kontrol edebilirsiniz.';
        break;

      case KomutTuru.tesekkurVeda:
        yanit = 'Rica ederim, her zaman buradayım! İyi alışverişler dilerim.';
        break;

      case KomutTuru.yardim:
        yanit = 'Ben Dilvin · SepetGöz Asistanı. Ürün etiketlerini okuyabilir, sepetinizi hesaplayabilir, bütçenizi takip edebilir ve aradığınız ürünleri bulabilirim.';
        break;

      case KomutTuru.sepetiSifirla:
        sepet.sepetiBosalt();
        yanit = 'Sepetiniz tamamen temizlendi, baştan başlıyoruz.';
        break;

      case KomutTuru.butceSorgula:
        final harcanan = sepet.toplamTutar;
        final kalan = profil.aylikButce - harcanan;
        if (kalan >= 0) {
          yanit = 'Şu ana kadar ${harcanan.toStringAsFixed(2)} lira harcadınız. Kalan bütçeniz ${kalan.toStringAsFixed(2)} lira.';
        } else {
          yanit = 'Bütçenizi ${(-kalan).toStringAsFixed(2)} lira aştınız! Toplam tutar: ${harcanan.toStringAsFixed(2)} lira.';
        }
        break;

      case KomutTuru.sepetOzeti:
        final adet = sepet.toplamUrunAdedi;
        final cesit = sepet.urunCesitSayisi;
        final toplam = sepet.toplamTutar;
        if (adet == 0) {
          yanit = 'Sepetiniz şu anda boş.';
        } else {
          yanit = 'Sepetinizde $cesit farklı ürün, toplam $adet adet var. Genel toplam ${toplam.toStringAsFixed(2)} lira.';
        }
        break;

      case KomutTuru.urunAra:
        yanit = '${komut.hedefUrun} aramak için kamera vizörünü açabilirsiniz.';
        break;

      case KomutTuru.sepeteEkle:
        yanit = 'Sepetinizdeki ürünler onaylandı.';
        break;

      case KomutTuru.iptal:
        yanit = 'İşlem iptal edildi.';
        break;

      default:
        yanit = 'Tam anlayamadım. "Sepette ne var" veya "Bütçem ne kadar" diyebilirsiniz.';
        break;
    }

    if (!mounted) return;
    setState(() {
      _dinleniyor = false;
      _asistanCevabi = yanit;
    });

    await _seslendir(yanit);
  }

  Future<void> _seslendir(String metin) async {
    if (_susturuldu) return;
    _cevapVeriyor = true;
    HapticFeedback.heavyImpact();
    await SesliAsistanServisi().konus(metin);
    _cevapVeriyor = false;

    if (mounted && !_susturuldu && _dinleniyor) {
      _canliDinlemeyiBaslat();
    }
  }

  void _dinlemeDurumuDegistir() {
    HapticFeedback.mediumImpact();
    if (_dinleniyor) {
      SesliAsistanServisi().dinlemeyiDurdur();
      setState(() => _dinleniyor = false);
    } else {
      _canliDinlemeyiBaslat();
    }
  }

  void _susturDegistir() {
    HapticFeedback.mediumImpact();
    setState(() {
      _susturuldu = !_susturuldu;
    });
    if (_susturuldu) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else {
      _seslendir('Asistan sesi açıldı.');
    }
  }

  void _komutCalistir(String komut) {
    final sepet = context.read<SepetYoneticisi>();
    setState(() {
      _kullaniciSorusu = komut;
    });

    if (komut.contains('çıkar')) {
      if (sepet.urunler.isNotEmpty) {
        final silinen = sepet.urunler.last;
        sepet.urunSil(silinen.id);
        setState(() {
          _asistanCevabi = 'Son ürün "${silinen.ad}" sepetten çıkarıldı. Güncel sepet tutarı ${sepet.toplamTutar.toStringAsFixed(2)} TL.';
        });
      } else {
        setState(() {
          _asistanCevabi = 'Sepetiniz zaten boş, çıkarılacak ürün bulunamadı.';
        });
      }
    } else if (komut.contains('Bütçem')) {
      final kalan = (240.0 - sepet.toplamTutar);
      if (kalan >= 0) {
        setState(() {
          _asistanCevabi = 'Belirlediğiniz 240 liralık bütçenizden ${kalan.toStringAsFixed(2)} TL limitiniz kaldı.';
        });
      } else {
        setState(() {
          _asistanCevabi = 'Bütçenizi ${(-kalan).toStringAsFixed(2)} TL aştınız! Dikkatli harcayın.';
        });
      }
    } else if (komut.contains('Süt')) {
      setState(() {
        _asistanCevabi = 'Sütaş Tam Yağlı Süt birim fiyatı 24 lira 90 kuruştur.';
      });
    } else if (komut.contains('fiş')) {
      if (sepet.urunler.isNotEmpty) {
        setState(() {
          _asistanCevabi = 'Alışverişiniz veritabanına kaydedildi, dijital fişiniz ekrana getiriliyor.';
        });
        final fisYoneticisi = context.read<FisYoneticisi>();
        fisYoneticisi.sepettenFisOlusturVeKaydet(
          urunler: sepet.urunler,
          marketAdi: 'Market',
          aciklama: 'Sesli Asistan Alışveriş Fişi',
        ).then((yeniFis) {
          sepet.sepetiBosalt();
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FisDetayEkrani(fis: yeniFis),
              ),
            );
          }
        });
      } else {
        setState(() {
          _asistanCevabi = 'Sepetiniz boş olduğu için fiş oluşturulamadı.';
        });
      }
    }

    _seslendir(_asistanCevabi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E11).withValues(alpha: 0.95),
        elevation: 4,
        toolbarHeight: 76,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD600), size: 30),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Geri Dön',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD600),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SESLİ MOD AKTİF',
                  style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Sesli Asistan',
              style: TextStyle(
                color: Color(0xFFE4E1E6),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFFFD600), size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AyarlarEkrani()),
              );
            },
            tooltip: 'Ayarlar ve Mod Değiştir',
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Color(0xFFFFD600), size: 30),
            onPressed: () => _seslendir(_asistanCevabi),
            tooltip: 'Cevabı Sesli Tekrar Oku',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KullaniciProfiliEkrani()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFF5DC),
                child: Icon(Icons.person, color: Color(0xFF3A3000), size: 22),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Sesli Asistan Durum Alanı & Sustur Butonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _susturuldu ? Colors.grey : const Color(0xFFFFD600),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _susturuldu ? 'HOPARLÖR KAPALI' : 'ASİSTAN AKTİF • AÇIK',
                        style: TextStyle(
                          color: _susturuldu ? Colors.white60 : const Color(0xFFFFF5DC),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _susturDegistir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2D),
                      foregroundColor: const Color(0xFFFFF5DC),
                      minimumSize: const Size(100, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(_susturuldu ? Icons.volume_up : Icons.volume_off, size: 20),
                    label: Text(_susturuldu ? 'Aç' : 'Sustur'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Canlı Dinleme Durumu & Ses Dalgaları & Merkez Mikrofon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F22),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _dinleniyor ? '“Dinliyorum...”' : '“Dokunun ve Konuşun”',
                    style: const TextStyle(
                      color: Color(0xFFFFF5DC),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ses Dalgaları Çubukları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _barHeights.map((h) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: _dinleniyor ? h : 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 88x88px Tactile Center Mic Pulse Button
                  GestureDetector(
                    onTap: _dinlemeDurumuDegistir,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD600).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.mic, color: Colors.black, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Konuşmanız algılanıyor',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Kullanıcı Konuşma Kaydı Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.record_voice_over, color: Color(0xFFFFD600), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'SİZ SÖYLEDİNİZ:',
                        style: TextStyle(
                          color: Color(0xFFFFD600),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“$_kullaniciSorusu”',
                    style: const TextStyle(
                      color: Color(0xFFFFF5DC),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Asistan Cevabı Kartı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2D),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy, color: Color(0xFFFFD600), size: 28),
                          SizedBox(width: 8),
                          Text(
                            'ASİSTAN CEVABI:',
                            style: TextStyle(
                              color: Color(0xFFFFD600),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.volume_up, color: Color(0xFF60F587), size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '“$_asistanCevabi”',
                    style: const TextStyle(
                      color: Color(0xFFFFF5DC),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _seslendir(_asistanCevabi),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF5DC),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(72),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.replay, size: 30, color: Colors.black),
                    label: const Text(
                      'Cevabı Tekrar Dinle',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. Hızlı Dokunsal Sesli Komut Önerileri (Min 72px)
            const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Color(0xFFFFD600), size: 24),
                SizedBox(width: 8),
                Text(
                  'ÖRNEK SESLİ KOMUTLAR:',
                  style: TextStyle(
                    color: Color(0xFFFFF5DC),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildKomutCipi(
              icon: Icons.remove_shopping_cart,
              metin: 'Son ürünü sepetten çıkar',
              onTap: () => _komutCalistir('Son ürünü sepetten çıkar'),
            ),
            const SizedBox(height: 10),
            _buildKomutCipi(
              icon: Icons.account_balance_wallet,
              metin: 'Bütçemde kaç lira kaldı?',
              onTap: () => _komutCalistir('Bütçemde kaç lira kaldı?'),
            ),
            const SizedBox(height: 10),
            _buildKomutCipi(
              icon: Icons.sell,
              metin: 'Süt kaç liraydı?',
              onTap: () => _komutCalistir('Süt kaç liraydı?'),
            ),
            const SizedBox(height: 10),
            _buildKomutCipi(
              icon: Icons.receipt_long,
              metin: 'Alışverişi bitir ve fiş oluştur',
              onTap: () => _komutCalistir('Alışverişi bitir ve fiş oluştur'),
            ),

            const SizedBox(height: 20),

            // 6. Alt Dev Dokunsal Ses Giriş Alanı (Min 80px)
            ElevatedButton(
              onPressed: _dinlemeDurumuDegistir,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, size: 36, color: Colors.black),
                  SizedBox(width: 12),
                  Text(
                    'KONUŞMAK İÇİN DOKUNUN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'İki parmakla çift dokun: Asistanı anında susturur',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // Görme Engelli Modu - 3 Butonlu Dev Alt Navigasyon Barı
      bottomNavigationBar: Container(
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E11),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Radar
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KameraTarayiciEkrani(
                        onFotoCekildi: (_) {},
                        onKapat: () => Navigator.maybePop(context),
                      ),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Radar',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // Sepet
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SepetEkrani(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Sepet',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // Asistan (Aktif)
            Expanded(
              child: Container(
                color: const Color(0xFF2A2A2D),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Color(0xFFFFD600), size: 32),
                    SizedBox(height: 4),
                    Text(
                      'Asistan',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKomutCipi({
    required IconData icon,
    required String metin,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD600), size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '“$metin”',
                style: const TextStyle(
                  color: Color(0xFFFFF5DC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 28),
          ],
        ),
      ),
    );
  }
}
