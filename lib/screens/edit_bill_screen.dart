import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/utils/bill_item_header.dart';
import '../models/bill.dart';
import '../models/item.dart';
import '../utils/item_form_dialog.dart';
import '../utils/constant.dart';
import '../providers/billing_provider.dart';

class EditBillScreen extends ConsumerStatefulWidget {
  final Bill bill;

  const EditBillScreen({super.key, required this.bill});

  @override
  ConsumerState<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends ConsumerState<EditBillScreen> {
  final List<Item> _items = [];
  final _discountCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  late VoidCallback _onUserFieldChanged;

  @override
  void initState() {
    super.initState();
    _items.addAll(widget.bill.items);
    _discountCtrl.text = widget.bill.discount.toString();
    _taxCtrl.text = widget.bill.tax.toString();
    _onUserFieldChanged = () => setState(() {});
    for (final ctrl in [_discountCtrl, _taxCtrl]) {
      ctrl.addListener(_onUserFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final ctrl in [_discountCtrl, _taxCtrl]) {
      ctrl.removeListener(_onUserFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  void _addItemDialog({Item? prefill}) {
    showDialog<Item>(
      context: context,
      builder: (_) => ItemFormDialog(
        prefill: prefill,
        confirmText: prefill == null ? "Add" : "Save",
        title: prefill == null ? "Add Item" : "Edit Item",
        keepPrefillId: true,
        onSubmit: (result) {
          setState(() {
            if (prefill != null) {
              final index =
                  _items.indexWhere((it) => it.uuid == prefill.uuid);
              if (index != -1) {
                _items[index] = result;
              }
            } else {
              _items.add(result);
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveEditedBill() async {
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0.0;

    final updatedBill = widget.bill.copyWith(
      items: _items,
      discount: discount,
      tax: tax,
    );

    await ref.read(billingNotifierProvider.notifier).updateBill(widget.bill.uuid!, updatedBill);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0.0;
    final calc = CalculateTax(_items, discount, tax);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Bill"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 12,
          children: [
            TextField(
              controller: TextEditingController(text: widget.bill.customerName),
              readOnly: true,
              decoration: InputDecoration(labelText: "Customer Name"),
            ),
            BillItemHeader(itemCount: _items.length, onAddItem: _addItemDialog, onQuickAddFromTemplate: (t) {_addItemDialog(prefill: t);},),

            _items.isEmpty
                ? const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No items found"),
                ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final it = _items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(it.name.isNotEmpty ? it.name : it.type),
                          subtitle: Text(
                            "Wt: ${it.weight}g • Rate: ₹${it.pricePerGram} • Making: ${it.makingCharge}% • Total: ₹${it.total.toStringAsFixed(2)}"
                          ),
                          subtitleTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == "edit") _addItemDialog(prefill: it);
                              if (v == "remove") {
                                setState(() => _items.removeAt(i));
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(value: "remove", child: Text("Remove")),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // DISCOUNT
            TextField(
              controller: _discountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [TwoDecimalNumberFormatter(maxValue: calc.subtotal)],
              decoration: const InputDecoration(
                labelText: "Discount (₹)",
                border: OutlineInputBorder(),
              ),
            ),

            // TAX
            TextField(
              controller: _taxCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [TwoDecimalNumberFormatter(maxValue: 100)],
              decoration: const InputDecoration(labelText: "Tax (%)"),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // SUMMARY (Same as payment screen)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(1),
              },
              children: [
                _row("Total", calc.subtotal),
                _row("Making", calc.totalMaking),
                _row("Discount", discount),
                _row("Tax (${_taxCtrl.text}%)", calc.taxAmount),
                TableRow(children: [
                  const Divider(),
                  const Divider(),
                ]),
                _row("Grand Total", calc.grandTotal, bold: true),
              ],
            ),

            const SizedBox(height: 80)
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _items.isEmpty ? null : _saveEditedBill,
              icon: const Icon(Icons.save),
              label: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _row(String title, double value, {bool bold = false}) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ]);
  }
}
