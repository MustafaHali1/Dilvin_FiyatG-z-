import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../modeller/fis_modeli.dart';

/// Alışveriş fişlerini PDF olarak oluşturan ve WhatsApp/E-posta ile paylaşan servis
class FisPdfServisi {
  /// Verilen fiş modelinden PDF dosyası üretir ve paylaşım penceresini açar
  static Future<bool> fisiPdfOlarakPaylas(FisModeli fis) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Başlık Alanı
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'FiyatGöz',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal800,
                            ),
                          ),
                          pw.Text(
                            'Erişilebilir Akıllı Alışveriş Asistanı',
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'FİŞ NO: ${fis.id}',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            '${fis.tarih.day}.${fis.tarih.month}.${fis.tarih.year} ${fis.tarih.hour.toString().padLeft(2, '0')}:${fis.tarih.minute.toString().padLeft(2, '0')}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(thickness: 1.5, color: PdfColors.teal700),
                  pw.SizedBox(height: 8),

                  // Market Bilgisi
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Market: ${fis.marketAdi}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          fis.aciklama,
                          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Ürünler Tablosu
                  pw.Text(
                    'ALINAN ÜRÜNLER',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                  ),
                  pw.SizedBox(height: 8),

                  pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    headers: ['#', 'Ürün Adı', 'Birim Fiyat', 'Adet', 'Tutar'],
                    data: List.generate(fis.urunler.length, (index) {
                      final u = fis.urunler[index];
                      return [
                        '${index + 1}',
                        u.ad,
                        '${u.birimFiyat.toStringAsFixed(2)} TL',
                        '${u.adet}',
                        '${u.toplamTutar.toStringAsFixed(2)} TL',
                      ];
                    }),
                  ),

                  pw.SizedBox(height: 20),

                  // Toplam ve Tasarruf Özeti
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Container(
                      width: 240,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.teal600, width: 1.5),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Toplam Ürün:'),
                              pw.Text('${fis.toplamUrunAdedi} adet', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          if (fis.toplamIndirim > 0) ...[
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Toplam Tasarruf:', style: const pw.TextStyle(color: PdfColors.green700)),
                                pw.Text(
                                  '${fis.toplamIndirim.toStringAsFixed(2)} TL',
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
                                ),
                              ],
                            ),
                          ],
                          pw.Divider(thickness: 1, color: PdfColors.grey300),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'GENEL TOPLAM:',
                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                '${fis.toplamTutar.toStringAsFixed(2)} TL',
                                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.Spacer(),

                  // Alt Bilgi (Footer)
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Bu fiş FiyatGöz yapay zekâ asistanı ile oluşturulmuştur.',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'www.fiyatgoz.app',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal700),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Geçici dizine kaydet
      final tempDir = Directory.systemTemp;
      final dosyaYolu = '${tempDir.path}/FiyatGoz_Fis_${fis.id}.pdf';
      final dosya = File(dosyaYolu);
      await dosya.writeAsBytes(await pdf.save());

      // Paylaşım penceresini tetikle
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(dosyaYolu)],
          text: '${fis.marketAdi} alışveriş fişim - Toplam: ${fis.toplamTutar.toStringAsFixed(2)} TL (FiyatGöz)',
          subject: 'FiyatGöz Alışveriş Fişi - ${fis.id}',
        ),
      );

      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('PDF üretme ve paylaşma hatası: $e');
      return false;
    }
  }
}
