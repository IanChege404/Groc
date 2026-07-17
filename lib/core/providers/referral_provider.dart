import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/referral_model.dart';
import '../services/referral_service.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final referralServiceProvider = Provider((ref) {
  return ReferralService();
});

final userReferralCodeProvider = FutureProvider((ref) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      return null;
    }

    final service = ref.read(referralServiceProvider);
    final code = await service.generateReferralCode(userId);
    return code;
  } catch (e) {
    Logger.error('Error generating referral code: $e', 'userReferralCodeProvider');
    return null;
  }
});

final userReferralsProvider = FutureProvider((ref) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      return <ReferralModel>[];
    }

    final service = ref.read(referralServiceProvider);
    return await service.getReferralsByUserId(userId);
  } catch (e) {
    Logger.error('Error getting user referrals: $e', 'userReferralsProvider');
    return <ReferralModel>[];
  }
});

final referralSummaryProvider = FutureProvider((ref) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      return ReferralSummary.empty();
    }

    final service = ref.read(referralServiceProvider);
    return await service.getReferralSummary(userId);
  } catch (e) {
    Logger.error('Error getting referral summary: $e', 'referralSummaryProvider');
    return ReferralSummary.empty();
  }
});

final topReferrersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final service = ref.read(referralServiceProvider);
    return await service.getTopReferrers();
  } catch (e) {
    Logger.error('Error getting top referrers: $e', 'topReferrersProvider');
    return [];
  }
});

final completeReferralProvider = FutureProvider.family<void, String>((
  ref,
  referralId,
) async {
  try {
    final service = ref.read(referralServiceProvider);
    await service.completeReferral(referralId);

    // Refresh referral data
    ref.invalidate(userReferralsProvider);
    ref.invalidate(referralSummaryProvider);

    Logger.info('Referral completed: $referralId', 'completeReferralProvider');
  } catch (e) {
    Logger.error('Error completing referral: $e', 'completeReferralProvider');
    rethrow;
  }
});

final cancelReferralProvider = FutureProvider.family<void, String>((
  ref,
  referralId,
) async {
  try {
    final service = ref.read(referralServiceProvider);
    await service.cancelReferral(referralId);

    // Refresh referral data
    ref.invalidate(userReferralsProvider);
    ref.invalidate(referralSummaryProvider);

    Logger.info('Referral cancelled: $referralId', 'cancelReferralProvider');
  } catch (e) {
    Logger.error('Error cancelling referral: $e', 'cancelReferralProvider');
    rethrow;
  }
});

final getReferralByCodeProvider = FutureProvider.family<ReferralModel?, String>((
  ref,
  code,
) async {
  try {
    final service = ref.read(referralServiceProvider);
    return await service.getReferralByCode(code);
  } catch (e) {
    Logger.error('Error getting referral by code: $e', 'getReferralByCodeProvider');
    return null;
  }
});

final createReferralProvider = FutureProvider.family<
    ReferralModel,
    (String refereeId, String referralCode, String refereeEmail)>((ref, params) async {
  try {
    final (refereeId, referralCode, refereeEmail) = params;

    final authState = ref.watch(authProvider);
    final referrerId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (referrerId == null || referrerId.isEmpty) {
      throw Exception('User not authenticated');
    }

    final service = ref.read(referralServiceProvider);
    final referral = await service.createReferral(
      referrerId: referrerId,
      refereeId: refereeId,
      referralCode: referralCode,
      refereeEmail: refereeEmail,
    );

    // Refresh referral data
    ref.invalidate(userReferralsProvider);
    ref.invalidate(referralSummaryProvider);

    return referral;
  } catch (e) {
    Logger.error('Error creating referral: $e', 'createReferralProvider');
    rethrow;
  }
});
