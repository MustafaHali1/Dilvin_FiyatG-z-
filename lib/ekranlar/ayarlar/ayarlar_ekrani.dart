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
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: UygulamaRenkleri.tehlikeKirmizi),
              title: Text('Tüm Fişleri Sil', style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.tehlikeKirmizi)),
              subtitle: const Text('Cihazdaki SQLite veritabanını temizler'),
              onTap: () => _tumFisleriSilOnay(context),
            ),
          ),
        ],
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
                  leading: const Icon(Icons.visibility_rounded, color: UygulamaRenkleri.bilgiMavi),
                  title: Text('Renk Körü Modu', style: MetinStilleri.govdeKalin()),
                  subtitle: const Text('Renge bağımlı olmayan güvenli mavi/turuncu palet'),
                  trailing: yonetici.profil.profilTuru == ProfilTuru.renkKoruModu
                      ? const Icon(Icons.check_circle, color: UygulamaRenkleri.anaZumrut)
                      : null,
                  onTap: () {
                    yonetici.profilAyarla(ProfilTuru.renkKoruModu);
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
    }
  }
}
