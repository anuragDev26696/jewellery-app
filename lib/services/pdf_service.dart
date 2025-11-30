import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/utils/pdf_generator.dart';

class PdfService {
  static Future<File> savePdf(Bill bill) async {
    final pdfBytes = await PdfGenerator.generateInvoicePdf(bill);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${bill.billNumber}.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  static Future<void> sharePdf(Bill bill) async {
    // final file = await savePdf(bill);
    // await Share.shareXFiles([XFile(file.path)], text: 'Invoice #${bill.billNumber}');
  }
}
