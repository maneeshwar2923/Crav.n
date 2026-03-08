import 'package:flutter/material.dart';

class RadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const RadioGroup({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (e) =>
                // The Radio API's `groupValue` / `onChanged` usage is currently
                // flagged as deprecated by newer SDKs which encourage using a
                // RadioGroup ancestor. For backward compatibility and until we
                // migrate to the new ancestor-based API, ignore the deprecation
                // lint here.
                // ignore: deprecated_member_use
                Radio<T>(value: e, groupValue: value, onChanged: onChanged),
          )
          .toList(),
    );
  }
}
