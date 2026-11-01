import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../sabitler/uygulama_renkleri.dart';
import '../sabitler/metin_stilleri.dart';

/// Türk Lirası fiyatını şık bir şekilde gösteren atomik class
class FiyatEtiketi extends StatelessWidget {
  final double tutar;
  final double? eskiTutar;
  final double boyut;
  final Color? renk;
  final bool kolayMod;

  const FiyatEtiketi({
    super.key,
    required this.tutar,
    this.eskiTutar,
    this.boyut = 20,
    this.renk,
    this.kolayMod = false,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final formatliTutar = format.format(tutar);

    if (kolayMod) {
      return Text(
        formatliTutar,
        style: MetinStilleri.kolayModDev(
          renk: renk ?? UygulamaRenkleri.kolayModSari,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (eskiTutar != null && eskiTutar! > tutar) ...[
          Text(
            format.format(eskiTutar),
            style: TextStyle(
              fontSize: boyut * 0.7,
              color: UygulamaRenkleri.griYazi,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          formatliTutar,
          style: MetinStilleri.fiyat(
            boyut: boyut,
            renk: renk ?? UygulamaRenkleri.koyuYazi,
          ),
        ),
      ],
    );
  }
}
