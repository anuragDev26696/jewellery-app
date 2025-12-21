import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:reactive_forms/reactive_forms.dart';
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

class TwoDecimalNumberFormatter extends TextInputFormatter {
  final double? maxValue; // <-- NEW OPTIONAL PARAM

  TwoDecimalNumberFormatter({this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // ---------- RULE 1: ZERO REPLACEMENT ----------
    // If previous = "0" and user types a number => replace 0
    if (oldValue.text == "0" && text.length == 2 && text.startsWith("0")) {
      text = text.substring(1); // remove first 0
    }

    // ---------- RULE 2: ONLY ONE DECIMAL POINT ----------
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    // ---------- RULE 3: MAX 2 DECIMAL DIGITS ----------
    if (text.contains(".")) {
      final parts = text.split(".");
      if (parts.length > 1 && parts[1].length > 2) {
        return oldValue; // block input
      }
    }

    // ---------- RULE 4: ONLY VALID NUMBER CHARACTERS ----------
    final pattern = RegExp(r'^\d*\.?\d{0,2}$');
    if (!pattern.hasMatch(text)) {
      return oldValue;
    }

    // RULE 5: NEW — Max Value Check (only when provided)
    if (maxValue != null && text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null && value > maxValue!) {
        return oldValue; // block input
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

const List<Map<String, String?>> paymentFilters = [
  {"label": "All", "value": null},
  {"label": "Paid", "value": "Paid"},
  {"label": "Pending", "value": "Pending"},
  {"label": "Partial Paid", "value": "Partial Paid"},
];

class CommonUtils {
  static Widget buildLabel(String label, String controlName, FormGroup form) {
    final control = form.control(controlName);
    final isRequired = control.validators.any((v) => v == Validators.required);
    
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}