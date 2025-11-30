import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:swarn_abhushan/models/item.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> globalDialogKey = GlobalKey<NavigatorState>();

class CalculateTax {
  const CalculateTax(this.items, this.discount, this.taxPercent);
  final List<Item> items;
  final double discount;
  final double taxPercent;

  double round2(double v) => double.parse(v.toStringAsFixed(2));

  double get subtotal => round2(items.fold(0.0, (p, e) => p + e.total));
  double get totalMaking => items.fold(0.0, (p, e) => p + e.makingChargeAmount);

  double get taxableAmount => round2(subtotal - discount);
  double get taxAmount => round2((taxableAmount * taxPercent) / 100.0);
  double get grandTotal => round2(taxableAmount + taxAmount);
}

String? Function(String?) numberValidator({
  required String field,
  bool requiredField = true,
  double? min,
  double? max,
}) {
  return (String? v) {
    if (v == null || v.isEmpty) {
      return requiredField ? 'Please enter $field' : null;
    }

    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';

    if (min != null && n < min) return '$field must be at least $min';
    if (max != null && n > max) return '$field cannot exceed $max';

    return null;
  };
}

String? isRequired(String? v, String field) => (v == null || v.isEmpty) ? 'Please enter $field' : null;


void sharePdf(Uint8List localPath, String fileName) {
  Printing.sharePdf(bytes: localPath, filename: fileName);
}
