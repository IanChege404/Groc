import 'package:cloud_firestore/cloud_firestore.dart';

enum WishlistItemType { product, bundle }

class WishlistModel {
  final String id;
  final String userId;
  final String itemId;
  final DateTime addedAt;
  final WishlistItemType? itemType;

  @Deprecated('Use itemId instead')
  String get productId => itemId;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.addedAt,
    this.itemType,
  });

  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawType = (data['itemType'] as String?)?.toLowerCase();

    return WishlistModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? data['productId'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      itemType: rawType == 'bundle'
          ? WishlistItemType.bundle
          : rawType == 'product'
          ? WishlistItemType.product
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'productId': itemId,
      'addedAt': Timestamp.fromDate(addedAt),
      if (itemType != null) 'itemType': itemType!.name,
    };
  }

  WishlistModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    @Deprecated('Use itemId instead') String? productId,
    DateTime? addedAt,
    WishlistItemType? itemType,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? productId ?? this.itemId,
      addedAt: addedAt ?? this.addedAt,
      itemType: itemType ?? this.itemType,
    );
  }

  @override
  String toString() => 'WishlistModel(itemId: $itemId, itemType: $itemType)';
}
