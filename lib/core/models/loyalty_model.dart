import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/payment_constants.dart';

class LoyaltyModel {
  final String id;
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int redeemedPoints;
  final int tier; // 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  final List<LoyaltyTransaction> transactions;
  final DateTime updatedAt;

  LoyaltyModel({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.redeemedPoints,
    required this.tier,
    this.transactions = const [],
    required this.updatedAt,
  });

  String get tierName {
    final idx = (tier - 1).clamp(0, PaymentConstants.loyaltyTierNames.length - 1);
    return PaymentConstants.loyaltyTierNames[idx];
  }

  /// Points needed for next tier
  int get pointsToNextTier {
    if (tier >= PaymentConstants.loyaltyTierThresholds.length) return 0;
    return PaymentConstants.loyaltyTierThresholds[tier] - totalPoints;
  }

  /// Monetary value of available points (100 points = KES 1)
  double get cashValue => availablePoints / 100.0;

  factory LoyaltyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      availablePoints: (data['availablePoints'] as num?)?.toInt() ?? 0,
      redeemedPoints: (data['redeemedPoints'] as num?)?.toInt() ?? 0,
      tier: (data['tier'] as num?)?.toInt() ?? 1,
      transactions: ((data['transactions'] as List?) ?? [])
          .map((e) => LoyaltyTransaction.fromMap(e as Map<String, dynamic>))
          .toList(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'redeemedPoints': redeemedPoints,
      'tier': tier,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LoyaltyModel copyWith({
    int? totalPoints,
    int? availablePoints,
    int? redeemedPoints,
    int? tier,
    List<LoyaltyTransaction>? transactions,
  }) {
    return LoyaltyModel(
      id: id,
      userId: userId,
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      redeemedPoints: redeemedPoints ?? this.redeemedPoints,
      tier: tier ?? this.tier,
      transactions: transactions ?? this.transactions,
      updatedAt: DateTime.now(),
    );
  }
}

class LoyaltyTransaction {
  final String id;
  final int points;
  final String type; // earn, redeem, expire, bonus
  final String description;
  final String? orderId;
  final DateTime timestamp;

  LoyaltyTransaction({
    required this.id,
    required this.points,
    required this.type,
    required this.description,
    this.orderId,
    required this.timestamp,
  });

  bool get isEarning => type == 'earn' || type == 'bonus';

  factory LoyaltyTransaction.fromMap(Map<String, dynamic> data) {
    return LoyaltyTransaction(
      id: data['id'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'earn',
      description: data['description'] as String? ?? '',
      orderId: data['orderId'] as String?,
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'type': type,
      'description': description,
      'orderId': orderId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
