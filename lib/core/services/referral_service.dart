import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/referral_model.dart';
import '../utils/logger.dart';

class ReferralService {
  final _firestore = FirebaseFirestore.instance;
  static const String _referralCollectionName = 'referrals';
  static const String _userCollectionName = 'users';
  static const double defaultRewardAmount = 500.0; // KES or local currency
  static const double defaultRefereeRewardAmount = 200.0;

  /// Generate a unique referral code for a user
  Future<String> generateReferralCode(String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final data = '$userId-$timestamp';
      final hash = sha256.convert(utf8.encode(data)).toString();
      final code = hash.substring(0, 8).toUpperCase();

      return code;
    } catch (e) {
      Logger.error('Error generating referral code: $e', 'ReferralService.generateReferralCode');
      rethrow;
    }
  }

  /// Create a new referral (when someone uses a referral code)
  Future<ReferralModel> createReferral({
    required String referrerId,
    required String refereeId,
    required String referralCode,
    required String refereeEmail,
  }) async {
    try {
      final docRef = _firestore.collection(_referralCollectionName).doc();
      final referral = ReferralModel(
        id: docRef.id,
        referrerId: referrerId,
        refereeId: refereeId,
        referralCode: referralCode,
        rewardAmount: defaultRewardAmount,
        refereeRewardAmount: defaultRefereeRewardAmount,
        status: ReferralStatus.pending,
        createdAt: DateTime.now(),
        refereeEmail: refereeEmail,
        referralCount: 0,
      );

      await docRef.set(referral.toFirestore());

      // Update user's referral code if not already set
      await _updateUserReferralCode(referrerId, referralCode);

      Logger.info(
        'Referral created: $referrerId referred $refereeId',
        'ReferralService.createReferral',
      );

      return referral;
    } catch (e, stack) {
      Logger.error(
        'Error creating referral: $e\nStack: $stack',
        'ReferralService.createReferral',
      );
      rethrow;
    }
  }

  /// Complete a referral (when referee makes their first purchase)
  Future<void> completeReferral(String referralId) async {
    try {
      final referral = await getReferralById(referralId);
      if (referral == null) {
        throw Exception('Referral not found');
      }

      if (referral.status == ReferralStatus.completed) {
        Logger.warning(
          'Referral already completed: $referralId',
          'ReferralService.completeReferral',
        );
        return;
      }

      // Update referral status
      await _firestore
          .collection(_referralCollectionName)
          .doc(referralId)
          .update({
        'status': ReferralStatus.completed.name,
        'completedAt': Timestamp.now(),
      });

      // Add rewards to both users
      await _addRewardToUser(referral.referrerId, referral.rewardAmount);
      await _addRewardToUser(referral.refereeId, referral.refereeRewardAmount);

      // Increment referral count
      await _incrementReferralCount(referral.referrerId);

      Logger.info(
        'Referral completed: $referralId',
        'ReferralService.completeReferral',
      );
    } catch (e, stack) {
      Logger.error(
        'Error completing referral: $e\nStack: $stack',
        'ReferralService.completeReferral',
      );
      rethrow;
    }
  }

  /// Get referral by ID
  Future<ReferralModel?> getReferralById(String referralId) async {
    try {
      final doc = await _firestore
          .collection(_referralCollectionName)
          .doc(referralId)
          .get();

      if (!doc.exists) return null;
      return ReferralModel.fromFirestore(doc);
    } catch (e, stack) {
      Logger.error(
        'Error getting referral: $e\nStack: $stack',
        'ReferralService.getReferralById',
      );
      return null;
    }
  }

  /// Get referral by code
  Future<ReferralModel?> getReferralByCode(String referralCode) async {
    try {
      final snapshot = await _firestore
          .collection(_referralCollectionName)
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ReferralModel.fromFirestore(snapshot.docs.first);
    } catch (e, stack) {
      Logger.error(
        'Error getting referral by code: $e\nStack: $stack',
        'ReferralService.getReferralByCode',
      );
      return null;
    }
  }

  /// Get all referrals made by a user
  Future<List<ReferralModel>> getReferralsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_referralCollectionName)
          .where('referrerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReferralModel.fromFirestore(doc))
          .toList();
    } catch (e, stack) {
      Logger.error(
        'Error getting referrals by user: $e\nStack: $stack',
        'ReferralService.getReferralsByUserId',
      );
      return [];
    }
  }

  /// Get referral summary for a user
  Future<ReferralSummary> getReferralSummary(String userId) async {
    try {
      final referrals = await getReferralsByUserId(userId);

      final completed =
          referrals.where((r) => r.status == ReferralStatus.completed).toList();
      final totalEarnings =
          completed.fold<double>(0, (sum, r) => sum + r.rewardAmount);

      return ReferralSummary(
        totalReferrals: referrals.length,
        completedReferrals: completed.length,
        totalEarnings: totalEarnings,
        recentReferrals: referrals.take(5).toList(),
      );
    } catch (e, stack) {
      Logger.error(
        'Error getting referral summary: $e\nStack: $stack',
        'ReferralService.getReferralSummary',
      );
      return ReferralSummary.empty();
    }
  }

  /// Cancel a referral
  Future<void> cancelReferral(String referralId) async {
    try {
      await _firestore
          .collection(_referralCollectionName)
          .doc(referralId)
          .update({
        'status': ReferralStatus.cancelled.name,
      });

      Logger.info(
        'Referral cancelled: $referralId',
        'ReferralService.cancelReferral',
      );
    } catch (e, stack) {
      Logger.error(
        'Error cancelling referral: $e\nStack: $stack',
        'ReferralService.cancelReferral',
      );
      rethrow;
    }
  }

  /// Helper: Update user's referral code
  Future<void> _updateUserReferralCode(String userId, String referralCode) async {
    try {
      final userDoc = await _firestore
          .collection(_userCollectionName)
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      if (userData['referralCode'] == null || userData['referralCode'].isEmpty) {
        await _firestore
            .collection(_userCollectionName)
            .doc(userId)
            .update({
          'referralCode': referralCode,
        });
      }
    } catch (e) {
      Logger.warning('Error updating user referral code: $e', 'ReferralService._updateUserReferralCode');
    }
  }

  /// Helper: Add reward to user's wallet
  Future<void> _addRewardToUser(String userId, double amount) async {
    try {
      await _firestore
          .collection(_userCollectionName)
          .doc(userId)
          .update({
        'walletBalance': FieldValue.increment(amount),
      });

      Logger.info(
        'Added referral reward to user $userId: $amount',
        'ReferralService._addRewardToUser',
      );
    } catch (e) {
      Logger.error('Error adding reward to user: $e', 'ReferralService._addRewardToUser');
    }
  }

  /// Helper: Increment referral count
  Future<void> _incrementReferralCount(String userId) async {
    try {
      await _firestore
          .collection(_userCollectionName)
          .doc(userId)
          .update({
        'referralCount': FieldValue.increment(1),
      });
    } catch (e) {
      Logger.error('Error incrementing referral count: $e', 'ReferralService._incrementReferralCount');
    }
  }

  /// Get leaderboard of top referrers
  Future<List<Map<String, dynamic>>> getTopReferrers({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_userCollectionName)
          .where('referralCount', isGreaterThan: 0)
          .orderBy('referralCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'name': data['name'] ?? 'User',
          'referralCount': data['referralCount'] ?? 0,
          'walletBalance': data['walletBalance'] ?? 0,
        };
      }).toList();
    } catch (e, stack) {
      Logger.error(
        'Error getting top referrers: $e\nStack: $stack',
        'ReferralService.getTopReferrers',
      );
      return [];
    }
  }
}
