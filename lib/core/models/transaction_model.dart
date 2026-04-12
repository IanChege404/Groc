import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // debit, credit
  final double amount;
  final String
  category; // purchase, cashback, bonus, topup, withdrawal, transfer
  final DateTime timestamp;
  final String description;
  final String? relatedOrderId;
  final String? relatedCouponId;
  final String? reference;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.description,
    this.relatedOrderId,
    this.relatedCouponId,
    this.reference,
  });

  /// Factory constructor from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      type: data['type'] as String? ?? 'debit',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'purchase',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] as String? ?? '',
      relatedOrderId: data['relatedOrderId'] as String?,
      relatedCouponId: data['relatedCouponId'] as String?,
      reference: data['reference'] as String?,
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'relatedOrderId': relatedOrderId,
      'relatedCouponId': relatedCouponId,
      'reference': reference,
    };
  }

  /// Create a copy with modifications
  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    DateTime? timestamp,
    String? description,
    String? relatedOrderId,
    String? relatedCouponId,
    String? reference,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedCouponId: relatedCouponId ?? this.relatedCouponId,
      reference: reference ?? this.reference,
    );
  }
}
