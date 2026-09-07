import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String label;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;
  final String userId;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.label,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    this.zipCode = '',
    required this.isDefault,
    required this.userId,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressModel(
      id: doc.id,
      label: data['label'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      line1: data['line1'] as String? ?? '',
      line2: data['line2'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      zipCode: data['zipCode'] as String? ?? '',
      isDefault: data['isDefault'] == true,
      userId: data['userId'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
      'userId': userId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? phone,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress {
    final parts = [line1, line2, city, state, zipCode]
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get displayName => label.isNotEmpty ? label : 'Address';

  bool get hasLocation => latitude != null && longitude != null;
}
