import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../yoneticiler/sepet_yoneticisi.dart';
import '../fis_detay/fis_detay_ekrani.dart';
import '../kamera/kamera_tarayici_ekrani.dart';
import '../sesli_asistan/sesli_asistan_diyalog_ekrani.dart';

/// Görme Engelli / Sesli Sepetim Ekranı
/// (Stitch: sesli_sepetim birebir)
class GormeEngelliSepetView extends StatefulWidget {
  const GormeEngelliSepetView({super.key});

  @override
  State<GormeEngelliSepetView> createState() => _GormeEngelliSepetViewState();
}

class _GormeEngelliSepetViewState extends State<GormeEngelliSepetView> {
  void _seslendir(String metin) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFFD600),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                metin,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sepetiBastanSonaOku(SepetYoneticisi sepet) {
    if (sepet.urunler.isEmpty) {
      _seslendir('Sepetiniz şu an boş. Alışverişe başlamak için radar kamerasını açın.');
      return;
    }
    final urunOzetleri = sepet.urunler.take(3).map((u) => '${u.ad} ${u.fiyat.toStringAsFixed(2)} TL').join(', ');
    _seslendir(
      'Sepetinizde ${sepet.urunler.length} ürün var. Tutar ${sepet.toplamTutar.toStringAsFixed(2)} TL. Bazı ürünler: $urunOzetleri.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final sepet = context.watch<SepetYoneticisi>();
    final hedefButce = 240.0;
    final mevcutTutar = sepet.toplamTutar > 0 ? sepet.toplamTutar : 287.40;
    final butceAsimi = (mevcutTutar - hedefButce).clamp(0.0, 9999.0);

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
            Text(
              'Sesli Sepetim (${sepet.urunler.length} Ürün)',
              style: const TextStyle(
                color: Color(0xFFE4E1E6),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Color(0xFFFFD600), size: 30),
            onPressed: () => _sepetiBastanSonaOku(sepet),
            tooltip: 'Sepeti Sesli Tekrar Oku',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFFFF5DC),
              child: Icon(Icons.person, color: Color(0xFF3A3000), size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Devasa "Sepeti Baştan Sona Oku" Butonu (Min 72px)
            Semantics(
              label: 'Sepeti baştan sona sesli dinle',
              button: true,
              child: ElevatedButton.icon(
                onPressed: () => _sepetiBastanSonaOku(sepet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(76),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.volume_up, size: 36, color: Colors.black),
                label: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEPETİ BAŞTAN SONA OKU',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Tüm ürünleri ve genel toplamı sesli dinleyin',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Bütçe Uyarısı Kartı
            if (butceAsimi > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2C62D),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2C62D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.warning, color: Colors.black, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BÜTÇE LİMİTİ: ${butceAsimi.toStringAsFixed(2)} ₺ AŞILDI',
                                style: const TextStyle(
                                  color: Color(0xFFE2C62D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hedef: ${hedefButce.toStringAsFixed(2)} ₺ • Mevcut: ${mevcutTutar.toStringAsFixed(2)} ₺',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _seslendir('Dikkat: Belirlediğiniz 240 liralık bütçe limitini 47 lira 40 kuruş aştınız. Sepetiniz 287 lira 40 kuruş.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF353438),
                        foregroundColor: const Color(0xFFFFD600),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up, size: 24),
                      label: const Text(
                        'Bütçe Durumunu Seslendir',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 3. Sepet Ürün Akışı (Sesli Ürün Kartları)
            if (sepet.urunler.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.shopping_basket_outlined, color: Colors.white38, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Sepetinizde Ürün Bulunmuyor',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Radar kamerasını açarak etiketleri taramaya başlayabilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              ...sepet.urunler.asMap().entries.map((entry) {
                final sira = entry.key + 1;
                final urun = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F22),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$sira. ${urun.ad}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${urun.fiyat.toStringAsFixed(2)} ₺',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD600),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Birim Fiyat: ${urun.fiyat.toStringAsFixed(2)} ₺ • 1 Adet',
                                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFFD600), size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _seslendir('${urun.ad}, ${urun.fiyat.toStringAsFixed(2)} Türk Lirası');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A2A2D),
                                foregroundColor: const Color(0xFFFFD600),
                                minimumSize: const Size.fromHeight(64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.volume_up, size: 28),
                              label: const Text('Dinle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                sepet.urunSil(urun.id);
                                _seslendir('${urun.ad} sepetten silindi.');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A2A2D),
                                foregroundColor: const Color(0xFFFFB4AB),
                                minimumSize: const Size.fromHeight(64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.delete, size: 28),
                              label: const Text('Sil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 12),

            // 4. Sepet Toplamı ve Alışverişi Bitir Bloğu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F22),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0E11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SEPET TOPLAMI (KDV DAHİL)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${sepet.toplamTutar.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            color: Color(0xFFFFD600),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '✓ ${sepet.urunler.length} Farklı Ürün • Toplam ${sepet.urunler.length} Kalem',
                          style: const TextStyle(
                            color: Color(0xFF60F587),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Alışverişi Bitir & Fişi Dinle Butonu (Min 80px)
                  ElevatedButton(
                    onPressed: () {
                      _seslendir('Alışveriş tamamlandı. Dijital fiş ekranına geçiliyor.');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FisDetayEkrani(),
                        ),
                      );
                    },
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart_checkout, size: 36, color: Colors.black),
                            SizedBox(width: 12),
                            Text(
                              'ALIŞVERİŞİ BİTİR & FİŞİ DİNLE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward, size: 32, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tüm Sepeti Boşalt Butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1F1F22),
                          title: const Text('Sepeti Boşalt?', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Tüm ürünler sepetten çıkarılacak. Emin misiniz?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('İptal', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                sepet.sepetiTemizle();
                                Navigator.pop(ctx);
                                _seslendir('Sepet tamamen boşaltıldı.');
                              },
                              child: const Text('Evet, Boşalt'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2D),
                      foregroundColor: const Color(0xFFFFB4AB),
                      minimumSize: const Size.fromHeight(64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 28),
                    label: const Text(
                      'Tüm Sepeti Boşalt',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
            // Sepet (Aktif)
            Expanded(
              child: Container(
                color: const Color(0xFF2A2A2D),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket, color: Color(0xFFFFD600), size: 32),
                    SizedBox(height: 4),
                    Text(
                      'Sepet',
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
            // Asistan
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SesliAsistanDiyalogEkrani(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Colors.white70, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Asistan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
}
