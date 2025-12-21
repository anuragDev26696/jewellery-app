import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/payment.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import '../models/bill.dart';
import '../models/item.dart';
import '../providers/billing_provider.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> billDraft;

  const PaymentScreen({super.key, required this.billDraft});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _discountCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '0');
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _mode = 'Cash';
  late VoidCallback _onUserFieldChanged;

  @override
  void initState() {
    super.initState();
    _onUserFieldChanged = () => setState(() {});
    for (final ctrl in [_discountCtrl, _taxCtrl, _amountCtrl, _notesCtrl]) {
      ctrl.addListener(_onUserFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final ctrl in [_discountCtrl, _taxCtrl, _amountCtrl, _notesCtrl]) {
      ctrl.removeListener(_onUserFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _saveBill() async {
    final customerId = (widget.billDraft['customerId'] ?? '') as String;
    final billNumber = "BILL-${DateTime.now().millisecondsSinceEpoch}";
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0.0;
    final paymentAmount = double.tryParse(_amountCtrl.text) ?? 0.0;

    final bill = Bill(
      billNumber: billNumber,
      items: List.from(widget.billDraft['items'] as List<Item>),
      discount: discount,
      tax: tax,
      notes: (_notesCtrl.text.trim()),
      customerId: customerId,
    );
    Bill newBill;

    // Save Bill
    try {
      newBill = await ref.read(billingNotifierProvider.notifier).addBill(bill);
    } catch (e) {
      debugPrint('Error saving bill: $e');
      return;
    }

    // Save single Payment entry (if entered)
    if (paymentAmount > 0) {
      final req = Payment(amount: paymentAmount, paymentMode: _mode, billId: newBill.uuid!);
      await ref.read(paymentNotifierProvider.notifier).addPayment(req).catchError((_) {});
    }

    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  bool get isvalidForm {
    return _discountCtrl.text.isNotEmpty &&
        _taxCtrl.text.isNotEmpty &&
        _amountCtrl.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.billDraft['items'] as List<Item>;
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0.0;
    final calc = CalculateTax(items, discount, tax);

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 12.0,
          children: [
            TextField(
              controller: _discountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [TwoDecimalNumberFormatter(maxValue: calc.subtotal)],
              decoration: const InputDecoration(labelText: 'Discount (₹)'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _taxCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [TwoDecimalNumberFormatter(maxValue: 100)],
              decoration: const InputDecoration(labelText: 'Tax (%)'),
              onChanged: (_) => setState(() {}),
            ),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              onChanged: (v) => setState(() => _mode = v!),
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              ],
            ),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [TwoDecimalNumberFormatter(maxValue: calc.grandTotal)],
              decoration: const InputDecoration(labelText: 'Payment Amount (₹)'),
            ),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            
            const SizedBox(height: 12),
            const Divider(),

            // Summary table (no borders)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildRow("Total", "₹${calc.subtotal.toStringAsFixed(2)}"),
                _buildRow("Making", "₹${calc.totalMaking.toStringAsFixed(2)}"),
                _buildRow("Discount", "₹${discount.toStringAsFixed(2)}"),
                _buildRow("Tax (${_taxCtrl.text}%)", "₹${calc.taxAmount.toStringAsFixed(2)}"),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(),
                    ),
                  ],
                ),
                _buildRow(
                  "Grand Total",
                  "₹${calc.grandTotal.toStringAsFixed(2)}",
                  isBold: true,
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Consumer(builder: (context, ref, _) {
              final isPaymentAdding = ref.watch(paymentNotifierProvider).isAdding;
              final isBillAdding = ref.watch(billingNotifierProvider).isAdding;
              final isDisabled = isPaymentAdding || isBillAdding;
              return ElevatedButton.icon(
                onPressed: isDisabled ? null : _saveBill,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save & Generate Bill",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              );
              },
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String value, {bool isBold = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
