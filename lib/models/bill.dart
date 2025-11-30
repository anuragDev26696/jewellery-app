import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swarn_abhushan/models/item.dart';

enum PaymentStatus {
  pending,
  paid,
  partialPaid,
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partialPaid:
        return 'Partial Paid';
      default:
        return 'Pending';
    }
  }

  String get shortLabel {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partialPaid:
        return 'Partial';
      default:
        return 'Pending';
    }
  }

  PaymentStatusColor get colors {
    switch (this) {
      case PaymentStatus.paid:
        return PaymentStatusColor(Colors.green, Colors.green.withValues(alpha: 0.12));
      case PaymentStatus.partialPaid:
        return PaymentStatusColor(Colors.orange, Colors.orange.withValues(alpha: 0.12));
      default:
        return PaymentStatusColor(Colors.red, Colors.red.withValues(alpha: 0.12));
    }
  }

  static PaymentStatus fromString(String? s) {
    if (s == null) return PaymentStatus.pending;
    switch (s) {
      case 'Paid':
        return PaymentStatus.paid;
      case 'Partial Paid':
        return PaymentStatus.partialPaid;
      case 'Pending':
      default:
        return PaymentStatus.pending;
    }
  }
}


class PaymentStatusColor {
  final Color text;
  final Color background;
  PaymentStatusColor(this.text, this.background);
}

PaymentStatus paymentStatusFromString(String? value) {
  switch (value) {
    case 'Pending':
      return PaymentStatus.pending;
    case 'Paid':
      return PaymentStatus.paid;
    case 'Partial Paid':
      return PaymentStatus.partialPaid;
    default:
      return PaymentStatus.pending;
  }
}

String paymentStatusToString(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return 'Pending';
    case PaymentStatus.paid:
      return 'Paid';
    case PaymentStatus.partialPaid:
      return 'Partial Paid';
  }
}


class Bill {
  String? uuid;
  String billNumber;
  String? customerName;
  String? customerPhone;
  DateTime? createdAt;
  List<Item> items;
  double discount;
  double? subtotal;
  double? taxAmount;
  double? total;
  double? dueAmount;
  double tax;
  String notes;
  String customerId;
  PaymentStatus paymentStatus;

  Bill({
    required this.billNumber,
    required this.customerId,
    required this.items,
    this.createdAt,
    this.customerName,
    this.customerPhone,
    this.discount = 0,
    this.notes = '',
    this.paymentStatus = PaymentStatus.pending,
    this.subtotal,
    this.tax = 0,
    this.taxAmount,
    this.total,
    this.uuid,
    this.dueAmount,
  });
  double get subTotal => items.fold(0.0, (p, e) => p + e.basicAmount);
  double get totalMaking => items.fold(0.0, (p, e) => p + e.makingCharge);

  double get taxableAmount => subTotal + totalMaking - discount;
  double get taxamount => (taxableAmount * tax) / 100.0;
  double get grandTotal => taxableAmount + taxamount;

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'billNumber': billNumber,
      'items': items.map((i) => i.toMap()).toList(),
      'discount': discount,
      'tax': tax,
      'notes': notes,
      'customerId': customerId,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      uuid: map['uuid'],
      billNumber: map['billNumber'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null),
      items: List<Item>.from((map['items'] as List).map((e) => Item.fromMap(Map<String, dynamic>.from(e))),
      ),
      discount: (map['discount'] ?? 0)?.toDouble(),
      tax: (map['tax'] ?? 0)?.toDouble(),
      notes: map['notes'] ?? '',
      customerId: map['customerId'] ?? '',
      subtotal: (map['subtotal'] ?? 0)?.toDouble(),
      taxAmount: (map['taxAmount'] ?? 0)?.toDouble(),
      total: (map['total'] ?? 0)?.toDouble(),
      paymentStatus: PaymentStatusX.fromString(map['paymentStatus']),
      dueAmount: (map['dueAmount'] ?? 0)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory Bill.fromJson(String source) => Bill.fromMap(json.decode(source));
}

class BillState {
  final List<Bill> bills;
  final int total;
  final int page;
  final int limit;
  final bool isLastPage;
  final bool isPreviousPage;
  final bool isLoading;
  final bool isAdding;
  final bool isUpdating;
  final bool isDeleting;
  final Bill? selectedBill;

  const BillState({
    this.bills = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.isLastPage = false,
    this.isPreviousPage = false,
    this.isLoading = false,
    this.isAdding = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.selectedBill,
  });

  BillState copyWith({
    List<Bill>? bills,
    int? total,
    int? page,
    int? limit,
    bool? isLastPage,
    bool? isPreviousPage,
    bool? isLoading,
    bool? isAdding,
    bool? isUpdating,
    bool? isDeleting,
    Bill? selectedBill,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isLastPage: isLastPage ?? this.isLastPage,
      isPreviousPage: isPreviousPage ?? this.isPreviousPage,
      isLoading: isLoading ?? false,
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      selectedBill: selectedBill
    );
  }
}
