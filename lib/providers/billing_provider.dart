import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/services/billling_service.dart';
import '../models/bill.dart';

final billingNotifierProvider = StateNotifierProvider<BillingNotifier, BillState>((ref) {
  return BillingNotifier();
});

class BillingNotifier extends StateNotifier<BillState> {

  BillingNotifier() : super(const BillState());

  Future<void> loadBills({
    required List<Bill> bills,
    required int total,
    required int page,
    required int limit,
    required bool isLastPage,
    required bool isPreviousPage,
    bool append = false,
  }) async {
    final newBills = append ? [...state.bills, ...bills] : bills;
    state = state.copyWith(
      bills: newBills,
      total: total,
      page: page,
      limit: limit,
      isLastPage: isLastPage,
      isPreviousPage: isPreviousPage
    );
  }

  void addBill(Bill bill) {
    state = state.copyWith(bills: [bill, ...state.bills]);
  }

  void updateBill(Bill updatedBill) {
    final updatedList = state.bills.map((t) => t.uuid == updatedBill.uuid ? updatedBill : t).toList();
    state = state.copyWith(bills: updatedList);
  }

  void deleteBill(String id) {
    final updatedList = state.bills.where((u) => u.uuid != id).toList();
    state = state.copyWith(bills: updatedList);
  }

  void clearAll() {
    state = state.copyWith(bills: [], total: 0, isLastPage: true, isPreviousPage: false);
  }

  /// Search bills by customer name, phone, or item name (case-insensitive)
  List<Bill> searchBills(String query) {
    if (query.trim().isEmpty) return state.bills;
    final q = query.toLowerCase();
    return state.bills.where((b) {
      final byName = b.customerName?.toLowerCase().contains(q);
      final byPhone = b.customerPhone?.toLowerCase().contains(q);
      final byItem = b.items.any((it) =>
          it.name.toLowerCase().contains(q) ||
          it.type.toLowerCase().contains(q));
      return byName! || byPhone! || byItem;
    }).toList();
  }

  /// Customer ledger: map customer phone -> summary {name, phone, totalAmount, billCount}
  List<CustomerLedgerEntry> buildCustomerLedger() {
    final Map<String, CustomerLedgerEntry> map = {};
    for (final b in state.bills) {
      final key = b.customerPhone!.isNotEmpty ? b.customerPhone : b.customerName;
      final entry = map[key];
      final amount = b.grandTotal;
      if (entry == null && key != null) {
        map[key] = CustomerLedgerEntry(
          customerName: b.customerName!,
          customerPhone: b.customerPhone!,
          totalAmount: amount,
          billCount: 1,
          bills: [b],
        );
      } else {
        entry!.totalAmount += amount;
        entry.billCount += 1;
        entry.bills.add(b);
      }
    }
    // Return sorted by totalAmount desc
    final list = map.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }
}

class CustomerLedgerEntry {
  String customerName;
  String customerPhone;
  double totalAmount;
  int billCount;
  List<Bill> bills;

  CustomerLedgerEntry({
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.billCount,
    required this.bills,
  });
}

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref);
});