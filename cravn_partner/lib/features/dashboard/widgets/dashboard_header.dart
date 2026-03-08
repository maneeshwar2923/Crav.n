import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.fullName,
    required this.status,
    required this.portionsSaved,
    required this.onCreateListing,
    required this.onViewOrders,
    required this.onSafetyCenter,
  });

  final String fullName;
  final String status;
  final int portionsSaved;
  final VoidCallback onCreateListing;
  final VoidCallback onViewOrders;
  final VoidCallback onSafetyCenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Section
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: status),
          ],
        ),
        const SizedBox(height: Dimensions.s24),

        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Listing',
                onTap: onCreateListing,
              ),
            ),
            const SizedBox(width: Dimensions.s12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                onTap: onViewOrders,
              ),
            ),
            const SizedBox(width: Dimensions.s12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.health_and_safety_outlined,
                label: 'Safety',
                onTap: onSafetyCenter,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isVerified = status.toLowerCase() == 'approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified ? cravnPrimary.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSm),
        border: Border.all(
          color: isVerified ? cravnPrimary.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.hourglass_empty,
            size: 14,
            color: isVerified ? cravnPrimary : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isVerified ? cravnPrimary : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? cravnPrimary : Colors.white,
      elevation: 0, // Flat style
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : cravnSecondary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : cravnSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
