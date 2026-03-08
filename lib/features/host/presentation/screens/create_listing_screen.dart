import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/extensions/iterable_extensions.dart';
import '../../../../core/models/user_address.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../home/presentation/widgets/address_manager_sheet.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _imageUrlController = TextEditingController();
  File? _pickedImage;
  final _priceController = TextEditingController();
  bool _isVeg = true;
  bool _loading = false;
  String? _error;
  bool _addressesLoading = false;
  UserAddress? _selectedAddress;

  @override
  void dispose() {
    _titleController.dispose();
    _cuisineController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _addressesLoading = true);
    final rows = await SupabaseService.instance.getUserAddresses();
    final parsed = rows.map(UserAddress.fromMap).toList();
    final defaultAddress =
        parsed.where((element) => element.isDefault).firstOrNull;
    setState(() {
      _addressesLoading = false;
      _selectedAddress =
          defaultAddress ?? (parsed.isEmpty ? null : parsed.first);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    String? imageUrl = _imageUrlController.text.trim().isEmpty
        ? null
        : _imageUrlController.text.trim();
    if (_pickedImage != null) {
      final uploaded = await SupabaseService.instance
          .uploadListingImage(file: _pickedImage!);
      imageUrl = uploaded ?? imageUrl;
    }
    // Get current position for geotagging
    double? lat;
    double? lng;
    try {
      if (_selectedAddress?.latitude != null &&
          _selectedAddress?.longitude != null) {
        lat = _selectedAddress!.latitude;
        lng = _selectedAddress!.longitude;
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final p = await Geolocator.getCurrentPosition();
          lat = p.latitude;
          lng = p.longitude;
        }
      }
    } catch (_) {}

    final listing = {
      'title': _titleController.text.trim(),
      'cuisine': _cuisineController.text.trim(),
      'image': imageUrl,
      'price': int.tryParse(_priceController.text.trim()) ?? 0,
      'isVeg': _isVeg,
      'owner_id': SupabaseService.instance.currentUser?.id,
      'lat': lat,
      'lng': lng,
      'address_id':
          _selectedAddress?.id.isEmpty == true ? null : _selectedAddress?.id,
      'status': 'pending',
      // Optional: add 'description' if you add a field in the UI and schema
    }..removeWhere((key, value) => value == null);
    try {
      final inserted =
          await SupabaseService.instance.createFoodListing(listing);
      if (!mounted) return;
      if (inserted != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing submitted for verification.')),
        );
        Navigator.of(context).pop(inserted);
      } else {
        setState(() => _error = 'Failed to create listing');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create listing')),
        );
      }
    } on AuthException catch (e) {
      final message = e.message;
      setState(() => _error = message);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } on PostgrestException catch (e) {
      final message = e.message;
      setState(() => _error = message);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      final message = resolveDisplayError(e);
      setState(() => _error = message);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    // Request permission if needed
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_outlined,
                        color: Color(0xFFD35400), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'New listings appear as pending while our team verifies details. '
                        'You\'ll receive an email once the listing is marked verified.',
                        style: TextStyle(color: Color(0xFF6A4C1B)),
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cuisineController,
                decoration: const InputDecoration(labelText: 'Cuisine'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _loading
                        ? null
                        : () async {
                            final status = await Permission.photos.request();
                            if (!status.isGranted) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Gallery permission denied')),
                                );
                              }
                              return;
                            }
                            final picker = ImagePicker();
                            final XFile? file = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1600,
                              imageQuality: 85,
                            );
                            if (file != null) {
                              setState(() {
                                _pickedImage = File(file.path);
                              });
                            }
                          },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 12),
                  if (_pickedImage != null)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _pickedImage!,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Price (₹, 0 for free)'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Vegetarian'),
                value: _isVeg,
                onChanged: (v) => setState(() => _isVeg = v),
              ),
              const SizedBox(height: 8),
              _addressesLoading
                  ? const LinearProgressIndicator(minHeight: 2)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Pickup location',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final chosen = await AddressManagerSheet.pick(
                                  context,
                                  initialSelection: _selectedAddress,
                                );
                                if (chosen != null) {
                                  setState(() => _selectedAddress = chosen);
                                }
                              },
                              icon: const Icon(Icons.location_on_outlined),
                              label: const Text('Choose saved'),
                            ),
                          ],
                        ),
                        if (_selectedAddress != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F6EE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedAddress!.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text([
                                  _selectedAddress!.addressLine1,
                                  _selectedAddress!.addressLine2,
                                  _selectedAddress!.city
                                ]
                                    .where(
                                        (element) => (element ?? '').isNotEmpty)
                                    .join(', ')),
                                if (_selectedAddress!.latitude != null &&
                                    _selectedAddress!.longitude != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Lat: ${_selectedAddress!.latitude!.toStringAsFixed(5)}, '
                                      'Lng: ${_selectedAddress!.longitude!.toStringAsFixed(5)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5C7470)),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        setState(() => _selectedAddress = null),
                                    child: const Text('Clear'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                              'We will use your current GPS location when you submit.'),
                      ],
                    ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D3B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
