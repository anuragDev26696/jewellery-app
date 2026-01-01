// import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/screens/bill_preview_screen.dart';
import 'package:swarn_abhushan/screens/edit_bill_screen.dart';
import 'package:swarn_abhushan/screens/pdf_view.dart';
import 'package:swarn_abhushan/services/billling_service.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class BillItem extends ConsumerStatefulWidget {
  final Bill bill;
  final PaymentStatus status;
  const BillItem({super.key, required this.bill, required this.status});

  @override
  ConsumerState<BillItem> createState() => _BillItem();
}

class _BillItem extends ConsumerState<BillItem> {
  late BillingService _service;
  
  @override
  void initState(){
    super.initState();
    Future.microtask((){
      _service = ref.read(billingServiceProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BillPreviewScreen(bill: widget.bill)));
      },
      dense: true,
      isThreeLine: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          color: Colors.black26,
          child: Text(
            widget.bill.customerName?.trim()[0] ?? 'U',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: Text(
        widget.bill.customerName != null ? widget.bill.customerName! : 'Customer',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10.0,
          children: [
            Text(
              DateFormat.yMMMd().format(widget.bill.createdAt!),
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            Text(
              ' • ${CommonUtils.formatCurrency(widget.bill.total!)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            _statusChip(widget.status),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          if(v == 'edit'){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditBillScreen(bill: widget.bill)),
            );
          } else if (v == 'delete') {
            await _deleteAction();
          } else if (v == 'export') {
            await downloadInvoicePdf();
            // Navigator.push(context, MaterialPageRoute(builder: (_) => BillPreviewScreen(bill: widget.bill, autoExportPdf: true)));
          }
        },
        itemBuilder: (ctx) => [
          if (widget.status.label != 'Paid') PopupMenuItem(value: 'edit', child: Text('Update Bill')),
          PopupMenuItem(value: 'export', child: Text('Share Bill PDF')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      hoverColor: gold.withValues(alpha: 0.05),
      splashColor: gold.withValues(alpha: 0.1),
    );
  }

  Widget _statusChip(PaymentStatus status) {
    final colors = status.colors;
    return Chip(
      label: Text(
        status.shortLabel,
        style: TextStyle(color: colors.text, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
      backgroundColor: colors.background,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      padding: EdgeInsets.zero,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.none,
    );
  }



  Future<void> downloadInvoicePdf() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfBytes = await _service.downloadInvoicePdf(widget.bill.uuid!);
      if(!mounted) return;
      Navigator.pop(context);

      if (kIsWeb) {
        // downloadPdfWeb(pdfBytes, "invoice-${widget.bill.uuid}.pdf");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            pdfBytes: pdfBytes,
            fileName: "invoice-${widget.bill.uuid}.pdf",
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      Toastr.show("Failed to load PDF: $e", success: false);
    }
  }
  // void downloadPdfWeb(Uint8List pdfBytes, String fileName) {
  //   final jsBytes = pdfBytes.toJS;
  //   final blobPart = <JSAny>[jsBytes].toJS;
  //   final blob = web.Blob(blobPart, web.BlobPropertyBag(type: "application/pdf"));
  //   final url = web.URL.createObjectURL(blob);
    
  //   final anchor = web.document.createElement('a') as web.HTMLAnchorElement
  //     ..href = url
  //     ..download = fileName;

  //   anchor.click();
  //   web.URL.revokeObjectURL(url);
  // }

  Future<void> _deleteAction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Are you sure you want to delete?', textAlign: TextAlign.center,),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowButtonSpacing: 12.0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_forever_rounded,
            size: 40,
            color: Colors.red,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty .resolveWith<Color?>((states) => Colors.red),
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if(widget.bill.uuid!.isEmpty && mounted) {
        Toastr.show('Invalid template id', success: false);
        return;
      }
      await ref.read(billingNotifierProvider.notifier).deleteBill(widget.bill.uuid!);
    }
  }
}