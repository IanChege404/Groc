import 'package:cloud_firestore/cloud_firestore.dart';

class BundleModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<String> images;
  final List<String> itemNames;
  final List<String> productIds;
  final double price;
  final double mainPrice;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  BundleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.images,
    required this.itemNames,
    required this.productIds,
    required this.price,
    required this.mainPrice,
    this.discountPrice,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BundleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BundleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      itemNames: List<String>.from(data['itemNames'] ?? []),
      productIds: List<String>.from(data['productIds'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      mainPrice: (data['mainPrice'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null
          ? (data['discountPrice']).toDouble()
          : null,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'images': images,
      'itemNames': itemNames,
      'productIds': productIds,
      'price': price,
      'mainPrice': mainPrice,
      'discountPrice': discountPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'images': images,
      'itemNames': itemNames,
      'productIds': productIds,
      'price': price,
      'mainPrice': mainPrice,
      'discountPrice': discountPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'cover': image, // For backward compatibility
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
