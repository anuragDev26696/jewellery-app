import 'dart:convert';

class Payment {
  String? uuid;
  double amount;
  String paymentMode;
  String billId;
  String? customerId;
  String customerName;
  DateTime? createdAt;
  String note;

  Payment({
    this.uuid,
    required this.amount,
    required this.paymentMode,
    required this.billId,
    this.customerId = '',
    this.customerName = '',
    this.createdAt,
    this.note = '',
  });

  
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'paymentMode': paymentMode,
      'billId': billId,
      'note': note,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      uuid: map['id'] ?? "",
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMode: map['paymentMode'] ?? '',
      billId: map['billId'] ?? "",
      customerId: map['customerId'] ?? "",
      customerName: map['customerName'] ?? "",
      note: map['note'] ?? "",
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory Payment.fromJson(String source) => Payment.fromMap(json.decode(source));
}

class PaymentState {
  final List<Payment> items;
  final int total;
  final int page;
  final int limit;
  final bool isLastPage;
  final bool isPreviousPage;
  final bool isLoading;
  final bool isAdding;
  final bool isDeleting;
  final Payment? selectedPayment;

  const PaymentState({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.isLastPage = false,
    this.isPreviousPage = false,
    this.isLoading = false,
    this.isAdding = false,
    this.isDeleting = false,
    this.selectedPayment,
  });

  PaymentState copyWith({
    List<Payment>? items,
    int? total,
    int? page,
    int? limit,
    bool? isLastPage,
    bool? isPreviousPage,
    bool? isLoading,
    bool? isAdding,
    bool? isDeleting,
    Payment? selectedPayment,
  }) {
    return PaymentState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isLastPage: isLastPage ?? this.isLastPage,
      isPreviousPage: isPreviousPage ?? this.isPreviousPage,
      isLoading: isLoading ?? false,
      isAdding: isAdding ?? this.isAdding,
      isDeleting: isDeleting ?? this.isDeleting,
      selectedPayment: selectedPayment
    );
  }
}
