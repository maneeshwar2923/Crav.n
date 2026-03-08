import 'package:flutter/material.dart';

import '../../../../core/extensions/iterable_extensions.dart';
import '../../../../core/models/user_address.dart';
import '../../../../core/services/supabase_service.dart';

/// Bottom sheet used to view, add, edit and select saved addresses.
class AddressManagerSheet extends StatefulWidget {
  final UserAddress? initialSelection;

  const AddressManagerSheet({super.key, this.initialSelection});

  static Future<UserAddress?> pick(BuildContext context,
      {UserAddress? initialSelection}) {
    return showModalBottomSheet<UserAddress>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.4,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) => AddressManagerSheet(
          initialSelection: initialSelection,
        ),
      ),
    );
  }

  @override
  State<AddressManagerSheet> createState() => _AddressManagerSheetState();
}

class _AddressManagerSheetState extends State<AddressManagerSheet> {
  late final SupabaseService _service;
  final List<UserAddress> _addresses = [];
  bool _loading = true;
  bool _mutating = false;
  UserAddress? _selected;

  @override
  void initState() {
    super.initState();
    _service = SupabaseService.instance;
    _selected = widget.initialSelection;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _service.getUserAddresses();
    final mapped = rows.map(UserAddress.fromMap).toList();
    setState(() {
      _addresses
        ..clear()
        ..addAll(mapped);
      _loading = false;
      if (_selected != null) {
        final match = _addresses
            .where((element) => element.id == _selected!.id)
            .firstOrNull;
        _selected = match;
      }
    });
  }

  Future<void> _saveAddress(UserAddress address) async {
    setState(() => _mutating = true);
    final response = await _service.upsertAddress(address.toMap());
    if (!mounted) return;
    setState(() => _mutating = false);
    if (response != null) {
      final saved = UserAddress.fromMap(response);
      final existingIndex =
          _addresses.indexWhere((element) => element.id == saved.id);
      setState(() {
        if (existingIndex >= 0) {
          _addresses[existingIndex] = saved;
        } else {
          _addresses.insert(0, saved);
        }
        _selected = saved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(existingIndex >= 0 ? 'Address updated' : 'Address saved'),
        ),
      );
    }
  }

  Future<void> _removeAddress(UserAddress address) async {
    setState(() => _mutating = true);
    final success = await _service.deleteAddress(address.id);
    if (!mounted) return;
    setState(() => _mutating = false);
    if (success) {
      setState(() {
        _addresses.removeWhere((element) => element.id == address.id);
        if (_selected?.id == address.id) {
          _selected = _addresses.firstOrNull;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address removed')),
      );
    }
  }

  Future<void> _setDefault(UserAddress address) async {
    setState(() => _mutating = true);
    final success = await _service.markDefaultAddress(address.id);
    if (!mounted) return;
    setState(() => _mutating = false);
    if (success) {
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default address updated')),
      );
    }
  }

  Future<void> _openAddressForm({UserAddress? seed}) async {
    final result = await showDialog<UserAddress>(
      context: context,
      builder: (context) => _AddressFormDialog(seed: seed),
    );
    if (result != null) {
      await _saveAddress(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saved addresses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _mutating ? null : () => _openAddressForm(),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add new'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_addresses.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_work_outlined,
                        size: 48, color: Color(0xFF94B0A8)),
                    const SizedBox(height: 8),
                    const Text('No addresses yet. Add one to reuse later.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _mutating ? null : () => _openAddressForm(),
                      child: const Text('Add address'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  final selected = _selected?.id == address.id;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF006D3B)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => Navigator.of(context).pop(address),
                      leading: Icon(
                        address.isDefault
                            ? Icons.home_rounded
                            : Icons.location_on_outlined,
                        color: address.isDefault
                            ? const Color(0xFF006D3B)
                            : const Color(0xFF6A7A76),
                      ),
                      title: Text('${address.label}'),
                      subtitle: Text(
                        [
                          address.addressLine1,
                          address.addressLine2,
                          address.city,
                        ]
                            .where((element) => (element ?? '').isNotEmpty)
                            .join(', '),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'default':
                              _setDefault(address);
                              break;
                            case 'edit':
                              _openAddressForm(seed: address);
                              break;
                            case 'delete':
                              _removeAddress(address);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (!address.isDefault)
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Set as default'),
                            ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_selected != null)
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Use ${_selected!.label}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressFormDialog extends StatefulWidget {
  final UserAddress? seed;

  const _AddressFormDialog({this.seed});

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    final seed = widget.seed;
    _labelController = TextEditingController(text: seed?.label ?? 'Home');
    _line1Controller = TextEditingController(text: seed?.addressLine1 ?? '');
    _line2Controller = TextEditingController(text: seed?.addressLine2 ?? '');
    _cityController = TextEditingController(text: seed?.city ?? '');
    _latitudeController = TextEditingController(
        text: seed?.latitude != null ? seed!.latitude!.toStringAsFixed(6) : '');
    _longitudeController = TextEditingController(
        text:
            seed?.longitude != null ? seed!.longitude!.toStringAsFixed(6) : '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.seed == null ? 'Add address' : 'Edit address'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label'),
                validator: (value) => value != null && value.trim().isNotEmpty
                    ? null
                    : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _line1Controller,
                decoration: const InputDecoration(labelText: 'Address line 1'),
                validator: (value) => value != null && value.trim().isNotEmpty
                    ? null
                    : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _line2Controller,
                decoration: const InputDecoration(labelText: 'Address line 2'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City / Area'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Latitude (optional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Longitude (optional)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final latitude = double.tryParse(_latitudeController.text.trim());
            final longitude = double.tryParse(_longitudeController.text.trim());
            Navigator.of(context).pop(
              UserAddress(
                id: widget.seed?.id ?? '',
                label: _labelController.text.trim(),
                addressLine1: _line1Controller.text.trim(),
                addressLine2: _line2Controller.text.trim().isEmpty
                    ? null
                    : _line2Controller.text.trim(),
                city: _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
                latitude: latitude,
                longitude: longitude,
                isDefault: widget.seed?.isDefault ?? false,
              ),
            );
          },
          child: Text(widget.seed == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
