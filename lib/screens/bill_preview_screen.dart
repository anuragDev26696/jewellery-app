import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/payment.dart';
import 'package:swarn_abhushan/providers/payment_provider.dart';
import 'package:swarn_abhushan/services/billling_service.dart';
import 'package:swarn_abhushan/services/payment_service.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import 'package:swarn_abhushan/utils/toastr.dart';
import '../models/bill.dart';
import '../models/item.dart';
import '../providers/billing_provider.dart';
class BillPreviewScreen extends ConsumerStatefulWidget {
  final Bill bill;
  final bool autoExportPdf;

  const BillPreviewScreen({
    super.key,
    required this.bill,
    this.autoExportPdf = false,
  });

  @override
  ConsumerState<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends ConsumerState<BillPreviewScreen> {
  // bool _showPayments = false;
  final _newPaymentCtrl = TextEditingController();
  String _selectedPaymentMode = 'Cash';
  final List<String> _paymentModes = ['Cash', 'Card', 'UPI', 'Net Banking'];
  late PaymentService _paymentService;
  late BillingService _billingService;

  bool get paymentProcess => ref.read(paymentNotifierProvider).isAdding;
  late Bill _bill;

  // Future<void> _exportAndShare(BuildContext context) async {
  //   try {
  //     Uint8List bytes;
  //     if (_bill != null) {
  //       bytes = await PdfGenerator.generateInvoicePdf(_bill!);
  //     } else {
  //       bytes = await PdfGenerator.generateFromTemporary(
  //         customerName: widget.temporaryCustomerName ?? '',
  //         customerPhone: widget.temporaryCustomerPhone ?? '',
  //         items: widget.temporaryItems ?? [],
  //         discount: widget.temporaryDiscount ?? 0,
  //         notes: widget.temporaryNotes ?? '',
  //         tax: widget.temporaryTax ?? 0,
  //         userId: '#123',
  //       );
  //     }
  //     await Printing.sharePdf(
  //       bytes: bytes,
  //       filename: 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
  //     );
  //   } catch (e) {
  //     if(mounted) Toastr.show('Export failed: $e', success: false);
  //   }
  // }

  Future<void> _download() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final pdfBytes = await _billingService.downloadInvoicePdf(_bill.uuid!);
      if (!mounted) return; 
      Navigator.pop(context);
      sharePdf(pdfBytes, "invoice-${_bill.uuid!}.pdf");
    } catch (e) {
      if(!mounted) return;
      Navigator.pop(context);
      Toastr.show("Failed to load PDF: $e", success: false);
    }
  }

  Future<void> _fetchBillPayments() async {
    if(_bill.uuid == null || _bill.uuid!.trim().isEmpty) return;
    await _paymentService.getPaymentsForBill(_bill.uuid!, 1);
  }

  @override
  void initState() {
    super.initState();
    setState(() => _bill = widget.bill);
    if (widget.autoExportPdf) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _download();
      });
    }
    _newPaymentCtrl.addListener(  () {
      setState(() {});
    });
    Future.microtask(() async {
      _paymentService = ref.read(paymentServiceProvider);
      _billingService = ref.read(billingServiceProvider);
      await _fetchBillPayments();
    });
  }

  @override
  void dispose() {
    _newPaymentCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final items = _bill.items;
    final customerName = _bill.customerName;
    final phone = _bill.customerPhone;
    final discount = _bill.discount;
    final taxPercent = _bill.tax;
    final date = _bill.createdAt;
    final allCalc = CalculateTax(items, discount, taxPercent);

    // Fetch payments for this bill (if any)
    final allPayments = ref.watch(paymentNotifierProvider).items;

    final totalPaid = allPayments.fold<double>(0, (p, e) => p + e.amount);
    final balance = allCalc.grandTotal - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export & Share PDF',
            onPressed: () => _download(),
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete_forever),
          //   tooltip: 'Delete Bill',
          //   onPressed: () async {
          //     final confirmed = await showDialog<bool>(
          //       context: context,
          //       builder: (c) => AlertDialog(
          //         title: const Text('Delete bill?'),
          //         actions: [
          //           TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          //           TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
          //         ],
          //       ),
          //     );
          //     if (confirmed == true) {
          //       await _billingService.deleteBill(_bill.uuid!);
          //       if(!mounted || !context.mounted) return;
          //       if (Navigator.canPop(context)) Navigator.pop(context);
          //     }
          //   },
          // ),
        ],
      ),
      bottomNavigationBar: (_bill.dueAmount != null && _bill.dueAmount! > 0) ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () => _showAddPaymentSheet(balance),
          icon: const Icon(Icons.add),
          label: const Text('Add Payment'),
        ),
      ) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  _buildCustomerInfo(customerName!, phone!, date!),
                  if(_bill.dueAmount != null && _bill.dueAmount! <= 0)
                    ...[
                      SizedBox(height: 10, width: 10,),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700, 
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.5), 
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(Icons.check, size: 50, color: Colors.white,),
                      ),
                      SizedBox(height: 5, width: 10,),
                      Text(
                        'Payment Completed',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  const SizedBox(height: 12.0),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) => _buildInvoiceItemRow(items[i]),
                  ),
                  const SizedBox(height: 12.0),
                  ExpansionTile(
                    title: Text('Payments History'),
                    initiallyExpanded: false,
                    children: [
                      _buildPaymentHistory(allPayments),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12.0),
                  _buildPriceRow('Subtotal', allCalc.subtotal),
                  _buildPriceRow('Discount', allCalc.discount, isNegative: true),
                  _buildPriceRow('Tax (${taxPercent.toStringAsFixed(2)}%)', allCalc.taxAmount),
                  const Divider(),
                  _buildPriceRow('Grand Total', allCalc.grandTotal, isTotal: true),
                  const SizedBox(height: 5.0),
                  _buildPriceRow('Total Paid', totalPaid),
                  if (_bill.dueAmount != null && _bill.dueAmount! > 0)
                    ...[
                      _buildPriceRow('Due Amount', _bill.dueAmount!, isTotal: true),
                      const SizedBox(height: 12.0),
                    ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(String customerName, String phone, DateTime date) {
    final gold = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              spacing: 10.0,
              children: [
                Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat.yMMMd().format(date), style: TextStyle(color: gold),),
              ],
            ),
            Text('Phone: $phone', style: TextStyle(fontSize: 12.0, color: Colors.white54),),
            Text('Invoice: #${_bill.billNumber}', style: TextStyle(fontSize: 12.0, overflow: TextOverflow.ellipsis, color: Colors.white54),),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItemRow(Item item) {
    final gold = Theme.of(context).colorScheme.primary;
    return ListTile(
      title: Text(item.name.isNotEmpty ? item.name : item.type),
      subtitle: Text('Wt: ${item.weight}g • ₹${item.pricePerGram.toStringAsFixed(2)} • Making: ${item.makingCharge.toStringAsFixed(2)}%', style: TextStyle(fontSize: 12.0, color: Colors.grey, fontWeight: FontWeight.normal),),
      trailing: Text('₹ ${item.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
    );
  }

  Widget _buildPaymentHistory(List<Payment> payments) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) {
        final p = payments[i];
        return ListTile(
          title: p.createdAt != null ? Text(DateFormat.yMMMd().format(p.createdAt!),) : null,
          subtitle: Text(p.paymentMode, style: TextStyle(fontSize: 12.0)),
          trailing: Text('₹${p.amount.toStringAsFixed(2)}', style: TextStyle(color: Color(0xFFFFC857)),),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isNegative = false}) {
    final gold = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? TextStyle(fontWeight: FontWeight.bold, color: gold) : null),
          Text('${isNegative ? '-' : ''} ₹ ${amount.toStringAsFixed(2)}', style: isTotal ? TextStyle(fontWeight: FontWeight.bold, color: gold) : null),
        ],
      ),
    );
  }

  void _showAddPaymentSheet(double balance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom; // For keyboard

        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomInset + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12.0,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('₹${balance.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: _newPaymentCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                  autofocus: true,
                  onChanged: (_) => setModalState(() {}),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMode,
                  items: _paymentModes.map((mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => _selectedPaymentMode = val);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _newPaymentCtrl.text.isEmpty  || paymentProcess ? null : () => _makePayment(context),
                    child: paymentProcess ? const CircularProgressIndicator(strokeWidth: 1.2) : const Text('Add Payment'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).whenComplete(() {
      _newPaymentCtrl.clear();
      _selectedPaymentMode = 'Cash';
    });
  }

  Future<void> _makePayment(BuildContext context) async {
    final amt = double.tryParse(_newPaymentCtrl.text);
    if (amt == null || amt <= 0) {
      Toastr.show('Enter a valid amount', success: false);
      return;
    }
    final req = Payment(billId: _bill.uuid!, amount: amt, paymentMode: _selectedPaymentMode);
    final res = await _paymentService.addPayment(req);
    _newPaymentCtrl.clear();
    if (!context.mounted) return; 
    Navigator.pop(context);
    setState(() => _bill = Bill.fromMap(res['updatedBill']));
    ref.read(billingNotifierProvider.notifier).updateBill(_bill);
  }
}
