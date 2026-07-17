import 'package:cloud_firestore/cloud_firestore.dart';

enum ReferralStatus { pending, completed, cancelled }

class ReferralModel {
  final String id;
  final String referrerId;
  final String refereeId;
  final String referralCode;
  final double rewardAmount;
  final double refereeRewardAmount;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String refereeEmail;
  final int referralCount;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.refereeId,
    required this.referralCode,
    required this.rewardAmount,
    required this.refereeRewardAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.refereeEmail,
    required this.referralCount,
  });

  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralModel(
      id: doc.id,
      referrerId: data['referrerId'] ?? '',
      refereeId: data['refereeId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      rewardAmount: (data['rewardAmount'] ?? 0).toDouble(),
      refereeRewardAmount: (data['refereeRewardAmount'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      refereeEmail: data['refereeEmail'] ?? '',
      referralCount: data['referralCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrerId': referrerId,
      'refereeId': refereeId,
      'referralCode': referralCode,
      'rewardAmount': rewardAmount,
      'refereeRewardAmount': refereeRewardAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'refereeEmail': refereeEmail,
      'referralCount': referralCount,
    };
  }

  ReferralModel copyWith({
    String? id,
    String? referrerId,
    String? refereeId,
    String? referralCode,
    double? rewardAmount,
    double? refereeRewardAmount,
    ReferralStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? refereeEmail,
    int? referralCount,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      refereeId: refereeId ?? this.refereeId,
      referralCode: referralCode ?? this.referralCode,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      refereeRewardAmount: refereeRewardAmount ?? this.refereeRewardAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refereeEmail: refereeEmail ?? this.refereeEmail,
      referralCount: referralCount ?? this.referralCount,
    );
  }

  @override
  String toString() =>
      'ReferralModel(referrerId: $referrerId, refereeId: $refereeId, status: ${status.name})';
}

ReferralStatus _parseStatus(dynamic value) {
  if (value == null) return ReferralStatus.pending;
  if (value is ReferralStatus) return value;
  try {
    return ReferralStatus.values.firstWhere(
      (e) => e.name == value.toString().toLowerCase(),
    );
  } catch (_) {
    return ReferralStatus.pending;
  }
}

class ReferralSummary {
  final int totalReferrals;
  final int completedReferrals;
  final double totalEarnings;
  final List<ReferralModel> recentReferrals;

  ReferralSummary({
    required this.totalReferrals,
    required this.completedReferrals,
    required this.totalEarnings,
    required this.recentReferrals,
  });

  factory ReferralSummary.empty() {
    return ReferralSummary(
      totalReferrals: 0,
      completedReferrals: 0,
      totalEarnings: 0,
      recentReferrals: [],
    );
  }
}
