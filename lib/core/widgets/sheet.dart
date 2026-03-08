import 'package:flutter/material.dart';

class BottomSheetWidget {
  static Future<T?> show<T>(BuildContext context, Widget child) =>
      showModalBottomSheet<T>(context: context, builder: (_) => child);
}
