import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_model.dart';
import '../constants/payment_constants.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final _firestore = FirebaseFirestore.instance;

// ── Loyalty account provider ─────────────────────────────────────────────────

final loyaltyProvider =
    StateNotifierProvider<LoyaltyNotifier, AsyncValue<LoyaltyModel?>>((ref) {
      final authState = ref.watch(authProvider);
      return LoyaltyNotifier(authState: authState);
    });

class LoyaltyNotifier extends StateNotifier<AsyncValue<LoyaltyModel?>> {
  final AsyncValue<String?> authState;

  LoyaltyNotifier({required this.authState})
      : super(const AsyncValue.loading()) {
    authState.whenData((uid) {
      if (uid != null && uid.isNotEmpty) {
        _load(uid);
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> _load(String userId) async {
    try {
      state = const AsyncValue.loading();
      final doc =
          await _firestore.collection('loyalty').doc(userId).get();

      if (doc.exists) {
        state = AsyncValue.data(LoyaltyModel.fromFirestore(doc));
      } else {
        // Create a new loyalty account for the user
        final newAccount = LoyaltyModel(
          id: userId,
          userId: userId,
          totalPoints: 0,
          availablePoints: 0,
          redeemedPoints: 0,
          tier: 1,
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('loyalty')
            .doc(userId)
            .set(newAccount.toFirestore());
        state = AsyncValue.data(newAccount);
      }
    } catch (e, st) {
      Logger.error('LoyaltyNotifier load error: $e', 'LoyaltyNotifier');
      state = AsyncValue.error(e, st);
    }
  }

  /// Earn loyalty points for a completed order
  Future<void> earnPoints({
    required String userId,
    required double orderAmount,
    required String orderId,
  }) async {
    try {
      final points =
          (orderAmount * PaymentConstants.pointsPerKes).floor();
      if (points <= 0) return;

      final txn = LoyaltyTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        points: points,
        type: 'earn',
        description: 'Earned from order',
        orderId: orderId,
        timestamp: DateTime.now(),
      );

      final current = state.valueOrNull;
      final newTotal = (current?.totalPoints ?? 0) + points;
      final newAvailable = (current?.availablePoints ?? 0) + points;
      final newTier = _calculateTier(newTotal);

      await _firestore.collection('loyalty').doc(userId).set(
        {
          'totalPoints': newTotal,
          'availablePoints': newAvailable,
          'tier': newTier,
          'transactions': FieldValue.arrayUnion([txn.toMap()]),
          'updatedAt': Timestamp.now(),
          'userId': userId,
        },
        SetOptions(merge: true),
      );

      await _load(userId);
      Logger.info(
        'Earned $points loyalty points for order $orderId',
        'LoyaltyNotifier',
      );
    } catch (e) {
      Logger.error('LoyaltyNotifier earnPoints error: $e', 'LoyaltyNotifier');
    }
  }

  /// Redeem loyalty points (deducted from available balance)
  Future<bool> redeemPoints({
    required String userId,
    required int points,
    required String description,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    if (points < PaymentConstants.minRedeemablePoints) {
      Logger.warning(
        'Minimum redeemable points: ${PaymentConstants.minRedeemablePoints}',
        'LoyaltyNotifier',
      );
      return false;
    }

    if (current.availablePoints < points) {
      Logger.warning('Insufficient loyalty points', 'LoyaltyNotifier');
      return false;
    }

    try {
      final txn = LoyaltyTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        points: -points,
        type: 'redeem',
        description: description,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('loyalty').doc(userId).set(
        {
          'availablePoints': current.availablePoints - points,
          'redeemedPoints': current.redeemedPoints + points,
          'transactions': FieldValue.arrayUnion([txn.toMap()]),
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );

      await _load(userId);
      return true;
    } catch (e) {
      Logger.error('LoyaltyNotifier redeemPoints error: $e', 'LoyaltyNotifier');
      return false;
    }
  }

  int _calculateTier(int totalPoints) {
    if (totalPoints >= 10000) return 4; // Platinum
    if (totalPoints >= 5000) return 3; // Gold
    if (totalPoints >= 2000) return 2; // Silver
    return 1; // Bronze
  }
}

// ── Convenience providers ────────────────────────────────────────────────────

final loyaltyPointsProvider = Provider<int>((ref) {
  return ref
          .watch(loyaltyProvider)
          .valueOrNull
          ?.availablePoints ??
      0;
});

final loyaltyCashValueProvider = Provider<double>((ref) {
  final points = ref.watch(loyaltyPointsProvider);
  return points * PaymentConstants.kesPerPoint;
});
