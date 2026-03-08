import 'package:flutter/material.dart';

/// FoodListingCard matching React/Vite web app UI exactly
/// Shows image with overlay, price badge, host avatar, veg indicator, and rating
class FoodListingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final dynamic price; // num or String ('free')
  final String hostName;
  final String hostAvatar;
  final bool isVeg;
  final double rating;
  final int? reviewCount;
  final VoidCallback onTap;
  final VoidCallback? onRequest;
  final String? status;

  const FoodListingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.hostName,
    required this.hostAvatar,
    required this.isVeg,
    required this.rating,
    this.reviewCount,
    required this.onTap,
    this.onRequest,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = rating.isFinite ? rating : 5.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay, price badge, and host avatar
            SizedBox(
              height: 144, // h-36 in Tailwind = 144px
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Food Image
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay (from-black/60 via-black/20 to-transparent)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Price Badge (top-right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: price == 'free' || price == 0
                            ? const Color(0xFF4CAF50) // bg-[#4CAF50] for FREE
                            : const Color(0xFF006D3B), // bg-[#006D3B] for paid
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price == 'free' || price == 0 ? 'FREE' : '₹$price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (status != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _badgeColor(status!).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Title Overlay (bottom-left)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 60, // Leave space for avatar
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Host Avatar (bottom-right)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 36, // 9*4 = 36 (Tailwind uses 4px unit)
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(hostAvatar),
                          fit: BoxFit.cover,
                          onError: (error, stack) {},
                        ),
                      ),
                      child: hostAvatar.isEmpty
                          ? CircleAvatar(
                              backgroundColor: const Color(0xFF006D3B),
                              child: Text(
                                hostName.isNotEmpty
                                    ? hostName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance and Veg Indicator
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF666666)),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Veg Indicator
                      if (isVeg)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF4CAF50), width: 2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Rating
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        displayRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      if ((reviewCount ?? 0) > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${reviewCount ?? 0})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return const Color(0xFF0F9D58);
      case 'pending':
        return const Color(0xFFF9A825);
      case 'rejected':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF5C7470);
    }
  }
}
