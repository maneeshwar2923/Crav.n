import 'package:flutter/material.dart';
import '../theme/dimensions.dart';

class CravnButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  const CravnButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            filled ? Theme.of(context).colorScheme.primary : Colors.transparent,
        foregroundColor:
            filled ? Colors.white : Theme.of(context).colorScheme.primary,
        elevation: filled ? 2 : 0,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.buttonPaddingHorizontal,
            vertical: Dimensions.buttonPaddingVertical),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.fontSizeBase,
              color: filled
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary)),
    );
  }
}
