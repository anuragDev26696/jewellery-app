import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/models/payment.dart';
import 'package:swarn_abhushan/services/payment_service.dart';

final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<PaymentState> {

  PaymentNotifier() : super(const PaymentState());

  Future<void> load({
    required List<Payment> items,
    required int total,
    required int page,
    required int limit,
    required bool isLastPage,
    required bool isPreviousPage,
    bool append = false,
    isLoading = false
  }) async {
    final newPayment = append ? [...state.items, ...items] : items;
    state = state.copyWith(
      items: newPayment,
      total: total,
      page: page,
      limit: limit,
      isLastPage: isLastPage,
      isPreviousPage: isPreviousPage,
    );
  }

  Future<void> addPayment(Payment newPayment) async {
    state = state.copyWith(items: [newPayment, ...state.items]);
  }

  List<Payment> getPaymentsByBill(String billId) {
    return state.items.where((p) => p.billId == billId).toList();
  }

  double getPaidAmount(String billId) {
    return getPaymentsByBill(billId).fold(0.0, (p, e) => p + e.amount);
  }
  
  List<Payment> searchPayment(String query) {
    if (query.trim().isEmpty) return state.items;
    final q = query.toLowerCase();
    return state.items.where((b) {
      final byName = b.customerName.toLowerCase().contains(q);
      return byName;
    }).toList();
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref);
});
