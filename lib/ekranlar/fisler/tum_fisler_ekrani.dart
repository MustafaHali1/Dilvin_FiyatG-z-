import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../modeller/fis_modeli.dart';
import '../../yoneticiler/fis_yoneticisi.dart';
import '../ana_sayfa/bilesenler/fis_karti.dart';
import '../fis_detay/fis_detay_ekrani.dart';

/// Kullanıcının tüm kayıtlı fişlerini veya haftalık fişlerini detaylı arama ve filtreleme ile listeleyen modern ekran
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

    return Scaffold(
      backgroundColor: UygulamaRenkleri.arkaPlan,
      appBar: AppBar(
        title: Text(widget.baslik, style: MetinStilleri.baslik2()),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Arama ve İstatistik Özeti
          Container(
            color: Colors.white,
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
                  decoration: InputDecoration(
                    hintText: 'Fiş, market veya ürün ara...',
                    prefixIcon: const Icon(Icons.search_rounded, color: UygulamaRenkleri.griYazi),
                    filled: true,
                    fillColor: UygulamaRenkleri.arkaPlan,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Olculer.yariCapOrta),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: Olculer.boslukOrta),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtrelenmis.length} Fiş Listeleniyor',
                      style: MetinStilleri.aciklama(),
                    ),
                    Text(
                      'Toplam: ₺${toplamTutar.toStringAsFixed(2)}',
                      style: MetinStilleri.govdeKalin(renk: UygulamaRenkleri.anaZumrut),
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
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.sadeceHaftalik
                                ? 'Bu hafta henüz fiş kaydı yok.'
                                : 'Henüz kayıtlı fişiniz bulunmuyor.',
                            style: MetinStilleri.govdeKalin(renk: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alışverişinizi tamamladığınızda fişleriniz burada listelenir.',
                            style: MetinStilleri.aciklama(),
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
                      return FisKarti(
                        fis: fis,
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
