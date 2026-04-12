import 'package:cloud_firestore/cloud_firestore.dart';

class FlashDealModel {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double originalPrice;
  final double dealPrice;
  final int discountPercentage;
  final int stockLeft;
  final int totalStock;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String? categoryId;

  FlashDealModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.originalPrice,
    required this.dealPrice,
    required this.discountPercentage,
    required this.stockLeft,
    required this.totalStock,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.categoryId,
  });

  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get isLive => isActive && hasStarted && !isExpired;

  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    if (!hasStarted) return startTime.difference(DateTime.now());
    return endTime.difference(DateTime.now());
  }

  double get stockPercentage =>
      stockLeft > 0 ? (stockLeft / totalStock).clamp(0.0, 1.0) : 0.0;

  double get savedAmount => originalPrice - dealPrice;

  factory FlashDealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashDealModel(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      dealPrice: (data['dealPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (data['discountPercentage'] as num?)?.toInt() ?? 0,
      stockLeft: (data['stockLeft'] as num?)?.toInt() ?? 0,
      totalStock: (data['totalStock'] as num?)?.toInt() ?? 1,
      startTime:
          (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 24)),
      isActive: data['isActive'] as bool? ?? true,
      categoryId: data['categoryId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'dealPrice': dealPrice,
      'discountPercentage': discountPercentage,
      'stockLeft': stockLeft,
      'totalStock': totalStock,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isActive': isActive,
      'categoryId': categoryId,
    };
  }

  FlashDealModel copyWith({int? stockLeft, bool? isActive}) {
    return FlashDealModel(
      id: id,
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      originalPrice: originalPrice,
      dealPrice: dealPrice,
      discountPercentage: discountPercentage,
      stockLeft: stockLeft ?? this.stockLeft,
      totalStock: totalStock,
      startTime: startTime,
      endTime: endTime,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId,
    );
  }
}
