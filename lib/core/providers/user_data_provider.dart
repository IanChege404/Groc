import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_service.dart';

final userDataProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, userId) async {
      if (userId.isEmpty) {
        return null;
      }
      return FirestoreService().getUserProfile(userId);
    });

final userAddressesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) async {
      if (userId.isEmpty) {
        return const [];
      }
      return FirestoreService().getUserAddresses(userId);
    });

final paymentMethodsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) async {
      if (userId.isEmpty) {
        return const [];
      }
      return FirestoreService().getPaymentMethods(userId);
    });
