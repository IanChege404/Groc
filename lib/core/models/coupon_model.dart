import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final String title;
  final double discount;
  final String discountType; // percentage, fixed
  final DateTime expireDate;
  final bool isUsed;
  final List<String> applicableCategories;
  final String? description;
  final int? minPurchaseAmount;
  final int? maxDiscount;
  final String? imageUrl;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discount,
    this.discountType = 'percentage',
    required this.expireDate,
    this.isUsed = false,
    this.applicableCategories = const [],
    this.description,
    this.minPurchaseAmount,
    this.maxDiscount,
    this.imageUrl,
  });

  /// Check if coupon is expired
  bool get isExpired => DateTime.now().isAfter(expireDate);

  /// Check if coupon can be used
  bool get canBeUsed => !isUsed && !isExpired;

  /// Factory constructor from Firestore document
  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      title: data['title'] as String? ?? '',
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: data['discountType'] as String? ?? 'percentage',
      expireDate:
          (data['expireDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUsed: data['isUsed'] as bool? ?? false,
      applicableCategories: List<String>.from(
        data['applicableCategories'] as List? ?? [],
      ),
      description: data['description'] as String?,
      minPurchaseAmount: data['minPurchaseAmount'] as int?,
      maxDiscount: data['maxDiscount'] as int?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'title': title,
      'discount': discount,
      'discountType': discountType,
      'expireDate': Timestamp.fromDate(expireDate),
      'isUsed': isUsed,
      'applicableCategories': applicableCategories,
      'description': description,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscount': maxDiscount,
      'imageUrl': imageUrl,
    };
  }

  /// Create a copy with modifications
  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    double? discount,
    String? discountType,
    DateTime? expireDate,
    bool? isUsed,
    List<String>? applicableCategories,
    String? description,
    int? minPurchaseAmount,
    int? maxDiscount,
    String? imageUrl,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      expireDate: expireDate ?? this.expireDate,
      isUsed: isUsed ?? this.isUsed,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      description: description ?? this.description,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
