import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    final reviews = await SupabasePartnerService.instance.getReviews();
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    }
  }

  Future<void> _replyToReview(String reviewId, String currentReply) async {
    final controller = TextEditingController(text: currentReply);
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Write your reply here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: cravnPrimary),
            child: const Text('Post Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reply != null && reply.isNotEmpty) {
      setState(() => _loading = true);
      final success = await SupabasePartnerService.instance.replyToReview(reviewId, reply);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply posted successfully')),
          );
          _loadReviews();
        } else {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post reply')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : _reviews.isEmpty
              ? const Center(child: Text('No reviews yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.s16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return _ReviewCard(
                      review: _reviews[index],
                      onReply: () => _replyToReview(
                        _reviews[index]['id'],
                        _reviews[index]['host_reply'] ?? '',
                      ),
                    );
                  },
                ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onReply});

  final Map<String, dynamic> review;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
    final comment = review['comment'] ?? '';
    final reply = review['host_reply'];
    final customerName = review['profiles']?['full_name'] ?? 'Guest';
    final listingTitle = review['food_listings']?['title'] ?? 'Unknown Item';
    final date = DateTime.tryParse(review['created_at'] ?? '') ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      listingTitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rating >= 4 ? Colors.green : (rating >= 3 ? Colors.orange : Colors.red),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Text(
                        rating.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.s12),
            Text(comment),
            const SizedBox(height: Dimensions.s8),
            Text(
              _formatDate(date),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const Divider(height: 24),
            if (reply != null)
              Container(
                padding: const EdgeInsets.all(Dimensions.s12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Reply',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: cravnPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(reply, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
