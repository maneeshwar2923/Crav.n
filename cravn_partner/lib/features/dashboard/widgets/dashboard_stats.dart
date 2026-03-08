import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.totalOrders,
    required this.grossRevenue,
    required this.averageRating,
    required this.ratingCount,
    required this.pendingSafetyChecks,
  });

  final int totalOrders;
  final double grossRevenue;
  final double averageRating;
  final int ratingCount;
  final int pendingSafetyChecks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Dimensions.s12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: Dimensions.s12,
          mainAxisSpacing: Dimensions.s12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              label: 'Total Orders',
              value: totalOrders.toString(),
              icon: Icons.shopping_bag_outlined,
              color: Colors.blue,
            ),
            _StatCard(
              label: 'Revenue',
              value: '₹${grossRevenue.toStringAsFixed(0)}',
              icon: Icons.currency_rupee,
              color: cravnPrimary,
            ),
            _StatCard(
              label: 'Rating',
              value: averageRating.toStringAsFixed(1),
              subValue: '($ratingCount)',
              icon: Icons.star_outline,
              color: Colors.amber,
            ),
            _StatCard(
              label: 'Safety Checks',
              value: pendingSafetyChecks.toString(),
              icon: Icons.health_and_safety_outlined,
              color: pendingSafetyChecks > 0 ? cravnError : Colors.grey,
              isAlert: pendingSafetyChecks > 0,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        border: Border.all(
          color: isAlert ? color.withOpacity(0.5) : const Color(0xFFE0E0E0),
          width: isAlert ? 1.5 : 1,
        ),
        boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (isAlert)
                Icon(Icons.warning_amber_rounded, color: color, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isAlert ? color : cravnSecondary,
                    ),
                  ),
                  if (subValue != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      subValue!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
