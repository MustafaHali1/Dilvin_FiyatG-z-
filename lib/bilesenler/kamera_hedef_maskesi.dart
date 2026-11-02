import 'package:flutter/material.dart';

/// Kamera ekranında sadece hedeflenen etiket alanını aydınlık bırakıp
/// dışarıdaki tüm alanı (Google sekmeleri, diğer etiketler vb.) karartan maske bileşeni
class KameraHedefMaskesi extends StatelessWidget {
  final double genislik;
  final double yukseklik;
  final Color cerceveRengi;
  final String ipucuMetni;

  const KameraHedefMaskesi({
    super.key,
    this.genislik = 300,
    this.yukseklik = 180,
    required this.cerceveRengi,
    this.ipucuMetni = 'Fiyat etiketini ortala',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dışarıyı karartan delikli maske (Cutout overlay)
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.65),
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: genislik,
                  height: yukseklik,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ortadaki renkli hedef çerçevesi ve yönlendirici yazı
        Center(
          child: Container(
            width: genislik,
            height: yukseklik,
            decoration: BoxDecoration(
              border: Border.all(color: cerceveRengi, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ipucuMetni,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
