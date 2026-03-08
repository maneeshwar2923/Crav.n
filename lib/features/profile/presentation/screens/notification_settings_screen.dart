import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/supabase_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _loading = true;
  bool _saving = false;
  
  // Notification preferences
  bool _orderUpdates = true;
  bool _newListingsNearby = true;
  bool _promotional = false;
  bool _chatMessages = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = SupabaseService.instance.currentUser?.id;
      if (userId == null) return;
      
      final data = await SupabaseService.instance.client
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
      
      if (data != null && mounted) {
        setState(() {
          _orderUpdates = data['order_updates'] ?? true;
          _newListingsNearby = data['new_listings_nearby'] ?? true;
          _promotional = data['promotional'] ?? false;
          _chatMessages = data['chat_messages'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _saving = true);
    
    try {
      final userId = SupabaseService.instance.currentUser?.id;
      if (userId == null) return;
      
      await SupabaseService.instance.client
        .from('notification_preferences')
        .upsert({
          'user_id': userId,
          'order_updates': _orderUpdates,
          'new_listings_nearby': _newListingsNearby,
          'promotional': _promotional,
          'chat_messages': _chatMessages,
          'updated_at': DateTime.now().toIso8601String(),
        });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: cravnBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cravnPrimary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined, color: cravnPrimary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Notification Preferences',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose what notifications you want to receive',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Settings card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildToggleTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Order Updates',
                      subtitle: 'Get notified about your order status',
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      icon: Icons.location_on_outlined,
                      title: 'New Listings Nearby',
                      subtitle: 'Alert when new food is available near you',
                      value: _newListingsNearby,
                      onChanged: (v) => setState(() => _newListingsNearby = v),
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat Messages',
                      subtitle: 'Get notified when you receive messages',
                      value: _chatMessages,
                      onChanged: (v) => setState(() => _chatMessages = v),
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      icon: Icons.local_offer_outlined,
                      title: 'Promotions & Tips',
                      subtitle: 'Occasional updates about features and offers',
                      value: _promotional,
                      onChanged: (v) => setState(() => _promotional = v),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: cravnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Preferences',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cravnPrimary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: cravnPrimary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: cravnPrimary,
      ),
    );
  }
}
