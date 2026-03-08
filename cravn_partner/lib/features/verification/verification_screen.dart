import 'package:flutter/material.dart';

class PartnerVerificationScreen extends StatelessWidget {
  const PartnerVerificationScreen({
    super.key,
    required this.profile,
    required this.verification,
    required this.onRefresh,
    required this.onSignOut,
    this.onStartApplication,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic>? verification;
  final Future<void> Function() onRefresh;
  final Future<void> Function()?
      onStartApplication; // reserved for future flows
  final VoidCallback onSignOut;

  String get _status => (profile['host_status'] ?? 'none').toString();

  bool get _isPending => _status == 'pending';

  @override
  Widget build(BuildContext context) {
    final submittedAt = verification?['submitted_at']?.toString();
    final reviewedAt = verification?['reviewed_at']?.toString();
    final reviewerNotes = verification?['notes']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host verification'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headline,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _description,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (submittedAt != null) ...[
                    const SizedBox(height: 12),
                    Text('Last submitted: $submittedAt'),
                  ],
                  if (reviewedAt != null) ...[
                    const SizedBox(height: 4),
                    Text('Reviewed: $reviewedAt'),
                  ],
                  if (reviewerNotes != null && reviewerNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Notes from reviewer:\n$reviewerNotes',
                        style: const TextStyle(color: Color(0xFF8A4B00)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildPrimaryAction(context),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.sync_outlined),
                    label: const Text('Check status again'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verification checklist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChecklistRow(
                    completed: _isPending || _status == 'approved',
                    label:
                        'Submit your food safety documents and contact details.',
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    completed: verification?['document_urls'] != null,
                    label: 'Upload kitchen hygiene photos or certificates.',
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    completed: profile['phone_number'] != null,
                    label:
                        'Confirm a reachable phone number so diners can contact you.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Need help?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reach out to onboarding@cravn.app with your business name and we will fast-track your review.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _headline {
    switch (_status) {
      case 'pending':
        return 'Verification in review';
      case 'rejected':
        return 'Verification needs updates';
      default:
        return 'Complete your verification';
    }
  }

  String get _description {
    switch (_status) {
      case 'pending':
        return 'We are reviewing your submission. This typically takes less than 24 hours. You will receive a notification once approved.';
      case 'rejected':
        return 'We reviewed your submission and need a few updates before approving your kitchen. Review the notes below or contact support for clarity.';
      default:
        return 'Share your food safety details to unlock the Partner dashboard and begin accepting diners.';
    }
  }

  Widget _buildPrimaryAction(BuildContext context) {
    if (_isPending) {
      return ElevatedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.hourglass_top_outlined),
        label: const Text('Refresh status'),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        if (onStartApplication != null) {
          await onStartApplication!.call();
          return;
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Digital document upload is on the roadmap. Contact onboarding@cravn.app to share your files.',
            ),
          ),
        );
      },
      icon: const Icon(Icons.upload_file_outlined),
      label: const Text('Send verification documents'),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.completed, required this.label});

  final bool completed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? const Color(0xFF006D3B) : const Color(0xFF9E9E9E),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}
