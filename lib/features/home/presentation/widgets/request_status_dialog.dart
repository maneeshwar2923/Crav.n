import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

enum RequestState { loading, success, error }

class RequestStatusDialog extends StatelessWidget {
  final RequestState state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onViewOrder;

  const RequestStatusDialog({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildSubtitle(),
            const SizedBox(height: 32),
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case RequestState.loading:
        return Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cravnSecondary,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(cravnPrimary),
          ),
        );
      case RequestState.success:
        return const Icon(Icons.check_circle, color: cravnPrimary, size: 80);
      case RequestState.error:
        return const Icon(Icons.error_outline, color: cravnError, size: 80);
    }
  }

  Widget _buildTitle() {
    switch (state) {
      case RequestState.loading:
        return const Text(
          'Securing your meal...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        );
      case RequestState.success:
        return const Text(
          'Meal Reserved!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        );
      case RequestState.error:
        return const Text(
          'Request Failed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildSubtitle() {
    switch (state) {
      case RequestState.loading:
        return const Text(
          'Connecting to the kitchen...',
          style: TextStyle(color: cravnTextSecondary),
          textAlign: TextAlign.center,
        );
      case RequestState.success:
        return const Text(
          'Your order has been placed successfully. You can track it in the Orders tab.',
          style: TextStyle(color: cravnTextSecondary),
          textAlign: TextAlign.center,
        );
      case RequestState.error:
        return Text(
          errorMessage ?? 'Something went wrong. Please try again.',
          style: const TextStyle(color: cravnTextSecondary),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildAction(BuildContext context) {
    switch (state) {
      case RequestState.loading:
        return const SizedBox.shrink(); // No action while loading
      case RequestState.success:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onViewOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: cravnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'View Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      case RequestState.error:
         return Row(
           children: [
             Expanded(
               child: OutlinedButton(
                 onPressed: () => Navigator.pop(context),
                 style: OutlinedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: cravnTextSecondary),
                 ),
                 child: const Text('Cancel', style: TextStyle(color: cravnTextSecondary)),
               ),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: ElevatedButton(
                 onPressed: onRetry,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: cravnPrimary,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(16),
                   ),
                 ),
                 child: const Text(
                   'Retry',
                   style: TextStyle(
                     color: Colors.white, 
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
           ],
         );
    }
  }
}
