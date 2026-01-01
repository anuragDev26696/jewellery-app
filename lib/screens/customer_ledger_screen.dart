import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/utils/constant.dart';
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
        padding: const EdgeInsets.all(12),
        child: entries.isEmpty
            ? const Center(child: Text('No customers/bills yet'))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final e = entries[i];
                  return Card(
                    child: ListTile(
                      title: Text(e.customerName.isNotEmpty ? e.customerName : (e.customerPhone.isNotEmpty ? e.customerPhone : 'Customer')),
                      subtitle: Text('${e.billCount} bill(s) • Total: ${CommonUtils.formatCurrency(e.totalAmount)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          // show list of bills for this customer
                          showModalBottomSheet(context: context, builder: (ctx) => SizedBox(
                            height: 480,
                            child: Column(
                              children: [
                                ListTile(title: Text('Bills for ${e.customerName.isNotEmpty ? e.customerName : e.customerPhone}')),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: e.bills.length,
                                    itemBuilder: (c, idx) {
                                      final b = e.bills[idx];
                                      return ListTile(
                                        title: Text('${DateFormat.yMMMd().format(b.createdAt!)} • ${CommonUtils.formatCurrency(b.grandTotal)}'),
                                        subtitle: Text('Items: ${b.items.length}'),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
