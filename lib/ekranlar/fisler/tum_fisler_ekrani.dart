import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../modeller/fis_modeli.dart';
import '../../modeller/profil_modeli.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../../yoneticiler/profil_yoneticisi.dart';
import '../ana_sayfa/bilesenler/fis_karti.dart';
import '../fis_detay/fis_detay_ekrani.dart';

/// Kullanıcının tüm kayıtlı fişlerini veya haftalık fişlerini detaylı arama ve filtreleme ile listeleyen ekran
/// Kolay Mod ve Standart Mod temalarını tam uyumlu şekilde destekler.
class TumFislerEkrani extends StatefulWidget {
  final String baslik;
  final bool sadeceHaftalik;
  final ValueChanged<FisModeli>? onFisSecildi;

  const TumFislerEkrani({
    super.key,
    this.baslik = 'Kayıtlı Fişlerim',
    this.sadeceHaftalik = false,
    this.onFisSecildi,
  });

  @override
  State<TumFislerEkrani> createState() => _TumFislerEkraniState();
}

class _TumFislerEkraniState extends State<TumFislerEkrani> {
  String _aramaMetni = '';

  @override
  Widget build(BuildContext context) {
    final fisYoneticisi = context.watch<FisYoneticisi>();
    final profilYoneticisi = context.watch<ProfilYoneticisi>();
    final bool kolayMod = profilYoneticisi.kolayMod;
    final bool isRenkKoru = profilYoneticisi.renkKoruModu;
    final palet = RenkKorluguPaleti.getir(profilYoneticisi.profil.renkKorluguTuru);
    final Color vurguRengi = kolayMod
        ? UygulamaRenkleri.kolayModSari
        : (isRenkKoru ? palet.primary : UygulamaRenkleri.anaZumrut);

    final kaynakFisler = widget.sadeceHaftalik
        ? fisYoneticisi.buHaftaninFisleri
        : fisYoneticisi.fisler;

    final filtrelenmis = kaynakFisler.where((f) {
      if (_aramaMetni.isEmpty) return true;
      final arama = _aramaMetni.toLowerCase();
      final marketUyumu = f.marketAdi.toLowerCase().contains(arama);
      final aciklamaUyumu = f.aciklama.toLowerCase().contains(arama);
      final urunUyumu = f.urunler.any((u) => u.ad.toLowerCase().contains(arama));
      return marketUyumu || aciklamaUyumu || urunUyumu;
    }).toList();

    final toplamTutar = filtrelenmis.fold(0.0, (toplam, f) => toplam + f.toplamTutar);

    final bool isKoyuStandart = profilYoneticisi.profil.profilTuru == ProfilTuru.standart &&
        profilYoneticisi.profil.karanlikModAcik;
    final bool isKoyu = kolayMod || isKoyuStandart;
    final Color zeminRengi = kolayMod
        ? Colors.black
        : (isKoyuStandart ? const Color(0xFF0F172A) : UygulamaRenkleri.arkaPlan);
    final Color ustKutuRengi = kolayMod
        ? const Color(0xFF1E1E1E)
        : (isKoyuStandart ? const Color(0xFF1E293B) : Colors.white);
    final Color aramaKutusuZemini = kolayMod
        ? Colors.black
        : (isKoyuStandart ? const Color(0xFF0F172A) : UygulamaRenkleri.arkaPlan);
    final Color anaYaziRengi = isKoyu ? Colors.white : Colors.black;
    final Color altYaziRengi = isKoyu ? const Color(0xFF94A3B8) : UygulamaRenkleri.griYazi;

    return Scaffold(
      backgroundColor: zeminRengi,
      appBar: AppBar(
        title: Text(
          widget.baslik,
          style: kolayMod
              ? MetinStilleri.kolayModBaslik()
              : MetinStilleri.baslik2(renk: anaYaziRengi),
        ),
        backgroundColor: zeminRengi,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: kolayMod
              ? UygulamaRenkleri.kolayModSari
              : (isKoyuStandart ? Colors.white : Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Arama ve İstatistik Özeti
          Container(
            color: ustKutuRengi,
            padding: const EdgeInsets.fromLTRB(
              Olculer.boslukBuyuk,
              0,
              Olculer.boslukBuyuk,
              Olculer.boslukBuyuk,
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _aramaMetni = val.trim()),
                  style: TextStyle(color: anaYaziRengi),
                  decoration: InputDecoration(
                    hintText: 'Fiş, market veya ürün ara...',
                    hintStyle: TextStyle(color: altYaziRengi),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: kolayMod
                          ? UygulamaRenkleri.kolayModSari
                          : (isKoyuStandart ? UygulamaRenkleri.anaZumrut : UygulamaRenkleri.griYazi),
                    ),
                    filled: true,
                    fillColor: aramaKutusuZemini,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                      borderSide: isKoyu
                          ? BorderSide(color: isKoyuStandart ? const Color(0xFF334155) : Colors.white24)
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                      borderSide: isKoyu
                          ? BorderSide(color: isKoyuStandart ? const Color(0xFF334155) : Colors.white24)
                          : BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtrelenmis.length} Fiş Listeleniyor',
                      style: TextStyle(
                        color: altYaziRengi,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Toplam: ₺${toplamTutar.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: vurguRengi,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fiş Listesi
          Expanded(
            child: filtrelenmis.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.sadeceHaftalik
                                ? Icons.calendar_today_rounded
                                : Icons.receipt_long_rounded,
                            size: 64,
                            color: kolayMod ? Colors.white38 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.sadeceHaftalik
                                ? 'Bu hafta henüz fiş kaydı yok.'
                                : 'Henüz kayıtlı fişiniz bulunmuyor.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kolayMod ? Colors.white70 : Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alışverişinizi tamamladığınızda fişleriniz burada listelenir.',
                            style: TextStyle(
                              fontSize: 13,
                              color: kolayMod ? Colors.white38 : Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(Olculer.boslukBuyuk),
                    itemCount: filtrelenmis.length,
                    itemBuilder: (context, index) {
                      final fis = filtrelenmis[index];

                      if (kolayMod) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: Olculer.boslukOrta),
                          padding: const EdgeInsets.all(Olculer.boslukOrta),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (widget.onFisSecildi != null) {
                                widget.onFisSecildi!(fis);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FisDetayEkrani(fis: fis),
                                  ),
                                );
                              }
                            },
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
                                  child: const Icon(
                                    Icons.receipt_rounded,
                                    color: UygulamaRenkleri.kolayModSari,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: Olculer.boslukOrta),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fis.aciklama,
                                        style: MetinStilleri.kolayModGovde(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year} • ₺${fis.toplamTutar.toStringAsFixed(2)}',
                                        style: MetinStilleri.govde(renk: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: UygulamaRenkleri.kolayModSari,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return FisKarti(
                        fis: fis,
                        vurguRengi: isRenkKoru ? palet.primary : null,
                        onDokunuldu: () {
                          if (widget.onFisSecildi != null) {
                            widget.onFisSecildi!(fis);
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FisDetayEkrani(fis: fis),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
