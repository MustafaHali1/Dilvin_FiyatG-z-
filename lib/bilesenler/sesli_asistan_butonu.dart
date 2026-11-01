import 'package:flutter/material.dart';
import '../../sabitler/uygulama_renkleri.dart';
import '../../sabitler/olculer.dart';
import '../../sabitler/metin_stilleri.dart';

/// Her ekranda sağ altta süzülen sesli asistan butonu
class SesliAsistanButonu extends StatelessWidget {
  final VoidCallback onDokunuldu;

  const SesliAsistanButonu({super.key, required this.onDokunuldu});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'sesli_asistan_fab',
      onPressed: onDokunuldu,
      backgroundColor: UygulamaRenkleri.anaZumrut,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Olculer.yariCapTam),
      ),
      icon: const Icon(Icons.mic_rounded, size: 22),
      label: Text(
        'Sesli Asistan',
        style: MetinStilleri.govdeKalin(renk: Colors.white),
      ),
    );
  }
}
