import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_service.dart';
import 'add_edit_address_screen.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loading = true);
    final addresses = await SupabaseService.instance.getUserAddresses();
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _loading = false;
      });
    }
  }

  Future<void> _deleteAddress(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService.instance.deleteAddress(id);
      _loadAddresses();
    }
  }

  Future<void> _setDefault(String id) async {
    await SupabaseService.instance.markDefaultAddress(id);
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No addresses found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.s16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isDefault = address['is_default'] == true;
                    final label = address['label'] ?? 'Address';
                    final street = address['address_line1'] ?? address['street_address'] ?? '';
                    final city = address['city'] ?? '';
                    
                    // Note: User App schema might differ slightly (address_line1 vs street_address)
                    // Based on UserAddress model: address_line1
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: Dimensions.s12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                        side: isDefault
                            ? const BorderSide(color: Color(0xFF006D3B), width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: Icon(
                          isDefault ? Icons.star : Icons.location_on_outlined,
                          color: isDefault ? const Color(0xFF006D3B) : Colors.grey,
                        ),
                        title: Row(
                          children: [
                            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006D3B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF006D3B), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('$street\n$city'),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as Default'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'default') _setDefault(address['id']);
                            if (value == 'delete') _deleteAddress(address['id']);
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditAddressScreen(address: address),
                                ),
                              ).then((_) => _loadAddresses());
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
          ).then((_) => _loadAddresses());
        },
        backgroundColor: const Color(0xFF006D3B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
