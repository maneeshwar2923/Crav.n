import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/supabase_partner_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/error_utils.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  final _service = SupabasePartnerService.instance;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  List<Map<String, dynamic>> _checks = const <Map<String, dynamic>>[];
  String _filter = 'all';
  bool _loading = false;
  String? _error;

  static const Map<String, String> _filterLabels = {
    'all': 'All statuses',
    'pending': 'Pending review',
    'approved': 'Approved',
    'flagged': 'Flagged',
    'rejected': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _loadSafetyChecks();
  }

  Future<void> _loadSafetyChecks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.getFoodSafetyChecks();
      setState(() => _checks = rows);
    } catch (e) {
      final message = resolveDisplayError(e);
      if (mounted) {
        setState(() => _error = message);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _checks
        : _checks
            .where((row) => (row['status'] ?? '').toString() == _filter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food safety center'),
        actions: [
          IconButton(
            onPressed: _loadSafetyChecks,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cravnPrimary))
          : RefreshIndicator(
              onRefresh: _loadSafetyChecks,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety_outlined,
                          color: Color(0xFF006D3B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stay compliant with Crav\'n\'s food safety guidelines.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _filter == 'all'
                              ? 'Upload your first safety checklist to unlock verified badges.'
                              : 'No ${_filterLabels[_filter]?.toLowerCase() ?? 'matching'} checklists yet.',
                        ),
                      ),
                    )
                  else
                    ...filtered.map(_buildSafetyCard),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChips() {
    final chips = <Widget>[];
    _filterLabels.forEach((value, label) {
      chips.add(Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == value,
          onSelected: (selected) {
            if (!selected) return;
            setState(() => _filter = value);
          },
        ),
      ));
    });
    return Wrap(children: chips);
  }

  Widget _buildSafetyCard(Map<String, dynamic> row) {
    final listing = row['food_listings'] as Map<String, dynamic>?;
    final title = listing?['title']?.toString() ?? 'Listing';
    final status = (row['status'] ?? '').toString();
    final submitted = row['submitted_at']?.toString();
    final reviewed = row['reviewed_at']?.toString();
    final notes = row['notes']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_statusLabel(status)),
                  backgroundColor: _statusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Checklist ID: ${row['id']}'),
            if (submitted != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Submitted ${_formatTimestamp(submitted)}'),
              ),
            if (reviewed != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Reviewed ${_formatTimestamp(reviewed)}'),
              ),
            if (notes != null && notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Reviewer notes: $notes'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return _dateFormat.format(parsed.toLocal());
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'flagged':
        return 'Flagged';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty
            ? 'Unknown'
            : '${status[0].toUpperCase()}${status.substring(1)}';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'flagged':
        return const Color(0xFFFFEBEE);
      case 'rejected':
        return const Color(0xFFFFCDD2);
      default:
        return const Color(0xFFE0E0E0);
    }
  }
}
