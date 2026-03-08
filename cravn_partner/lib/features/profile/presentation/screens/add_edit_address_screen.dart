import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/supabase_partner_service.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

// API Key from AndroidManifest.xml
const String _kGoogleMapsApiKey = 'AIzaSyCbuhvl0cecgpfRjn-h4ArSVxDkWIbidaA';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key, this.address});

  final Map<String, dynamic>? address;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  
  bool _isDefault = false;
  bool _loading = false;
  
  // Maps & Location
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default to India center
  final _places = GoogleMapsPlaces(apiKey: _kGoogleMapsApiKey);
  Timer? _debounce;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry',
  ];

  Future<void> _loadMapStyle() async {
    try {
      // Using a dark/green theme style directly here to ensure it works without asset file
      const style = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
      ''';
      _mapController?.setMapStyle(style);
    } catch (e) {
      debugPrint('Failed to load map style: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!['label'] ?? '';
      _line1Controller.text = widget.address!['address_line1'] ?? widget.address!['street_address'] ?? '';
      _line2Controller.text = widget.address!['address_line2'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _stateController.text = widget.address!['state'] ?? '';
      _zipController.text = widget.address!['zip_code'] ?? '';
      _isDefault = widget.address!['is_default'] == true;
      
      // If we had lat/lng in DB, we would set it here.
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _mapController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      _updateMapLocation(latLng);
      await _reverseGeocode(latLng);
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateMapLocation(LatLng latLng) {
    setState(() {
      _currentPosition = latLng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: latLng,
          draggable: true,
          onDragEnd: (newPos) {
            _updateMapLocation(newPos);
            _reverseGeocode(newPos);
          },
        ),
      );
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    try {
      final geocoding = GoogleMapsGeocoding(apiKey: _kGoogleMapsApiKey);
      final res = await geocoding.searchByLocation(
        Location(lat: latLng.latitude, lng: latLng.longitude),
      );

      if (res.isOkay && res.results.isNotEmpty) {
        final result = res.results.first;
        _fillAddressFromComponents(result.addressComponents);
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
  }

  void _fillAddressFromComponents(List<AddressComponent> components) {
    String street = '';
    String city = '';
    String state = '';
    String zip = '';

    for (var component in components) {
      final types = component.types;
      if (types.contains('street_number')) {
        street = '${component.longName} $street';
      }
      if (types.contains('route')) {
        street += component.longName;
      }
      if (types.contains('locality')) {
        city = component.longName;
      } else if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = component.longName;
      }
      if (types.contains('administrative_area_level_1')) {
        state = component.longName;
      }
      if (types.contains('postal_code')) {
        zip = component.longName;
      }
    }

    setState(() {
      _line1Controller.text = street.trim();
      _cityController.text = city;
      if (_indianStates.contains(state)) {
        _stateController.text = state;
      } else {
        _stateController.text = _indianStates.firstWhere(
            (s) => s.toLowerCase() == state.toLowerCase(),
            orElse: () => '');
      }
      _zipController.text = zip;
    });
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final payload = {
      // 'label': _labelController.text.trim(), // Column missing in DB
      'address_line1': _line1Controller.text.trim(),
      'address_line2': _line2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zip_code': _zipController.text.trim(),
      'is_default': _isDefault,
      'lat': _currentPosition.latitude,
      'lng': _currentPosition.longitude,
    };

    if (widget.address != null) {
      payload['id'] = widget.address!['id'];
    }

    try {
      final result = await SupabasePartnerService.instance.upsertAddress(payload);

      if (mounted) {
        setState(() => _loading = false);
        if (result != null) {
          if (_isDefault && result['id'] != null) {
            await SupabasePartnerService.instance.markDefaultAddress(result['id']);
          }
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Saving Address'),
            content: SingleChildScrollView(
              child: SelectableText(e.toString()), // SelectableText for easier copying
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(Dimensions.s16),
            children: [
              // Map Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _loadMapStyle();
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onTap: (pos) {
                      _updateMapLocation(pos);
                      _reverseGeocode(pos);
                    },
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.s16),

              // Use Current Location Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current Location'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.s12),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: cravnPrimary),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.s24),

              // Address Form Container
              Container(
                padding: const EdgeInsets.all(Dimensions.s16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // TextFormField(
                      //   controller: _labelController,
                      //   decoration: const InputDecoration(
                      //     labelText: 'Label',
                      //     hintText: 'e.g., Home, Work',
                      //     prefixIcon: Icon(Icons.label_outline),
                      //   ),
                      //   validator: (value) =>
                      //       value?.isEmpty == true ? 'Please enter a label' : null,
                      // ),
                      // const SizedBox(height: Dimensions.s16),
                      
                      // Autocomplete for Address Line 1
                      Autocomplete<Prediction>(
                        displayStringForOption: (Prediction option) => option.description ?? '',
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Prediction>.empty();
                          }
                          final res = await _places.autocomplete(
                            textEditingValue.text,
                            components: [Component(Component.country, "in")],
                          );
                          if (res.isOkay) {
                            return res.predictions;
                          }
                          return const Iterable<Prediction>.empty();
                        },
                        onSelected: (Prediction selection) async {
                          final details = await _places.getDetailsByPlaceId(selection.placeId!);
                          if (details.isOkay && details.result.geometry != null) {
                            final location = details.result.geometry!.location;
                            final latLng = LatLng(location.lat, location.lng);
                            _updateMapLocation(latLng);
                            _fillAddressFromComponents(details.result.addressComponents);
                          }
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          if (controller.text != _line1Controller.text && _line1Controller.text.isNotEmpty) {
                               if (controller.text.isEmpty) controller.text = _line1Controller.text;
                          }
                          controller.addListener(() {
                            _line1Controller.text = controller.text;
                          });

                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Address Line 1',
                              hintText: 'Start typing to search...',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (value) =>
                                value?.isEmpty == true ? 'Please enter an address' : null,
                          );
                        },
                      ),
                      
                      const SizedBox(height: Dimensions.s16),
                      TextFormField(
                        controller: _line2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address Line 2 (Optional)',
                          hintText: 'Apt, Suite, etc.',
                          prefixIcon: Icon(Icons.apartment),
                        ),
                      ),
                      const SizedBox(height: Dimensions.s16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(labelText: 'City'),
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: Dimensions.s16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _indianStates.contains(_stateController.text) 
                                  ? _stateController.text 
                                  : null,
                              decoration: const InputDecoration(labelText: 'State'),
                              items: _indianStates.map((String state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(state, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _stateController.text = newValue ?? '';
                                });
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.s16),
                      TextFormField(
                        controller: _zipController,
                        decoration: const InputDecoration(labelText: 'Zip Code'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: Dimensions.s24),
                      SwitchListTile(
                        title: const Text('Set as Default Address'),
                        value: _isDefault,
                        activeColor: cravnPrimary,
                        onChanged: (value) => setState(() => _isDefault = value),
                      ),
                      const SizedBox(height: Dimensions.s32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cravnPrimary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isEditing ? 'Update Address' : 'Save Address'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
