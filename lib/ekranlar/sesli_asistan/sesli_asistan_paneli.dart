import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../../servisler/sesli_asistan_servisi.dart';
import '../../servisler/sesli_komut_servisi.dart';

/// Standart ve Renk Körlüğü Modlarına özel, ekranı sarsmayan / titretmeyen,
/// şık ve modern Yarım Ekran (Modal Bottom Sheet) Sesli Asistan Paneli.
class SesliAsistanPaneli extends StatefulWidget {
  const SesliAsistanPaneli({super.key});

  /// Paneli çağıran statik yardımcı metot
  static Future<void> goster(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => const SesliAsistanPaneli(),
    );
  }

  @override
  State<SesliAsistanPaneli> createState() => _SesliAsistanPaneliState();
}

class _SesliAsistanPaneliState extends State<SesliAsistanPaneli> {
  bool _dinleniyor = true;
  bool _susturuldu = false;
  bool _cevapVeriyor = false;
  String _kullaniciMetni = 'Sizi dinliyorum, konuşun...';
  String _yakalananMetin = '';
  String _asistanCevabi = 'Nasıl yardımcı olabilirim? "Sepette ne var" veya "Bütçem" diyebilirsiniz.';

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    // Sessizlik veya mikrofon kesintilerinde kullanıcının bağırmak zorunda kalmaması için
    // arka planda dinlemeyi sürekli tetikte tutan durum dinleyicisi
    SesliAsistanServisi().durumDinleyicisiAyarla((durum) {
      if (!mounted || _susturuldu || _cevapVeriyor) return;
      if (durum == 'notListening' || durum == 'done') {
        if (_yakalananMetin.trim().isNotEmpty) {
          final islenecek = _yakalananMetin;
          _yakalananMetin = '';
          _komutuIsle(islenecek);
        } else if (_dinleniyor) {
          // Sessizlikten kapandıysa kullanıcı bağırmadan konuşabilsin diye dinlemeyi hemen tazele
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
    SesliAsistanServisi().durumDinleyicisiAyarla(null);
    SesliAsistanServisi().dinlemeyiDurdur();
    super.dispose();
  }

  Future<void> _canliDinlemeyiBaslat() async {
    final asistan = SesliAsistanServisi();

    if (!mounted || _cevapVeriyor) return;
    setState(() {
      _dinleniyor = true;
      _kullaniciMetni = 'Dinliyorum...';
      _yakalananMetin = '';
    });

    await asistan.dinle(
      dinlemeSuresi: const Duration(seconds: 30),
      sessizlikSuresi: const Duration(seconds: 4),
      onSonuc: (metin, sonMu) async {
        if (!mounted || _cevapVeriyor) return;
        _yakalananMetin = metin;
        setState(() {
          _kullaniciMetni = metin;
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

    final komut = await komutServisi.niyetCozAkilli(
      metin,
      kalanButce: profil.aylikButce - sepet.toplamTutar,
      sepetTutar: sepet.toplamTutar,
      sepetAdet: sepet.toplamUrunAdedi,
    );
    String yanit = komut.asistanCevabi ?? '';

    switch (komut.tur) {
      case KomutTuru.selamlama:
        yanit = 'Merhabalar! Alışverişinizde size yardımcı olmak için buradayım.';
        break;

      case KomutTuru.tesekkurVeda:
        yanit = 'Rica ederim, iyi alışverişler!';
        break;

      case KomutTuru.yardim:
        yanit = 'Ben Dilvin · SepetGöz Asistanı. Fiyatları söyleyebilir, sepetinizi yönetebilir ve bütçenizi hesaplayabilirim.';
        break;

      case KomutTuru.sepetiSifirla:
        sepet.sepetiBosalt();
        yanit = 'Sepetiniz tamamen sıfırlandı.';
        break;

      case KomutTuru.butceSorgula:
        final harcanan = sepet.toplamTutar;
        final kalan = profil.aylikButce - harcanan;
        if (kalan >= 0) {
          yanit = 'Toplam harcama: ${harcanan.toStringAsFixed(2)} ₺. Kalan bütçeniz: ${kalan.toStringAsFixed(2)} ₺.';
        } else {
          yanit = 'Bütçenizi ${(-kalan).toStringAsFixed(2)} ₺ aştınız! Toplam: ${harcanan.toStringAsFixed(2)} ₺.';
        }
        break;

      case KomutTuru.sepetOzeti:
        final adet = sepet.toplamUrunAdedi;
        final cesit = sepet.urunCesitSayisi;
        final toplam = sepet.toplamTutar;
        if (adet == 0) {
          yanit = 'Sepetiniz şu anda boş.';
        } else {
          yanit = 'Sepetinizde $cesit çeşit, toplam $adet ürün var. Tutar: ${toplam.toStringAsFixed(2)} ₺.';
        }
        break;

      case KomutTuru.urunAra:
        yanit = '${komut.hedefUrun} aramak için kamerayı kullanabilirsiniz.';
        break;

      case KomutTuru.sepeteEkle:
        yanit = 'İşlem onaylandı, sepete eklendi.';
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
      _asistanCevabi = yanit;
    });

    await _seslendir(yanit);
  }

  Future<void> _seslendir(String metin) async {
    if (_susturuldu) return;
    _cevapVeriyor = true;
    HapticFeedback.lightImpact();
    await SesliAsistanServisi().konus(metin);
    _cevapVeriyor = false;

    // Asistan cümlesini bitirince konuşmanın devamı için mikrofonu otomatik aç
    if (mounted && !_susturuldu && _dinleniyor) {
      _canliDinlemeyiBaslat();
    }
  }

  void _dinlemeTetikle() {
    HapticFeedback.selectionClick();
    if (_dinleniyor) {
      SesliAsistanServisi().dinlemeyiDurdur();
      setState(() => _dinleniyor = false);
    } else {
      _canliDinlemeyiBaslat();
    }
  }

  void _hazirKomutSec(String komutMetni) {
    final sepet = context.read<SepetYoneticisi>();
    final profil = context.read<ProfilYoneticisi>().profil;
    HapticFeedback.lightImpact();

    String yanit = '';
    if (komutMetni.contains('Sepette')) {
      final adet = sepet.toplamUrunAdedi;
      final toplam = sepet.toplamTutar;
      yanit = adet == 0
          ? 'Sepetiniz henüz boş.'
          : 'Sepetinizde $adet ürün var, genel toplam ${toplam.toStringAsFixed(2)} ₺.';
    } else if (komutMetni.contains('Bütçe')) {
      final kalan = profil.aylikButce - sepet.toplamTutar;
      yanit = kalan >= 0
          ? 'Kalan bütçeniz ${kalan.toStringAsFixed(2)} ₺.'
          : 'Bütçeyi ${(-kalan).toStringAsFixed(2)} ₺ aştınız.';
    } else if (komutMetni.contains('Sıfırla')) {
      sepet.sepetiBosalt();
      yanit = 'Sepet tamamen temizlendi.';
    } else if (komutMetni.contains('Çıkar')) {
      if (sepet.urunler.isNotEmpty) {
        final son = sepet.urunler.last;
        sepet.urunSil(son.id);
        yanit = '"${son.ad}" sepetten çıkarıldı.';
      } else {
        yanit = 'Sepet zaten boş.';
      }
    }

    setState(() {
      _kullaniciMetni = komutMetni;
      _asistanCevabi = yanit;
      _dinleniyor = false;
    });

    _seslendir(yanit);
  }

  @override
  Widget build(BuildContext context) {
    final profilYoneticisi = context.watch<ProfilYoneticisi>();
    final profil = profilYoneticisi.profil;
    final bool isRenkKoru = profil.profilTuru == ProfilTuru.renkKoruModu;
    final bool kolayMod = profilYoneticisi.kolayMod;
    final palet = profilYoneticisi.renkPaleti;

    // Modlara göre renk teması
    final Color anaRenk = kolayMod
        ? UygulamaRenkleri.kolayModSari
        : (isRenkKoru ? palet.primary : UygulamaRenkleri.anaZumrut);

    final Color ikincilRenk = kolayMod
        ? Colors.white
        : (isRenkKoru ? palet.secondary : const Color(0xFF00875A));

    final Color zeminRengi = kolayMod ? const Color(0xFF1E1E1E) : Colors.white;
    final Color anaMetinRengi = kolayMod ? Colors.white : UygulamaRenkleri.koyuYazi;
    final Color altMetinRengi = kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi;
    final Color kartZemini = kolayMod ? const Color(0xFF2A2A2A) : anaRenk.withValues(alpha: 0.07);

    return Container(
      decoration: BoxDecoration(
        color: zeminRengi,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.boslukBuyuk, 12, Olculer.boslukBuyuk, Olculer.boslukBuyuk),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Üst Tutamaç Çizgisi
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kolayMod ? Colors.white30 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Durum Çubuğu & Kapatma Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _dinleniyor ? anaRenk : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dinleniyor ? 'Sizi Dinliyorum...' : 'Hazır',
                        style: TextStyle(
                          color: anaMetinRengi,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _susturuldu ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: _susturuldu ? Colors.grey : anaRenk,
                          size: 22,
                        ),
                        tooltip: _susturuldu ? 'Sesi Aç' : 'Sustur',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _susturuldu = !_susturuldu);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: altMetinRengi, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Sabit Boyutlu Ses Dalgası (Ekranı Kesinlikle Sarsmaz/Zıplatmaz)
              _IzoleSesDalgasiWidget(
                aktifMi: _dinleniyor,
                anaRenk: anaRenk,
                ikincilRenk: ikincilRenk,
              ),
              const SizedBox(height: 12),

              // 4. Merkez Mikrofon Butonu
              GestureDetector(
                onTap: _dinlemeTetikle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: anaRenk,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: anaRenk.withValues(alpha: _dinleniyor ? 0.45 : 0.2),
                        blurRadius: _dinleniyor ? 18 : 8,
                        spreadRadius: _dinleniyor ? 4 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _dinleniyor ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: kolayMod ? Colors.black : Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Kullanıcı Söylediği & Asistan Yanıtı (Sade ve Net)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kartZemini,
                  borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                  border: Border.all(
                    color: anaRenk.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı Metni
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 16, color: altMetinRengi),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '"$_kullaniciMetni"',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: altMetinRengi,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Asistan Yanıtı
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, size: 18, color: anaRenk),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _asistanCevabi,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: anaMetinRengi,
                            ),
                          ),
                        ),
                        if (!_susturuldu)
                          InkWell(
                            onTap: () => _seslendir(_asistanCevabi),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.volume_up_outlined, size: 18, color: anaRenk),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 6. Hızlı Öneri Çipleri
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _komutCipi('🛍️ Sepette ne var?', anaRenk, kolayMod),
                    const SizedBox(width: 8),
                    _komutCipi('💰 Bütçem ne kadar?', anaRenk, kolayMod),
                    const SizedBox(width: 8),
                    _komutCipi('↩️ Son ürünü çıkar', anaRenk, kolayMod),
                    const SizedBox(width: 8),
                    _komutCipi('🧹 Sepeti sıfırla', anaRenk, kolayMod),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _komutCipi(String etiket, Color vurguRengi, bool kolayMod) {
    return InkWell(
      onTap: () => _hazirKomutSec(etiket),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kolayMod ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: kolayMod ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        child: Text(
          etiket,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kolayMod ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

/// Ekranı ASLA sarsmayan, sabit yükseklikli ve sadece kendi içinde dalgalanan
/// izole ses çubukları bileşeni.
class _IzoleSesDalgasiWidget extends StatefulWidget {
  final bool aktifMi;
  final Color anaRenk;
  final Color ikincilRenk;

  const _IzoleSesDalgasiWidget({
    required this.aktifMi,
    required this.anaRenk,
    required this.ikincilRenk,
  });

  @override
  State<_IzoleSesDalgasiWidget> createState() => _IzoleSesDalgasiWidgetState();
}

class _IzoleSesDalgasiWidgetState extends State<_IzoleSesDalgasiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sabit 42 piksel yükseklik - ebeveyn widget'ı asla itmez
    return SizedBox(
      height: 42,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(11, (index) {
              final double faz = (index / 11) * 2 * 3.14159;
              final double carpan = widget.aktifMi
                  ? (0.3 + 0.7 * ((_animController.value * 2 * 3.14159 + faz).abs() % 1.0))
                  : 0.15;
              final double yukseklik = 8 + (30 * carpan);

              final Color cubukRengi = index % 2 == 0 ? widget.anaRenk : widget.ikincilRenk;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 4,
                height: yukseklik,
                decoration: BoxDecoration(
                  color: cubukRengi,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
