import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/profil_yoneticisi.dart';

/// Ayarlar ve Kişiselleştirme Ekranı
class AyarlarEkrani extends StatelessWidget {
  final VoidCallback? onFisleriTemizle;

  const AyarlarEkrani({super.key, this.onFisleriTemizle});

  @override
  Widget build(BuildContext context) {
    final profilYoneticisi = context.watch<ProfilYoneticisi>();
    final profil = profilYoneticisi.profil;

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text('Ayarlar', style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Olculer.boslukBuyuk),
        children: [
          // Bütçe Ayarları Bölümü
          Text('BÜTÇE AYARLARI', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            padding: const EdgeInsets.all(Olculer.boslukOrta),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: UygulamaRenkleri.cizgi),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aylık Bütçe Hedefi', style: MetinStilleri.govdeKalin()),
                    Text('${profil.aylikButce.toStringAsFixed(0)} ₺', style: MetinStilleri.aciklama()),
                  ],
                ),
                TextButton(
                  onPressed: () => _butceDuzenleDiyalogu(context, profilYoneticisi),
                  child: const Text('Değiştir'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Erişilebilirlik Bölümü
          Text('ERİŞİLEBİLİRLİK VE MODLAR', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: UygulamaRenkleri.cizgi),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: UygulamaRenkleri.anaKoyu),
                  title: Text('Aktif Mod', style: MetinStilleri.govdeKalin()),
                  subtitle: Text(_profilMetni(profil.profilTuru)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _modSecimDiyalogu(context, profilYoneticisi),
                ),
                if (profil.profilTuru == ProfilTuru.renkKoruModu) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: RenkKorluguPaleti.getir(profil.renkKorluguTuru).primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text('Renk Körlüğü Türü', style: MetinStilleri.govdeKalin()),
                    subtitle: Text(
                      '${RenkKorluguPaleti.getir(profil.renkKorluguTuru).turAdi} (${RenkKorluguPaleti.getir(profil.renkKorluguTuru).turAciklamasi})',
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
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () => _renkKoruTuruSecimDiyalogu(context, profilYoneticisi),
                  ),
                ],
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined, color: UygulamaRenkleri.anaKoyu),
                  title: Text('Sesli Asistan', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Fiyatları ve toplamı seslendir'),
                  value: profil.sesliAsistanAcik,
                  activeThumbColor: UygulamaRenkleri.anaZumrut,
                  onChanged: (val) => profilYoneticisi.sesliAsistanDegistir(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded, color: UygulamaRenkleri.anaKoyu),
                  title: Text('Titreşimli Geri Bildirim', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Kamera taramasında ve bütçe aşımında uyar'),
                  value: profil.titresimAcik,
                  activeThumbColor: UygulamaRenkleri.anaZumrut,
                  onChanged: (val) => profilYoneticisi.titresimDegistir(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: Olculer.boslukBuyuk),

          // Veri ve Sıfırlama
          Text('VERİLER VE GÜVENLİK', style: MetinStilleri.aciklama().copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: Olculer.boslukKucuk),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
              border: Border.all(color: UygulamaRenkleri.cizgi),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded, color: UygulamaRenkleri.anaZumrut),
                  title: Text('Kurulum Testlerini Yeniden Yap', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Renk körlüğü ve okuma testini baştan başlatır'),
                  onTap: () {
                    profilYoneticisi.kurulumTamamlandiAyarla(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kurulum modu yeniden başlatıldı.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: UygulamaRenkleri.tehlikeKirmizi),
                  title: Text('Tüm Fişleri Sil', style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.tehlikeKirmizi)),
                  subtitle: const Text('Cihazdaki SQLite veritabanını temizler'),
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
    showModalBottomSheet(
      context: context,
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
                Text('Renk Körlüğü Türünü Seç', style: MetinStilleri.baslik2()),
                const SizedBox(height: 6),
                Text(
                  'Uygulama renkleri seçtiğin tıbbi palete göre anında güncellenir.',
                  style: MetinStilleri.aciklama(),
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
        title: Text('${palet.turAdi} (${palet.turAciklamasi})', style: MetinStilleri.govdeKalin()),
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
    showModalBottomSheet(
      context: context,
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
                Text('Uygulama Modunu Değiştir', style: MetinStilleri.baslik2()),
                const SizedBox(height: Olculer.boslukOrta),
                ListTile(
                  leading: const Icon(Icons.grid_view_rounded, color: UygulamaRenkleri.anaZumrut),
                  title: Text('Standart Mod', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Klasik zümrüt yeşili modern tema'),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.standart
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.standart);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded, color: UygulamaRenkleri.uyariTuruncu),
                  title: Text('Kolay Mod (Yüksek Kontrast)', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Büyük yazılar ve siyah zemin üzerine sarı butonlar'),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.kolayMod
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.kolayMod);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.visibility_rounded, color: yonetici.renkPaleti.primary),
                  title: Text('Renk Körü Modu', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Renge bağımlı olmayan güvenli Okabe-Ito paleti'),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.renkKoruModu
                      ? Icon(Icons.check_circle, color: yonetici.renkPaleti.primary)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.renkKoruModu);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.radar, color: Color(0xFFFFD600)),
                  title: Text('Görme Engelli (Sesli Radar Modu)', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Tam sesli okuma, haptik radar ve konuşan asistan'),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.gormeEngelliModu
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.gormeEngelliModu);
                    Navigator.of(context).pop();
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm geçmiş temizlendi.')),
              );
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
