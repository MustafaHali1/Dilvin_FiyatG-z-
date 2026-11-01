import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiyatgoz/sabitler/uygulama_renkleri.dart';
import 'package:fiyatgoz/sabitler/olculer.dart';
import 'package:fiyatgoz/sabitler/metin_stilleri.dart';
import 'package:fiyatgoz/modeller/profil_modeli.dart';
import 'package:fiyatgoz/yoneticiler/profil_yoneticisi.dart';

/// Ayarlar ve Kişiselleştirme Ekranı
class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

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
                  onPressed: () {},
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
                  onTap: () {},
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
              onTap: () {},
            ),
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
