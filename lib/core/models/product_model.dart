import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double mainPrice;
  final double? discountPrice;
  final int stock;
  final String image;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String weight;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.mainPrice,
    this.discountPrice,
    required this.stock,
    required this.image,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.weight,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document to ProductModel
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      mainPrice: (data['mainPrice'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null
          ? (data['discountPrice']).toDouble()
          : null,
      stock: data['stock'] ?? 0,
      image: data['image'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      weight: data['weight'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert ProductModel to Firestore JSON
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'mainPrice': mainPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'image': image,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'weight': weight,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert to map (for UI)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'mainPrice': mainPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'image': image,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'weight': weight,
      'cover': image, // For backward compatibility
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    double? mainPrice,
    double? discountPrice,
    int? stock,
    String? image,
    List<String>? images,
    double? rating,
    int? reviewCount,
    String? weight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      mainPrice: mainPrice ?? this.mainPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';
}
