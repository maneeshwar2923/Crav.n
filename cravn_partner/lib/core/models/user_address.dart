class UserAddress {
  const UserAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  factory UserAddress.fromMap(Map<String, dynamic> map) {
    return UserAddress(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Address',
      addressLine1:
          map['address_line1']?.toString() ?? map['addressLine1'] ?? '',
      addressLine2: map['address_line2']?.toString() ?? map['addressLine2'],
      city: map['city']?.toString() ?? map['city_name'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['is_default'] == true || map['isDefault'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.isEmpty ? null : id,
      'label': label,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    }..removeWhere((key, value) => value == null);
  }

  UserAddress copyWith({
    String? id,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? city,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
