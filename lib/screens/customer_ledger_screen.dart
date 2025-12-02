import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/bill.dart';
import '../providers/billing_provider.dart';
import 'bill_preview_screen.dart';
import 'package:intl/intl.dart';

class CustomerLedgerScreen extends ConsumerWidget {
  const CustomerLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.read(billingNotifierProvider.notifier).buildCustomerLedger();

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Ledger')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: entries.isEmpty
            ? const Center(child: Text('No customers/bills yet'))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final e = entries[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white10, width: 1)),
                    child: ListTile(
                      title: Text(e.customerName.isNotEmpty ? e.customerName : (e.customerPhone.isNotEmpty ? e.customerPhone : 'Customer')),
                      subtitle: Text('${e.billCount} bill(s) • Total: ₹ ${e.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          color: Colors.black26,
                          child: Text(
                            e.customerName?.trim()[0] ?? 'U',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(context: context, builder: (ctx) => SizedBox(
                          height: 480,
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.all(12), child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )),
                              ListTile(title: Text('Bills for ${e.customerName.isNotEmpty ? e.customerName : e.customerPhone}')),
                              Divider(),
                              Expanded(
                                child: ListView.separated(
                                  separatorBuilder: (c, i) => const Divider(height: 1,),
                                  scrollDirection: Axis.vertical,
                                  addSemanticIndexes: true,
                                  shrinkWrap: true,
                                  itemCount: e.bills.length,
                                  itemBuilder: (c, idx) {
                                    final b = e.bills[idx];
                                    return ListTile(
                                      title: Text('${DateFormat.yMMMd().format(b.createdAt!)} • ₹ ${b.grandTotal.toStringAsFixed(2)}'),
                                      subtitle: Row(spacing: 5.0, children:[Text('Items: ${b.items.length}'), SizedBox(width: 10,), _statusChip(b.paymentStatus)]),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => BillPreviewScreen(bill: b)));
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ));
                      },
                    ),
                  );
                },
              ),
      ),
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
}
