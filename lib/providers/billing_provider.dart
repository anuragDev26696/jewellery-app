import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/services/billling_service.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import '../models/bill.dart';

final billingNotifierProvider = StateNotifierProvider<BillingNotifier, BillState>((ref) {
  return BillingNotifier(ref);
});

class BillingNotifier extends StateNotifier<BillState> {
  final Ref _ref;
  late final BillingService _service;
  late final LoaderService _loader;

  BillingNotifier(this._ref) : super(const BillState()){
    _service = _ref.read(billingServiceProvider);
    _loader = _ref.read(loaderServiceProvider);
  }

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

  Future<Bill> addBill(Bill reqData) async {
    state = state.copyWith(isAdding: true);
    _loader.show();
    try {
      final bill = await _service.addBill(reqData);
      state = state.copyWith(bills: [bill, ...state.bills]);
      return bill;
    } finally {
      state = state.copyWith(isAdding: false);
      _loader.hide();
    }
  }

  Future<Bill> updateBill(String id, Bill bill, {bool byPayment = false}) async {
    if(byPayment) {
      state = state.copyWith(
        bills: state.bills.map((b) => b.uuid == id ? bill : b).toList(),
      );
      return bill;
    }
    state = state.copyWith(isUpdating: true);
    _loader.show();
    try {
      final updated = await _service.updateBill(id, bill);
      state = state.copyWith(
        bills: state.bills.map((b) => b.uuid == id ? updated : b).toList(),
      );
      return updated;
    } finally {
      state = state.copyWith(isUpdating: false);
      _loader.hide();
    }
  }

  Future<void> deleteBill(String id) async {
    _loader.show();
    try {
      await _service.deleteBill(id);
      state = state.copyWith(
        bills: state.bills.where((b) => b.uuid != id).toList(),
      );
    } finally {
      _loader.hide();
    }
  }

  void clearAll() {
    state = state.copyWith(bills: [], total: 0, isLastPage: true, isPreviousPage: false);
  }

  Future<void> fetchBills(String? keyword, int page, int limit, {String? status, String? customerId}) async {
    _loader.show();
    state = state.copyWith(isLoading: true);
    if(page == 1) {
      state = state.copyWith(bills: [], total: 0, isPreviousPage: false);
    }

    try {
      final response = await _service.fetchBills(keyword, page,limit, status: status, customerId: customerId);
      final List data = response["data"] ?? [];
      final bills = data.map((e) => Bill.fromMap(e)).toList();
      loadBills(
        bills: bills,
        total: response["total"] ?? bills.length,
        page: response["page"] ?? 1,
        limit: response["limit"] ?? limit,
        isLastPage: response["isLastPage"] ?? false,
        isPreviousPage: response["isPreviousPage"] ?? false,
        append: page > 1,
      );
    } finally {
      state = state.copyWith(isLoading: false);
      _loader.hide();
    }
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