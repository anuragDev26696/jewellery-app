import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/models/payment.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/providers/payment_provider.dart';
import 'package:swarn_abhushan/providers/user_provider.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/utils/api.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class PaymentService {
  final Ref _ref;

  PaymentService(this._ref);

  Api get _api => _ref.read(apiProvider);
  PaymentNotifier get _paymentNotifier => _ref.read(paymentNotifierProvider.notifier);
  LoaderService get _loader => _ref.read(loaderServiceProvider);

  Future<dynamic> addPayment(Payment newReq) async {
    try {
      final res = await _api.post('payment', body: newReq.toJson());
      final payment = Payment.fromMap(res['payment']);
      final updatedBill = Bill.fromMap(res['updatedBill']);
      Toastr.show('Payment created successfully');
      return {
        'payment': payment,
        'updatedBill': updatedBill,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get all payments for a bill
  Future<List<Payment>> getPaymentsForBill(String billId, int page) async {
    try {
      _loader.show();
      final response = await _api.post('payment/search', body: {
        "billId": billId,
        'page': 1,
        'limit': 50,
      });

      final List data = response['data'] ?? [];
      final payments = data.map((e) => Payment.fromMap(e)).toList();
      await _paymentNotifier.load(
        items: payments, 
        total: response['total'] ?? payments.length,
        page: response['page'] ?? 1,
        limit: response['limit'] ?? 50,
        isLastPage: response['isLastPage'] ?? false,
        isPreviousPage: response['isPreviousPage'] ?? false,
        append: page > 1,
      );
      return payments;
    } catch(e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }

  /// Get all payments with user name populated
  List<Map<String, dynamic>> getPaymentsWithUserName() {
    final payments = _ref.read(paymentNotifierProvider);
    final usersState = _ref.read(userNotifierProvider);

    return payments.items.map((p) {
      final user = usersState.users.firstWhere(
        (u) => u.uuid == p.customerId,
        orElse: () => User(
          uuid: '',
          name: '',
          mobile: '',
          email: '',
          address: '',
        ),
      );

      return {
        'uuid': p.uuid,
        'billId': p.billId,
        'customerId': p.customerId,
        'userName': user.name,
        'amount': p.amount,
        'mode': p.paymentMode,
        'createdAt': p.createdAt,
      };
    }).toList();
  }
}
