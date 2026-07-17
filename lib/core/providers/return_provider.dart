import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/return_request_model.dart';
import '../services/return_service.dart';

final returnServiceProvider = Provider((ref) => ReturnService());

final userReturnsProvider =
    StreamProvider.family<List<ReturnRequestModel>, String>(
  (ref, userId) {
    final returnService = ref.watch(returnServiceProvider);
    return returnService.getUserReturns(userId);
  },
);

final returnRequestProvider =
    StreamProvider.family<ReturnRequestModel?, String>(
  (ref, returnId) {
    final returnService = ref.watch(returnServiceProvider);
    return returnService.getReturnRequest(returnId);
  },
);

final orderReturnsProvider =
    StreamProvider.family<List<ReturnRequestModel>, String>(
  (ref, orderId) {
    final returnService = ref.watch(returnServiceProvider);
    return returnService.getOrderReturns(orderId);
  },
);

final userReturnCountProvider = FutureProvider.family<int, String>(
  (ref, userId) async {
    final returnService = ref.watch(returnServiceProvider);
    return returnService.getReturnCount(userId);
  },
);

final initializeReturnProvider =
    FutureProvider.family<String, ReturnRequestModel>(
  (ref, request) async {
    final returnService = ref.watch(returnServiceProvider);
    return returnService.initializeReturn(request);
  },
);
