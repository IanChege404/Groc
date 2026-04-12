import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty; // easy, medium, hard
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      servings: (data['servings'] as num?)?.toInt() ?? 2,
      prepTimeMinutes: (data['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (data['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      difficulty: data['difficulty'] as String? ?? 'medium',
      ingredients: ((data['ingredients'] as List?) ?? [])
          .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      instructions: List<String>.from(data['instructions'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'servings': servings,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'difficulty': difficulty,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RecipeModel copyWith({int? servings}) {
    return RecipeModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      difficulty: difficulty,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags,
      rating: rating,
      reviewCount: reviewCount,
      createdAt: createdAt,
    );
  }
}

class RecipeIngredient {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final String? imageUrl;
  final double? price;

  RecipeIngredient({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    this.price,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> data) {
    return RecipeIngredient(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: data['unit'] as String? ?? 'piece',
      imageUrl: data['imageUrl'] as String?,
      price: (data['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'price': price,
    };
  }

  /// Scale quantity by a servings multiplier
  RecipeIngredient scaledBy(double factor) {
    return RecipeIngredient(
      productId: productId,
      productName: productName,
      quantity: quantity * factor,
      unit: unit,
      imageUrl: imageUrl,
      price: price,
    );
  }
}
