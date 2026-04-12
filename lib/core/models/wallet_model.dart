import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;
  final double totalEarned;
  final double totalSpent;

  WalletModel({
    required this.userId,
    required this.balance,
    this.currency = 'KES',
    required this.lastUpdated,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
  });

  /// Factory constructor from Firestore document
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      userId: data['userId'] as String? ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'KES',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalEarned: (data['totalEarned'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
    };
  }

  /// Create a copy with modifications
  WalletModel copyWith({
    String? userId,
    double? balance,
    String? currency,
    DateTime? lastUpdated,
    double? totalEarned,
    double? totalSpent,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
