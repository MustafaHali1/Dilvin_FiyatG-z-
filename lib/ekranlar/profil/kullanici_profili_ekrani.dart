import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../bilesenler/ozel_buton.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/kullanici_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../ayarlar/ayarlar_ekrani.dart';

/// Kullanıcı Profili ve E-Posta İndirim Bülteni Yönetim Ekranı
/// Temiz mimari: İnce ekran yapısı, modüler alt bileşenler, Provider entegrasyonu.
class KullaniciProfiliEkrani extends StatefulWidget {
  const KullaniciProfiliEkrani({super.key});

  @override
  State<KullaniciProfiliEkrani> createState() => _KullaniciProfiliEkraniState();
}

class _KullaniciProfiliEkraniState extends State<KullaniciProfiliEkrani> {
  late TextEditingController _adSoyadKontrolcu;
  late TextEditingController _epostaKontrolcu;
  bool _formDegisti = false;

  @override
  void initState() {
    super.initState();
    final kullanici = context.read<KullaniciYoneticisi>().kullanici;
    _adSoyadKontrolcu = TextEditingController(text: kullanici.adSoyad);
    _epostaKontrolcu = TextEditingController(text: kullanici.eposta);
  }

  @override
  void dispose() {
    _adSoyadKontrolcu.dispose();
    _epostaKontrolcu.dispose();
    super.dispose();
  }

  void _kaydet() async {
    HapticFeedback.mediumImpact();
    final ad = _adSoyadKontrolcu.text.trim();
    final eposta = _epostaKontrolcu.text.trim();

    if (ad.isEmpty || eposta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ad soyad ve e-posta alanlarını doldurun.'),
          backgroundColor: UygulamaRenkleri.tehlikeKirmizi,
        ),
      );
      return;
    }

    await context.read<KullaniciYoneticisi>().profiliGuncelle(
      adSoyad: ad,
      eposta: eposta,
    );

    setState(() => _formDegisti = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil bilgileriniz başarıyla güncellendi!'),
          backgroundColor: UygulamaRenkleri.basari,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilYoneticisi = context.watch<ProfilYoneticisi>();
    final profil = profilYoneticisi.profil;
    final kullaniciYoneticisi = context.watch<KullaniciYoneticisi>();
    final fisYoneticisi = context.watch<FisYoneticisi>();
    final kullanici = kullaniciYoneticisi.kullanici;

    final kolayMod = profil.profilTuru == ProfilTuru.kolayMod;
    final renkKoru = profil.profilTuru == ProfilTuru.renkKoruModu;
    final palet = profilYoneticisi.renkPaleti;

    final arkaPlan = kolayMod
        ? Colors.black
        : (renkKoru ? const Color(0xFFF8FAFC) : UygulamaRenkleri.arkaPlan);

    final anaRenk = kolayMod
        ? UygulamaRenkleri.kolayModSari
        : (renkKoru ? palet.primary : UygulamaRenkleri.anaZumrut);

    return Scaffold(
      backgroundColor: arkaPlan,
      appBar: AppBar(
        title: Text(
          'Kullanıcı Profili',
          style: kolayMod
              ? MetinStilleri.kolayModBaslik(renk: Colors.white)
              : MetinStilleri.baslik2(),
        ),
        backgroundColor: kolayMod ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kolayMod ? Colors.white : Colors.black87),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Olculer.boslukBuyuk),
          children: [
            // 1. Profil Başlık Kartı (Avatar ve Aktif Mod Rozeti)
            _ProfilAvatarKarti(
              adSoyad: kullanici.adSoyad,
              eposta: kullanici.eposta,
              profilTuru: profil.profilTuru,
              anaRenk: anaRenk,
              kolayMod: kolayMod,
              renkKoru: renkKoru,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 2. Alışveriş & Tasarruf İstatistik Kartı
            _AlisverisIstatistikKarti(
              toplamFis: fisYoneticisi.fisSayisi,
              buAyHarcama: fisYoneticisi.donemHarcamasi(profil),
              toplamTasarruf: fisYoneticisi.toplamTasarruf,
              anaRenk: anaRenk,
              kolayMod: kolayMod,
              donemEtiketi: profil.butceDonemiFormatli,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 3. Bilgi Düzenleme Formu
            _KullaniciFormKarti(
              adSoyadKontrolcu: _adSoyadKontrolcu,
              epostaKontrolcu: _epostaKontrolcu,
              onChanged: (_) {
                if (!_formDegisti) setState(() => _formDegisti = true);
              },
              anaRenk: anaRenk,
              kolayMod: kolayMod,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 4. Haftalık İndirim & E-Posta Bülteni
            _EpostaBulteniKarti(
              aktif: kullanici.epostaBulteniAktif,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                context.read<KullaniciYoneticisi>().profiliGuncelle(
                  epostaBulteniAktif: val,
                );
              },
              anaRenk: anaRenk,
              kolayMod: kolayMod,
            ),
            const SizedBox(height: Olculer.boslukBuyuk),

            // 5. Bilgileri Güncelle Butonu
            OzelButon(
              metin: 'Bilgileri Kaydet',
              ikon: Icons.save_rounded,
              renk: anaRenk,
              onPressed: _kaydet,
            ),
            const SizedBox(height: Olculer.boslukOrta),
          ],
        ),
      ),
    );
  }
}

/// 1. Profil Avatar ve Mod Rozet Bileşeni
class _ProfilAvatarKarti extends StatelessWidget {
  final String adSoyad;
  final String eposta;
  final ProfilTuru profilTuru;
  final Color anaRenk;
  final bool kolayMod;
  final bool renkKoru;

  const _ProfilAvatarKarti({
    required this.adSoyad,
    required this.eposta,
    required this.profilTuru,
    required this.anaRenk,
    required this.kolayMod,
    required this.renkKoru,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: BoxDecoration(
        color: kolayMod ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(
          color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi,
          width: kolayMod ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: anaRenk,
            child: Text(
              adSoyad.isNotEmpty ? adSoyad[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kolayMod ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: Olculer.boslukOrta),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adSoyad,
                  style: kolayMod
                      ? MetinStilleri.kolayModBaslik(renk: Colors.white)
                      : MetinStilleri.baslik2(),
                ),
                const SizedBox(height: 4),
                Text(
                  eposta,
                  style: TextStyle(
                    fontSize: 14,
                    color: kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AyarlarEkrani()),
                    );
                  },
                  borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: anaRenk.withValues(alpha: kolayMod ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(Olculer.yariCapKucuk),
                      border: Border.all(color: anaRenk),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _modEtiketi(profilTuru),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kolayMod ? UygulamaRenkleri.kolayModSari : anaRenk,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.tune_rounded, size: 14, color: kolayMod ? UygulamaRenkleri.kolayModSari : anaRenk),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _modEtiketi(ProfilTuru tur) {
    switch (tur) {
      case ProfilTuru.standart:
        return 'STANDART MOD';
      case ProfilTuru.kolayMod:
        return 'KOLAY MOD';
      case ProfilTuru.renkKoruModu:
        return 'RENK KÖRÜ MODU';
      case ProfilTuru.gormeEngelliModu:
        return 'SESLİ RADAR MODU';
    }
  }
}

/// 2. Harcama ve İndirim Tasarruf İstatistikleri Bileşeni
class _AlisverisIstatistikKarti extends StatelessWidget {
  final int toplamFis;
  final double buAyHarcama;
  final double toplamTasarruf;
  final Color anaRenk;
  final bool kolayMod;
  final String? donemEtiketi;

  const _AlisverisIstatistikKarti({
    required this.toplamFis,
    required this.buAyHarcama,
    required this.toplamTasarruf,
    required this.anaRenk,
    required this.kolayMod,
    this.donemEtiketi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: BoxDecoration(
        color: kolayMod ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(
          color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi,
          width: kolayMod ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: anaRenk, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  donemEtiketi != null
                      ? 'HARCAMA RAPORU ($donemEtiketi)'
                      : 'HARCAMA VE KÂR RAPORU',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    fontSize: 13,
                    color: kolayMod ? UygulamaRenkleri.kolayModSari : anaRenk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          Row(
            children: [
              Expanded(
                child: _MetrikKutusu(
                  baslik: 'Kayıtlı Fiş',
                  deger: '$toplamFis Adet',
                  kolayMod: kolayMod,
                  ikon: Icons.receipt_long_rounded,
                  vurgu: anaRenk,
                ),
              ),
              const SizedBox(width: Olculer.boslukOrta),
              Expanded(
                child: _MetrikKutusu(
                  baslik: 'Dönem Harcaması',
                  deger: '${buAyHarcama.toStringAsFixed(2)} ₺',
                  kolayMod: kolayMod,
                  ikon: Icons.credit_card_rounded,
                  vurgu: anaRenk,
                ),
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          // Toplam İndirim Kazancı Vurgusu
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: kolayMod
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFD1FAE5).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(
                color: kolayMod
                    ? UygulamaRenkleri.kolayModSari
                    : UygulamaRenkleri.anaZumrut,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  color: UygulamaRenkleri.anaZumrut,
                  size: 28,
                ),
                const SizedBox(width: Olculer.boslukOrta),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam İndirim Tasarrufu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kolayMod ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        '${toplamTasarruf.toStringAsFixed(2)} ₺ kâr elde ettiniz',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UygulamaRenkleri.anaZumrut,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetrikKutusu extends StatelessWidget {
  final String baslik;
  final String deger;
  final bool kolayMod;
  final IconData ikon;
  final Color vurgu;

  const _MetrikKutusu({
    required this.baslik,
    required this.deger,
    required this.kolayMod,
    required this.ikon,
    required this.vurgu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukOrta),
      decoration: BoxDecoration(
        color: kolayMod ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(color: kolayMod ? Colors.white12 : UygulamaRenkleri.cizgi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: vurgu),
          const SizedBox(height: 6),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              color: kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            deger,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kolayMod ? Colors.white : UygulamaRenkleri.koyuYazi,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Kullanıcı Bilgileri Formu
class _KullaniciFormKarti extends StatelessWidget {
  final TextEditingController adSoyadKontrolcu;
  final TextEditingController epostaKontrolcu;
  final ValueChanged<String> onChanged;
  final Color anaRenk;
  final bool kolayMod;

  const _KullaniciFormKarti({
    required this.adSoyadKontrolcu,
    required this.epostaKontrolcu,
    required this.onChanged,
    required this.anaRenk,
    required this.kolayMod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: BoxDecoration(
        color: kolayMod ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(
          color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi,
          width: kolayMod ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HESAP BİLGİLERİ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              fontSize: 13,
              color: kolayMod ? UygulamaRenkleri.kolayModSari : anaRenk,
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),
          TextField(
            controller: adSoyadKontrolcu,
            onChanged: onChanged,
            style: TextStyle(color: kolayMod ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'Ad Soyad',
              labelStyle: TextStyle(color: kolayMod ? Colors.white70 : Colors.black54),
              prefixIcon: Icon(Icons.person_outline, color: anaRenk),
              filled: true,
              fillColor: kolayMod ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: anaRenk, width: 2),
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukOrta),
          TextField(
            controller: epostaKontrolcu,
            onChanged: onChanged,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: kolayMod ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'E-Posta Adresi',
              labelStyle: TextStyle(color: kolayMod ? Colors.white70 : Colors.black54),
              prefixIcon: Icon(Icons.email_outlined, color: anaRenk),
              filled: true,
              fillColor: kolayMod ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                borderSide: BorderSide(color: anaRenk, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Haftalık İndirim Bülteni ve E-Posta Gönderim Kartı
class _EpostaBulteniKarti extends StatelessWidget {
  final bool aktif;
  final ValueChanged<bool> onChanged;
  final Color anaRenk;
  final bool kolayMod;

  const _EpostaBulteniKarti({
    required this.aktif,
    required this.onChanged,
    required this.anaRenk,
    required this.kolayMod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
      decoration: BoxDecoration(
        color: kolayMod ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(
          color: kolayMod ? Colors.white24 : UygulamaRenkleri.cizgi,
          width: kolayMod ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: anaRenk, size: 24),
              const SizedBox(width: 8),
              Text(
                'İNDİRİM BÜLTENİ VE DUYURULAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  fontSize: 13,
                  color: kolayMod ? UygulamaRenkleri.kolayModSari : anaRenk,
                ),
              ),
            ],
          ),
          const SizedBox(height: Olculer.boslukOrta),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.mark_email_read_outlined,
              color: aktif ? anaRenk : (kolayMod ? Colors.white54 : UygulamaRenkleri.griYazi),
              size: 28,
            ),
            title: Text(
              'Haftalık İndirimleri E-postama Gönder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kolayMod ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'En ucuz market ürünleri, aktüel kataloglar ve kaçırılmayacak fırsatlar haftalık olarak e-posta adresinize gönderilir.',
              style: TextStyle(
                fontSize: 12,
                color: kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi,
              ),
            ),
            value: aktif,
            activeThumbColor: anaRenk,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
