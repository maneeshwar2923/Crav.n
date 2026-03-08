import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class RecentOrderTile extends StatelessWidget {
  const RecentOrderTile({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final listing = order['food_listings'] as Map<String, dynamic>?;
    final title = listing?['title']?.toString() ?? 'Order';
    final status = (order['status'] ?? 'pending').toString();
    final quantity = (order['quantity'] as num? ?? 0).toInt();
    final placedAt = order['placed_at']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cravnPrimary.withOpacity(0.1),
          child: Text(
            quantity > 0 ? quantity.toString() : '1',
            style: const TextStyle(color: cravnPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Status: ${status.toUpperCase()}${placedAt != null ? '\nPlaced: $placedAt' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

class SafetyCheckTile extends StatelessWidget {
  const SafetyCheckTile({super.key, required this.check});

  final Map<String, dynamic> check;

  @override
  Widget build(BuildContext context) {
    final listing = check['food_listings'] as Map<String, dynamic>?;
    final title = listing?['title']?.toString() ?? 'Listing';
    final status = (check['status'] ?? 'pending').toString();
    final submittedAt = check['submitted_at']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      child: ListTile(
        leading: const Icon(Icons.health_and_safety_outlined, color: cravnPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Status: ${status.toUpperCase()}${submittedAt != null ? '\nSubmitted: $submittedAt' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
