import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime addedAt;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.addedAt,
  });

  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  WishlistModel copyWith({
    String? id,
    String? userId,
    String? productId,
    DateTime? addedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() => 'WishlistModel(productId: $productId)';
}
