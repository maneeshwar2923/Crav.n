import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';

class KitchenSettingsScreen extends StatefulWidget {
  const KitchenSettingsScreen({super.key});

  @override
  State<KitchenSettingsScreen> createState() => _KitchenSettingsScreenState();
}

class _KitchenSettingsScreenState extends State<KitchenSettingsScreen> {
  bool _loading = true;

  
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  int _prepTimeMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final profile = await SupabasePartnerService.instance.getProfile();
    
    if (mounted && profile != null) {
      setState(() {
        if (profile['opening_time'] != null) {
          _openTime = _parseTime(profile['opening_time']);
        }
        if (profile['closing_time'] != null) {
          _closeTime = _parseTime(profile['closing_time']);
        }
        _prepTimeMinutes = (profile['prep_time_minutes'] as num?)?.toInt() ?? 15;
        _loading = false;
      });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeForDb(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(bool isOpenTime) async {
    final initial = isOpenTime ? _openTime : _closeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: cravnPrimary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _loading = true);
    
    final updates = {
      'opening_time': _formatTimeForDb(_openTime),
      'closing_time': _formatTimeForDb(_closeTime),
      'prep_time_minutes': _prepTimeMinutes,
    };

    final success = await SupabasePartnerService.instance.updateProfile(updates);

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Settings saved successfully' : 'Failed to save settings'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        title: const Text('Kitchen Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Operating Hours'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.s16),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Opening Time'),
                            trailing: Text(
                              _openTime.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cravnPrimary,
                              ),
                            ),
                            onTap: () => _selectTime(true),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Closing Time'),
                            trailing: Text(
                              _closeTime.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cravnPrimary,
                              ),
                            ),
                            onTap: () => _selectTime(false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.s24),

                  _SectionHeader(title: 'Preparation Time'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Average time to prepare an order',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: Dimensions.s16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_prepTimeMinutes mins',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (_prepTimeMinutes > 5) {
                                        setState(() => _prepTimeMinutes -= 5);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      if (_prepTimeMinutes < 120) {
                                        setState(() => _prepTimeMinutes += 5);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.s32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cravnPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.s12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
      ),
    );
  }
}
