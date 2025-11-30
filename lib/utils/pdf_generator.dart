import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/models/item.dart';

class PdfGenerator {
  static Future<Uint8List> generateInvoicePdf(Bill bill) async {
    final pdf = pw.Document();

    final logo =
        (await rootBundle.load('assets/logos/logo_1.png')).buffer.asUint8List();

    final fontRegular = pw.Font.ttf(
      await rootBundle.load('fonts/Roboto-Regular.ttf'),
    );
    final fontBold = pw.Font.ttf(
      await rootBundle.load('fonts/Roboto-Bold.ttf'),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        ),
        build:
            (context) => [
              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SWARN ABHUSHAN',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 22,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Naigarhi, Mauganj, Madhya Pradesh - 486341'),
                      pw.Text(
                        'Phone: +91 94249 81420 | Email: contact@swarnjeweller.in',
                      ),
                      pw.Text('GSTIN: 09ABCDE1234F1Z6'),
                    ],
                  ),
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.Image(pw.MemoryImage(logo)),
                  ),
                ],
              ),
              pw.Divider(),

              // Invoice Header
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.amber, width: 1.2),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Invoice No: INV-${bill.uuid}',
                          style: pw.TextStyle(font: fontBold),
                        ),
                        pw.Text(
                          'Date: ${bill.createdAt!.toLocal().toString().split(' ')[0]}',
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Customer: ${bill.customerName}',
                          style: pw.TextStyle(font: fontBold),
                        ),
                        pw.Text('Phone: ${bill.customerPhone}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Payment Mode: Cash'),
                        pw.Text('Billed By: SWARN ABHUSHAN'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // Table Header
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.amber100),
                headerStyle: pw.TextStyle(
                  font: fontBold,
                  color: PdfColors.black,
                  fontSize: 11,
                ),
                cellStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
                cellAlignment: pw.Alignment.center,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                },
                headers: [
                  'Item',
                  'Weight (g)',
                  'Rate/g',
                  'Making',
                  // 'Tax',
                  'Total',
                ],
                data:
                    bill.items.map((item) {
                      return [
                        item.name,
                        item.weight.toStringAsFixed(2),
                        '₹${item.pricePerGram.toStringAsFixed(2)}',
                        '₹${item.makingCharge.toStringAsFixed(2)}',
                        // '₹${item.taxAmount.toStringAsFixed(2)}',
                        '₹${(item.basicAmount + item.makingCharge).toStringAsFixed(2)}',
                      ];
                    }).toList(),
              ),
              pw.SizedBox(height: 10),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 547,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildTotalRow('Subtotal', bill.subTotal, fontBold),
                        _buildTotalRow(
                          'Making Charges',
                          bill.totalMaking,
                          fontBold,
                        ),
                        _buildTotalRow('Tax', bill.taxamount, fontBold),
                        _buildTotalRow('Discount', -bill.discount, fontBold),
                        pw.Divider(),
                        _buildTotalRow(
                          'Grand Total',
                          bill.grandTotal,
                          fontBold,
                          color: PdfColors.green800,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Divider(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'This is a computer-generated invoice — no signature required.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'All jewellery sold is hallmarked as per BIS standards. Prices include GST.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Thank you for shopping with SWARN ABHUSHAN!',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 11,
                        color: PdfColors.brown800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount,
    pw.Font font, {
    bool isBold = false,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black),
        ),
        pw.SizedBox(width: 50),
        pw.Text(
          '₹${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: color,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ---------------- Item Table ----------------
  // static pw.Widget _buildItemTable(Bill bill, pw.Font regular, pw.Font bold) {
  //   final headers = ['Item', 'Weight(g)', 'Rate/g', 'Making', 'Total'];
  //   final data =
  //       bill.items.map((item) {
  //         return [
  //           item.name,
  //           item.weight.toStringAsFixed(2),
  //           item.pricePerGram.toStringAsFixed(2),
  //           item.makingCharge.toStringAsFixed(2),
  //           // item.taxAmount.toStringAsFixed(2),
  //           (item.basicAmount + item.makingCharge).toStringAsFixed(2),
  //         ];
  //       }).toList();

  //   return pw.Table.fromTextArray(
  //     headerDecoration: const pw.BoxDecoration(color: PdfColors.amber100),
  //     headerStyle: pw.TextStyle(
  //       font: bold,
  //       fontSize: 10,
  //       color: PdfColors.brown800,
  //     ),
  //     cellStyle: pw.TextStyle(font: regular, fontSize: 9),
  //     headers: headers,
  //     data: data,
  //     cellAlignment: pw.Alignment.centerRight,
  //     headerAlignment: pw.Alignment.center,
  //     border: pw.TableBorder.symmetric(outside: pw.BorderSide.none),
  //     columnWidths: {
  //       0: const pw.FlexColumnWidth(3),
  //       1: const pw.FlexColumnWidth(1),
  //       2: const pw.FlexColumnWidth(1),
  //       3: const pw.FlexColumnWidth(1),
  //       4: const pw.FlexColumnWidth(1),
  //       5: const pw.FlexColumnWidth(1.2),
  //     },
  //     rowDecoration: pw.BoxDecoration(
  //       border: pw.Border(
  //         bottom: pw.BorderSide(color: PdfColors.amber100, width: 0.4),
  //       ),
  //     ),
  //   );
  // }

  /// Generate a PDF for temporary inputs (when previewing before saving)
  static Future<Uint8List> generateFromTemporary({
    required String customerName,
    required String customerPhone,
    required List<Item> items,
    required double discount,
    required double tax,
    required String notes,
    required String userId,
  }) async {
    final now = DateTime.now();
    final billNum =
        'TEMP-${now.year}${now.month}${now.day}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final tempBill = Bill(
      uuid: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      billNumber: billNum,
      customerName: customerName,
      customerPhone: customerPhone,
      createdAt: DateTime.now(),
      items: items,
      discount: discount,
      notes: notes,
      tax: tax,
      customerId: userId,
    );
    return generateInvoicePdf(tempBill);
  }
}
