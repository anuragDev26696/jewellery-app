import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/models/payment.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/services/payment_service.dart';

final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref ref;
  late final PaymentService _service;

  PaymentNotifier(this.ref) : super(const PaymentState()){
    _service = ref.read(paymentServiceProvider);
  }
  
  LoaderService get _loader => ref.read(loaderServiceProvider);

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
    state = state.copyWith(isAdding: true);
    _loader.show();
    try {
      final res = await _service.addPayment(newPayment);
      final payment = res['payment'] as Payment;
      final updatedBill = res['updatedBill'] as Bill;
      await ref.read(billingNotifierProvider.notifier).updateBill(updatedBill.uuid!, updatedBill, byPayment: true);
      state = state.copyWith(
        items: [payment, ...state.items],
        total: state.total + 1,
      );
    } finally {
      state = state.copyWith(isAdding: false);
      _loader.hide();
    }
  }

  List<Payment> getPaymentsByBill(String billId) {
    return state.items.where((p) => p.billId == billId).toList();
  }
  
  Future<void> searchPayment({String? billId, int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true);
    _loader.show();
    try {
      final res = await _service.getPaymentsForBill({
        if (billId != null) 'billId': billId,
        'page': page,
        'limit': limit,
      });
      final List<Payment> payments = List<Payment>.from(
        (res['data'] as List).map(
          (e) => Payment.fromMap(e as Map<String, dynamic>),
        ),
      );
      await load(
        items: payments,
        total: res['total'] as int,
        page: res['page'] as int,
        limit: res['limit'] as int,
        isLastPage: res['isLastPage'] as bool,
        isPreviousPage: res['isPreviousPage'] as bool,
        append: page > 1,
      );
    } finally {
      state = state.copyWith(isLoading: false);
      _loader.hide();
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref);
});
