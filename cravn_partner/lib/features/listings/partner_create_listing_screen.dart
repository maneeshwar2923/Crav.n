import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/supabase_partner_service.dart';
import '../profile/presentation/screens/add_edit_address_screen.dart';

class PartnerCreateListingScreen extends StatefulWidget {
  const PartnerCreateListingScreen({super.key, this.listing});

  final Map<String, dynamic>? listing;

  @override
  State<PartnerCreateListingScreen> createState() => _PartnerCreateListingScreenState();
}

class _PartnerCreateListingScreenState extends State<PartnerCreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _weightController = TextEditingController();
  
  // State
  bool _isFree = false;
  bool _isVeg = true;
  bool _loading = false;
  TimeOfDay _pickupTime = const TimeOfDay(hour: 20, minute: 0); // Default 8 PM
  File? _imageFile;
  String? _existingImageUrl;
  
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    if (widget.listing != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final l = widget.listing!;
    _titleController.text = l['title'] ?? '';
    _descriptionController.text = l['description'] ?? '';
    _priceController.text = (l['price']?.toString() ?? '0');
    _quantityController.text = (l['portions_available']?.toString() ?? '0');
    _weightController.text = (l['weight_grams']?.toString() ?? '0');
    _isVeg = l['isveg'] == true;
    _isFree = (l['price'] as num?) == 0;
    
    // Support legacy single image or new multi-images
    if (l['images'] != null && (l['images'] as List).isNotEmpty) {
      _existingImages = List<String>.from(l['images']);
    } else if (l['image'] != null) {
      _existingImages = [l['image']];
    }
    
    _selectedAddressId = l['address_id'];
    
    if (l['pickup_end'] != null) {
      final end = DateTime.tryParse(l['pickup_end']);
      if (end != null) {
        _pickupTime = TimeOfDay.fromDateTime(end);
      }
    }
  }

  Future<void> _loadAddresses() async {
    final addresses = await SupabasePartnerService.instance.getUserAddresses();
    if (mounted) {
      setState(() {
        _addresses = addresses;
        if (_selectedAddressId == null && addresses.isNotEmpty) {
          _selectedAddressId = addresses.first['id'] as String?;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  final List<File> _selectedImages = [];
  List<String> _existingImages = [];

  Future<void> _pickImages(ImageSource source) async {
    try {
      final picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final pickedFiles = await picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedFiles.map((e) => File(e.path)));
          });
        }
      } else {
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          setState(() {
            _selectedImages.add(File(pickedFile.path));
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick images')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      return GestureDetector(
        onTap: _showImagePickerOptions,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text('Add Photos (Required)', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
              const Text('Add multiple angles for verification', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing Images from Edit
              ..._existingImages.map((url) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, width: 120, height: 120, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _existingImages.remove(url)),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 16)),
                      ),
                    ),
                  ],
                ),
              )),
              // Newly Selected Images
              ..._selectedImages.map((file) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImages.remove(file)),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 16)),
                      ),
                    ),
                  ],
                ),
              )),
              // Add More Button
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: cravnPrimary,
              onPrimary: Colors.white,
              onSurface: cravnSecondary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _pickupTime) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup address')),
      );
      return;
    }

    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Upload New Images
      List<String> finalImageUrls = [..._existingImages];
      if (_selectedImages.isNotEmpty) {
        final uploadedUrls = await SupabasePartnerService.instance.uploadListingImages(
          files: _selectedImages,
        );
        finalImageUrls.addAll(uploadedUrls);
      }

      if (finalImageUrls.isEmpty) throw Exception('No images available for listing');

      // 2. Prepare Listing Data
      final selectedAddress = _addresses.firstWhere((a) => a['id'] == _selectedAddressId);
      final now = DateTime.now();
      final pickupDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _pickupTime.hour,
        _pickupTime.minute,
      );

      final listingData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _isFree ? 0.0 : double.parse(_priceController.text.trim()),
        'portions_available': int.parse(_quantityController.text.trim()),
        'weight_grams': double.tryParse(_weightController.text.trim()) ?? 0,
        'pickup_start': now.toIso8601String(),
        'pickup_end': pickupDateTime.toIso8601String(),
        'isveg': _isVeg,
        'address_id': _selectedAddressId,
        'lat': selectedAddress['lat'] ?? 0.0,
        'lng': selectedAddress['lng'] ?? 0.0,
        'status': 'active', // Reset to active, but verification might be needed
        'image': finalImageUrls.first, // Primary thumbnail
        'images': finalImageUrls, // Array of images
      };

      if (widget.listing != null) {
        // Update
        listingData['id'] = widget.listing!['id'];
        await SupabasePartnerService.instance.updateFoodListing(listingData);
      } else {
        // Create
        await SupabasePartnerService.instance.createFoodListing(listingData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.listing != null ? 'Listing updated!' : 'Listing published!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Saving Listing'),
            content: SingleChildScrollView(
              child: SelectableText(e.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'New Listing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              color: cravnBackground, // Green background
              child: ListView(
                padding: const EdgeInsets.all(Dimensions.s16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.s16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker
                          _buildImageGrid(),
                          const SizedBox(height: Dimensions.s24),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Listing Title',
                              hintText: 'e.g., Surplus Biryani Pack',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Dimensions.s16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Describe the meal contents...',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Dimensions.s24),

                          // Price & Free Toggle
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  enabled: !_isFree,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price (₹)',
                                    prefixText: '₹ ',
                                    hintText: '0.00',
                                    filled: !_isFree,
                                    fillColor: _isFree ? Colors.grey[100] : cravnSurface,
                                  ),
                                  validator: (value) {
                                    if (!_isFree && (value == null || value.isEmpty)) {
                                      return 'Please enter a price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: Dimensions.s16),
                              Column(
                                children: [
                                  const Text('Free?', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Switch(
                                    value: _isFree,
                                    activeColor: cravnPrimary,
                                    onChanged: (value) {
                                      setState(() {
                                        _isFree = value;
                                        if (_isFree) {
                                          _priceController.clear();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.s16),

                          // Veg Toggle
                          Row(
                            children: [
                              const Icon(Icons.eco, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Vegetarian?', style: TextStyle(fontSize: 16)),
                              const Spacer(),
                              Switch(
                                value: _isVeg,
                                activeColor: Colors.green,
                                onChanged: (value) => setState(() => _isVeg = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.s16),

                          // Quantity
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                    hintText: 'e.g., 5',
                                    suffixText: 'portions',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: Dimensions.s16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Weight (per portion)',
                                    hintText: 'e.g., 500',
                                    suffixText: 'g',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.s24),

                          // Pickup Time
                          InkWell(
                            onTap: () => _selectTime(context),
                            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: cravnSecondary),
                                  const SizedBox(width: Dimensions.s12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Pickup Until', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(
                                        _pickupTime.format(context),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.s24),

                          // Address Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Pickup Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                                  ).then((_) => _loadAddresses());
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add New'),
                              ),
                            ],
                          ),
                          if (_addresses.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'No addresses found. You need a pickup address to create a listing.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                                      ).then((_) => _loadAddresses());
                                    },
                                    child: const Text('Add Address Now'),
                                  ),
                                ],
                              ),
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedAddressId,
                              decoration: const InputDecoration(
                                hintText: 'Select Pickup Location',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              items: _addresses.map((addr) {
                                final label = addr['label'] ?? 'Address';
                                final street = addr['address_line1'] ?? '';
                                return DropdownMenuItem(
                                  value: addr['id'] as String,
                                  child: Text(
                                    '$label ($street)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedAddressId = value),
                            ),
                          const SizedBox(height: Dimensions.s32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitListing,
                              child: const Text(
                                'Publish Listing',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
