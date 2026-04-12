import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flash_deal_model.dart';
import '../utils/logger.dart';

final _firestore = FirebaseFirestore.instance;

// ── Flash deals stream provider ───────────────────────────────────────────────

final flashDealsProvider =
    StreamProvider<List<FlashDealModel>>((ref) {
      return _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .where('endTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('endTime')
          .snapshots()
          .map(
            (snap) => snap.docs
                .map(FlashDealModel.fromFirestore)
                .where((d) => d.hasStarted)
                .toList(),
          );
    });

// ── Active deals count ────────────────────────────────────────────────────────

final activeDealsCountProvider = Provider<int>((ref) {
  return ref.watch(flashDealsProvider).maybeWhen(
        data: (deals) => deals.length,
        orElse: () => 0,
      );
});

// ── Single deal ───────────────────────────────────────────────────────────────

final dealDetailProvider =
    FutureProvider.family<FlashDealModel?, String>((ref, dealId) async {
      try {
        final doc =
            await _firestore.collection('offers').doc(dealId).get();
        if (!doc.exists) return null;
        return FlashDealModel.fromFirestore(doc);
      } catch (e) {
        Logger.error('dealDetailProvider error: $e', 'FlashDealProvider');
        return null;
      }
    });
