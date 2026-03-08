import 'package:flutter/material.dart';

class CravnDialog {
  static Future<T?> show<T>(BuildContext context, Widget child) async {
    return showDialog<T>(
      context: context,
      builder: (_) => AlertDialog(content: child),
    );
  }
}
