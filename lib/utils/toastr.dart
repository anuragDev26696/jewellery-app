import 'package:flutter/material.dart';
import 'package:swarn_abhushan/utils/constant.dart';

class Toastr {
  static void show(String message, {bool success = true}) {
    final context = globalNavigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}
