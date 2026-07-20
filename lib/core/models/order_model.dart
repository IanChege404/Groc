import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // pending, completed, cancelled, refunded
  final String paymentMethod; // mpesa, card, wallet
  final String? shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt; // Soft delete: null = active, set = archived
  final String? deletionReason; // why order was deleted (refund, user request, etc)

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletionReason,
  });

  bool get isDeleted => deletedAt != null;
  bool get isActive => deletedAt == null;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsList = (data['items'] as List?)
            ?.map((item) => OrderItemModel.fromMap(item))
            .toList() ??
        [];

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: itemsList,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      shippingAddress: data['shippingAddress'],
      trackingNumber: data['trackingNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletionReason: data['deletionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      if (deletionReason != null) 'deletionReason': deletionReason,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    String? paymentMethod,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletionReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletionReason: deletionReason ?? this.deletionReason,
    );
  }

  @override
  String toString() =>
      'OrderModel(id: $id, status: $status, totalAmount: $totalAmount)';
}

class OrderItemModel {
  final String productId;
  final int quantity;
  final double priceAtTimeOfOrder;
  final String productName;
  final String image;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.priceAtTimeOfOrder,
    required this.productName,
    required this.image,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 1,
      priceAtTimeOfOrder: (data['priceAtTimeOfOrder'] ?? 0).toDouble(),
      productName: data['productName'] ?? '',
      image: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'priceAtTimeOfOrder': priceAtTimeOfOrder,
      'productName': productName,
      'image': image,
    };
  }
}
