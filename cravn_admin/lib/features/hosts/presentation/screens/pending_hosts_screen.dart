import 'package:flutter/material.dart';
import '../../../../core/services/supabase_admin_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';

class PendingHostsScreen extends StatefulWidget {
  const PendingHostsScreen({super.key});

  @override
  State<PendingHostsScreen> createState() => _PendingHostsScreenState();
}

class _PendingHostsScreenState extends State<PendingHostsScreen> {
  List<Map<String, dynamic>> _hosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    setState(() => _isLoading = true);
    final hosts = await SupabaseAdminService.instance.getPendingHosts();
    if (mounted) {
      setState(() {
        _hosts = hosts;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveHost(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Host'),
        content: Text('Are you sure you want to approve "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseAdminService.instance.approveHost(userId);
      _loadHosts(); // Refresh list
    }
  }

  Future<void> _rejectHost(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Host'),
        content: Text('Are you sure you want to reject "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cravnError),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseAdminService.instance.rejectHost(userId);
      _loadHosts(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: cravnPrimary));
    }

    if (_hosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending hosts', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.s16),
      itemCount: _hosts.length,
      itemBuilder: (context, index) {
        final host = _hosts[index];
        final id = host['id'] as String;
        final name = host['full_name'] ?? 'Unknown Name';
        final description = host['description'] ?? 'No description provided.';
        final email = 'Email not exposed in profile'; // Profiles table might not have email, usually in auth.users

        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.s16),
          padding: const EdgeInsets.all(Dimensions.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            boxShadow: Dimensions.boxShadowSmall(Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cravnPrimary.withOpacity(0.1),
                    child: Text(name[0].toUpperCase(),
                        style: const TextStyle(color: cravnPrimary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: Dimensions.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('ID: $id',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.s16),
              const Text('Description:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cravnSecondary)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: Dimensions.s16),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: cravnPrimary),
                  const SizedBox(width: 8),
                  Text(host['phone']?.toString() ?? 'No phone provided', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: Dimensions.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _rejectHost(id, name),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cravnError,
                      side: const BorderSide(color: cravnError),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: Dimensions.s16),
                  ElevatedButton(
                    onPressed: () => _approveHost(id, name),
                     style: ElevatedButton.styleFrom(
                      backgroundColor: cravnPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
