import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final double priceAtTimeOfAdd;
  final DateTime addedAt;
  final DateTime updatedAt;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.priceAtTimeOfAdd,
    required this.addedAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 1,
      priceAtTimeOfAdd: (data['priceAtTimeOfAdd'] ?? 0).toDouble(),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'priceAtTimeOfAdd': priceAtTimeOfAdd,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    double? priceAtTimeOfAdd,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      priceAtTimeOfAdd: priceAtTimeOfAdd ?? this.priceAtTimeOfAdd,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CartItemModel(productId: $productId, quantity: $quantity)';
}
