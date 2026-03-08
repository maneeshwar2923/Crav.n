import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class ListingPerformanceCard extends StatelessWidget {
  const ListingPerformanceCard({super.key, required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final title = row['title']?.toString() ?? 'Listing';
    final orders = (row['total_orders'] as num? ?? 0).toInt();
    final revenue = (row['gross_revenue'] as num? ?? 0).toDouble();
    final rating = (row['average_rating'] as num? ?? 0).toDouble();
    final reviewCount = (row['review_count'] as num? ?? 0).toInt();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cravnPrimary.withOpacity(0.1),
          child: Text(
            orders > 0 ? orders.toString() : '1',
            style: const TextStyle(color: cravnSecondary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$orders orders • ₹${revenue.toStringAsFixed(0)} revenue'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
            const SizedBox(width: 4),
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : '—',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (reviewCount > 0)
              Text(' ($reviewCount)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
