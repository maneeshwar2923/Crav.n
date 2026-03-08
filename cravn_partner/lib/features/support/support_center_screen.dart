import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  static const String _supportEmail = 'onboarding@cravn.app';
  static const String _supportPhone = '+1-888-555-0199';
  static const String _safetyGuideUrl =
      'https://www.notion.so/cravn/Partner-Food-Safety-Checklist';
  static const String _faqUrl = 'https://www.notion.so/cravn/Cravn-Partner-FAQ';

  Future<void> _launch(Uri uri, BuildContext context) async {
    if (!await launchUrl(uri)) {
      // Keep this surface level; partners just need a quick retry cue.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open ${uri.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headset_mic_outlined,
                          color: Color(0xFF006D3B)),
                      const SizedBox(width: 8),
                      Text(
                        'Reach the Crav\'n team',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We respond within a few minutes during active rescue hours. '
                    'Choose the channel that works best for you.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launch(
                        Uri(scheme: 'tel', path: _supportPhone), context),
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Call support'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _launch(
                      Uri(
                        scheme: 'mailto',
                        path: _supportEmail,
                        queryParameters: {
                          'subject': 'Crav\'n partner assistance',
                        },
                      ),
                      context,
                    ),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email onboarding@cravn.app'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.book_outlined, color: Color(0xFF006D3B)),
                      const SizedBox(width: 8),
                      Text(
                        'Guides and resources',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.checklist_outlined,
                        color: Color(0xFF5C7470)),
                    title: const Text('Food safety checklist'),
                    subtitle: const Text(
                        'Step-by-step walkthrough of Crav\'n standards.'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launch(Uri.parse(_safetyGuideUrl), context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.question_answer_outlined,
                        color: Color(0xFF5C7470)),
                    title: const Text('Partner FAQ'),
                    subtitle:
                        const Text('Most common questions and quick fixes.'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launch(Uri.parse(_faqUrl), context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Color(0xFF006D3B)),
                      const SizedBox(width: 8),
                      Text(
                        'Best practices',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Update portion availability after each pickup.\n'
                    '• Keep your food safety logs ready for surprise audits.\n'
                    '• Message diners if you\'re running behind pickup windows.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
