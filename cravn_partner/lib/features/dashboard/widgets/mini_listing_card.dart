import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class MiniListingCard extends StatelessWidget {
  const MiniListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  final Map<String, dynamic> listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = listing['title']?.toString() ?? 'Listing';
    final status = (listing['status'] ?? 'pending').toString();
    final price = listing['price'];
    final priceLabel =
        (price == null || price == 0 || price == 'free') ? 'Free' : '₹$price';
    final portions = (listing['portions_available'] as num?)?.toInt() ?? 0;

    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: Dimensions.s8),
                  Text(
                    '$priceLabel • ${portions > 0 ? '$portions portions' : 'Portions pending'}',
                    style: const TextStyle(color: Color(0xFF5C7470)),
                  ),
                  const SizedBox(height: Dimensions.s8),
                  Chip(
                    label: Text(status.toUpperCase()),
                    backgroundColor: const Color(0xFFE7F6EE),
                    labelStyle: const TextStyle(
                      color: cravnSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
