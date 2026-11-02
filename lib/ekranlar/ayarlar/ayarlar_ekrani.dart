import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../../yoneticiler/kullanici_yoneticisi.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../profil/kullanici_profili_ekrani.dart';
import '../onboarding/okuma_testi_ekrani.dart';
import '../onboarding/renk_korlugu_secim_ekrani.dart';
import '../onboarding/renk_testi_sorusu_ekrani.dart';

/// Ayarlar ve Kişiselleştirme Ekranı
class AyarlarEkrani extends StatelessWidget {
  final VoidCallback? onFisleriTemizle;

  const AyarlarEkrani({super.key, this.onFisleriTemizle});

  @override
  Widget build(BuildContext context) {
    final profilYoneticisi = context.watch<ProfilYoneticisi>();
    final profil = profilYoneticisi.profil;
    final kullanici = context.watch<KullaniciYoneticisi>().kullanici;
    final bool kolayMod = profilYoneticisi.kolayMod;

    final Color arkaPlanRengi = kolayMod ? Colors.black : UygulamaRenkleri.arkaPlan;
    final Color kartRengi = kolayMod ? const Color(0xFF1E1E1E) : Colors.white;
    final Color kartBorderRengi = kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.cizgi;
    final Color anaMetinRengi = kolayMod ? Colors.white : UygulamaRenkleri.koyuYazi;
    final Color altMetinRengi = kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi;
    final Color baslikBolumRengi = kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.griYazi;
    final Color ikonRengi = kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaKoyu;

    return Scaffold(
      backgroundColor: arkaPlanRengi,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: kolayMod
              ? MetinStilleri.kolayModBaslik()
              : MetinStilleri.baslik2(),
        ),
        backgroundColor: kolayMod ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kolayMod ? UygulamaRenkleri.kolayModSari : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // Kullanıcı Hesabı Bölümü
          Text(
            'KULLANICI HESABI',
            style: TextStyle(
              color: baslikBolumRengi,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: Olculer.boslukKucuk),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KullaniciProfiliEkrani()),
              );
            },
            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
            child: Container(
              padding: const EdgeInsets.all(Olculer.boslukOrta),
              decoration: BoxDecoration(
                color: kartRengi,
                borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                border: Border.all(color: kartBorderRengi, width: kolayMod ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaZumrut,
                    child: Text(
                      kullanici.adSoyad.isNotEmpty ? kullanici.adSoyad[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                          kullanici.adSoyad,
                          style: TextStyle(
                            fontSize: kolayMod ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: anaMetinRengi,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kullanici.eposta,
                          style: TextStyle(
                            fontSize: kolayMod ? 14 : 12,
                            color: altMetinRengi,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: altMetinRengi),
                ],
              ),
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Bütçe Ayarları Bölümü
          Text(
            'BÜTÇE AYARLARI',
            style: TextStyle(
              color: baslikBolumRengi,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: kartBorderRengi, width: kolayMod ? 1.5 : 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aylık Bütçe Hedefi',
                      style: TextStyle(
                        fontSize: kolayMod ? 18 : 15,
                        fontWeight: FontWeight.bold,
                        color: anaMetinRengi,
                      ),
                    ),
                    Text(
                      '${profil.aylikButce.toStringAsFixed(0)} ₺',
                      style: TextStyle(
                        fontSize: kolayMod ? 22 : 14,
                        fontWeight: FontWeight.w900,
                        color: kolayMod ? UygulamaRenkleri.kolayModSari : altMetinRengi,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _butceDuzenleDiyalogu(context, profilYoneticisi),
                  style: TextButton.styleFrom(
                    foregroundColor: kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaZumrut,
                  ),
                  child: Text(
                    'Değiştir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: kolayMod ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Erişilebilirlik Bölümü
          Text(
            'ERİŞİLEBİLİRLİK VE MODLAR',
            style: TextStyle(
              color: baslikBolumRengi,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: kartBorderRengi, width: kolayMod ? 1.5 : 1),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: ikonRengi),
                  title: Text(
                    'Aktif Mod',
                    style: TextStyle(
                      fontSize: kolayMod ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: anaMetinRengi,
                    ),
                  ),
                  subtitle: Text(
                    _profilMetni(profil.profilTuru),
                    style: TextStyle(color: altMetinRengi),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: altMetinRengi),
                  onTap: () => _modSecimDiyalogu(context, profilYoneticisi),
                ),
                if (profil.profilTuru == ProfilTuru.renkKoruModu) ...[
                  Divider(height: 1, color: kartBorderRengi),
                  ListTile(
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: RenkKorluguPaleti.getir(profil.renkKorluguTuru).primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      'Renk Körlüğü Türü',
                      style: TextStyle(fontWeight: FontWeight.bold, color: anaMetinRengi),
                    ),
                    subtitle: Text(
                      '${RenkKorluguPaleti.getir(profil.renkKorluguTuru).turAdi} (${RenkKorluguPaleti.getir(profil.renkKorluguTuru).turAciklamasi})',
                      style: TextStyle(color: altMetinRengi),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _renkNoktasi(RenkKorluguPaleti.getir(profil.renkKorluguTuru).primary),
                        const SizedBox(width: 4),
                        _renkNoktasi(RenkKorluguPaleti.getir(profil.renkKorluguTuru).secondary),
                        const SizedBox(width: 4),
                        _renkNoktasi(RenkKorluguPaleti.getir(profil.renkKorluguTuru).warning),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: altMetinRengi),
                      ],
                    ),
                    onTap: () => _renkKoruTuruSecimDiyalogu(context, profilYoneticisi),
                  ),
                ],
                Divider(height: 1, color: kartBorderRengi),
                SwitchListTile(
                  secondary: Icon(Icons.volume_up_outlined, color: ikonRengi),
                  title: Text(
                    'Sesli Asistan',
                    style: TextStyle(
                      fontSize: kolayMod ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: anaMetinRengi,
                    ),
                  ),
                  subtitle: Text(
                    'Fiyatları ve toplamı seslendir',
                    style: TextStyle(color: altMetinRengi),
                  ),
                  value: profil.sesliAsistanAcik,
                  activeThumbColor: kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaZumrut,
                  onChanged: (val) => profilYoneticisi.sesliAsistanDegistir(val),
                ),
                Divider(height: 1, color: kartBorderRengi),
                SwitchListTile(
                  secondary: Icon(Icons.vibration_rounded, color: ikonRengi),
                  title: Text(
                    'Titreşimli Geri Bildirim',
                    style: TextStyle(
                      fontSize: kolayMod ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: anaMetinRengi,
                    ),
                  ),
                  subtitle: Text(
                    'Kamera taramasında ve bütçe aşımında uyar',
                    style: TextStyle(color: altMetinRengi),
                  ),
                  value: profil.titresimAcik,
                  activeThumbColor: kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaZumrut,
                  onChanged: (val) => profilYoneticisi.titresimDegistir(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Veri ve Sıfırlama
          Text(
            'VERİLER VE GÜVENLİK',
            style: TextStyle(
              color: baslikBolumRengi,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: kartBorderRengi, width: kolayMod ? 1.5 : 1),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.restart_alt_rounded,
                    color: kolayMod ? UygulamaRenkleri.kolayModSari : UygulamaRenkleri.anaZumrut,
                  ),
                  title: Text(
                    'Kurulum Testlerini Yeniden Yap',
                    style: TextStyle(
                      fontSize: kolayMod ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: anaMetinRengi,
                    ),
                  ),
                  subtitle: Text(
                    'Renk körlüğü ve okuma testini baştan başlatır',
                    style: TextStyle(color: altMetinRengi),
                  ),
                  onTap: () {
                    profilYoneticisi.kurulumTamamlandiAyarla(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kurulum modu yeniden başlatıldı.')),
                    );
                  },
                ),
                Divider(height: 1, color: kartBorderRengi),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: UygulamaRenkleri.tehlikeKirmizi),
                  title: Text(
                    'Tüm Fişleri Sil',
                    style: TextStyle(
                      fontSize: kolayMod ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: UygulamaRenkleri.tehlikeKirmizi,
                    ),
                  ),
                  subtitle: Text(
                    'Cihazdaki SQLite veritabanını temizler',
                    style: TextStyle(color: altMetinRengi),
                  ),
                  onTap: () => _tumFisleriSilOnay(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renkNoktasi(Color renk) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
    );
  }

  void _renkKoruTuruSecimDiyalogu(BuildContext context, ProfilYoneticisi yonetici) {
    final bool koyuTema = yonetici.kolayMod;
    showModalBottomSheet(
      context: context,
      backgroundColor: koyuTema ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Olculer.yariCapBuyuk)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renk Körlüğü Türünü Seç',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: koyuTema ? Colors.white : UygulamaRenkleri.koyuYazi,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uygulama renkleri seçtiğin tıbbi palete göre anında güncellenir.',
                  style: TextStyle(
                    fontSize: 14,
                    color: koyuTema ? Colors.white70 : UygulamaRenkleri.griYazi,
                  ),
                ),
                const SizedBox(height: Olculer.boslukOrta),

                // 1. Deuteranopia
                _renkKoruTurSatiri(
                  context: context,
                  yonetici: yonetici,
                  tur: RenkKorluguTuru.deuteranopi,
                  palet: RenkKorluguPaleti.deuteranopia,
                ),
                // 2. Protanopia
                _renkKoruTurSatiri(
                  context: context,
                  yonetici: yonetici,
                  tur: RenkKorluguTuru.protanopi,
                  palet: RenkKorluguPaleti.protanopia,
                ),
                // 3. Tritanopia
                _renkKoruTurSatiri(
                  context: context,
                  yonetici: yonetici,
                  tur: RenkKorluguTuru.tritanopi,
                  palet: RenkKorluguPaleti.tritanopia,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kontrastliRozet({required String etiket, required Color renk}) {
    // WCAG 2.1 AA/AAA Kontrast: Açık zeminlerde koyu metin, koyu zeminlerde beyaz metin
    final bool koyuZemin = ThemeData.estimateBrightnessForColor(renk) == Brightness.dark;
    final Color metinRengi = koyuZemin ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        etiket,
        style: TextStyle(
          color: metinRengi,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _renkKoruTurSatiri({
    required BuildContext context,
    required ProfilYoneticisi yonetici,
    required RenkKorluguTuru tur,
    required RenkKorluguPaleti palet,
  }) {
    final bool seciliMi = yonetici.profil.renkKorluguTuru == tur;

    // Her türün kendine ait 3 kontrastlı renk etiketi (Primary, Secondary, Accent)
    final Color accentRenk = tur == RenkKorluguTuru.protanopi
        ? palet.info // Açık Mavi #56B4E9
        : (tur == RenkKorluguTuru.tritanopi ? palet.warning : palet.error); // Magenta #CC79A7

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: seciliMi ? palet.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
        border: Border.all(
          color: seciliMi ? palet.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: palet.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: palet.primary.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: seciliMi
              ? const Icon(Icons.check, color: Colors.white, size: 22)
              : null,
        ),
        title: Text(
          '${palet.turAdi} (${palet.turAciklamasi})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: yonetici.kolayMod ? Colors.white : UygulamaRenkleri.koyuYazi,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _kontrastliRozet(etiket: 'Primary', renk: palet.primary),
              _kontrastliRozet(etiket: 'Secondary', renk: palet.secondary),
              _kontrastliRozet(etiket: 'Accent', renk: accentRenk),
            ],
          ),
        ),
        trailing: seciliMi
            ? Icon(Icons.check_circle, color: palet.primary, size: 28)
            : null,
        onTap: () {
          yonetici.renkKorluguTuruAyarla(tur);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: palet.primary,
              content: Text(
                'Palet güncellendi: ${palet.turAdi} (${palet.turAciklamasi})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  void _modSecimDiyalogu(BuildContext context, ProfilYoneticisi yonetici) {
    final bool kolayMod = yonetici.kolayMod;
    final Color zeminRengi = kolayMod ? const Color(0xFF1E1E1E) : Colors.white;
    final Color baslikRengi = kolayMod ? Colors.white : UygulamaRenkleri.koyuYazi;
    final Color altRengi = kolayMod ? Colors.white70 : UygulamaRenkleri.griYazi;

    showModalBottomSheet(
      context: context,
      backgroundColor: zeminRengi,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Olculer.yariCapBuyuk)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Olculer.boslukBuyuk),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uygulama Modunu Değiştir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: baslikRengi),
                ),
                const SizedBox(height: Olculer.boslukOrta),

                // 1. Standart Mod
                ListTile(
                  leading: const Icon(Icons.grid_view_rounded, color: UygulamaRenkleri.anaZumrut, size: 28),
                  title: Text('Standart Mod', style: TextStyle(fontWeight: FontWeight.bold, color: baslikRengi)),
                  subtitle: Text('Klasik zümrüt yeşili modern tema', style: TextStyle(color: altRengi)),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.standart
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut, size: 26)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.standart);
                    Navigator.of(bottomSheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Standart moda geçildi.')),
                    );
                  },
                ),

                // 2. Kolay Mod (Görme ve Harf Boyutu Testi ile)
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded, color: UygulamaRenkleri.kolayModSari, size: 28),
                  title: Text('Kolay Mod (Yüksek Kontrast)', style: TextStyle(fontWeight: FontWeight.bold, color: baslikRengi)),
                  subtitle: Text('Büyük yazılar ve siyah zemin üzerine sarı butonlar', style: TextStyle(color: altRengi)),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.kolayMod
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.kolayModSari, size: 26)
                      : null,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    // Doğrudan Okuma ve Görme Testi Ekranına yönlendiriyoruz
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OkumaTestiEkrani(
                          onSecildi: (secilenBoyut) async {
                            await yonetici.yaziBoyutuAyarla(secilenBoyut);
                            await yonetici.profilAyarla(ProfilTuru.kolayMod);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: UygulamaRenkleri.kolayModSari,
                                  content: Text(
                                    'Kolay Mod aktif! Yazı boyutu: ${secilenBoyut.toInt()} px olarak ayarlandı.',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),

                // 3. Renk Körü Modu (Renk Testi ve Palet Seçimi ile)
                ListTile(
                  leading: Icon(Icons.visibility_rounded, color: yonetici.renkPaleti.primary, size: 28),
                  title: Text('Renk Körü Modu', style: TextStyle(fontWeight: FontWeight.bold, color: baslikRengi)),
                  subtitle: Text('Renge bağımlı olmayan güvenli Okabe-Ito paleti', style: TextStyle(color: altRengi)),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.renkKoruModu
                      ? Icon(Icons.check_circle, color: yonetici.renkPaleti.primary, size: 26)
                      : null,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RenkKorluguSecimEkrani(
                          onSecildi: (tur) async {
                            await yonetici.renkKorluguTuruAyarla(tur);
                            await yonetici.profilAyarla(ProfilTuru.renkKoruModu);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: RenkKorluguPaleti.getir(tur).primary,
                                  content: Text(
                                    'Renk Körü Modu aktif: ${tur.name}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                          },
                          onTestBaslat: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RenkTestiSorusuEkrani(
                                  onTestTamamlandi: () {
                                    yonetici.profilAyarla(ProfilTuru.renkKoruModu);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // 4. Görme Engelli Modu (Sesli Radar)
                ListTile(
                  leading: const Icon(Icons.radar, color: Color(0xFFFFD600), size: 28),
                  title: Text('Görme Engelli (Sesli Radar Modu)', style: TextStyle(fontWeight: FontWeight.bold, color: baslikRengi)),
                  subtitle: Text('Tam sesli okuma, haptik radar ve konuşan asistan', style: TextStyle(color: altRengi)),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.gormeEngelliModu
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut, size: 26)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.gormeEngelliModu);
                    Navigator.of(bottomSheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Görme Engelli Sesli Radar moduna geçildi.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _butceDuzenleDiyalogu(BuildContext context, ProfilYoneticisi yonetici) {
    final denetleyici = TextEditingController(text: yonetici.profil.aylikButce.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aylık Bütçe Hedefi'),
        content: TextField(
          controller: denetleyici,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bütçe Tutarı (₺)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final yeni = double.tryParse(denetleyici.text);
              if (yeni != null && yeni > 0) {
                yonetici.butceAyarla(yeni);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _tumFisleriSilOnay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Fişler Silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz. Kayıtlı tüm alışveriş geçmişiniz silinecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<FisYoneticisi>().tumFisleriTemizle();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm alışveriş geçmişi veritabanından temizlendi.')),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: UygulamaRenkleri.tehlikeKirmizi)),
          ),
        ],
      ),
    );
  }

  String _profilMetni(ProfilTuru tur) {
    switch (tur) {
      case ProfilTuru.standart:
        return 'Standart Mod';
      case ProfilTuru.kolayMod:
        return 'Kolay Mod (Yüksek Kontrast)';
      case ProfilTuru.renkKoruModu:
        return 'Renk Körü Modu';
      case ProfilTuru.gormeEngelliModu:
        return 'Sesli Radar & Haptik Mod';
    }
  }
}
