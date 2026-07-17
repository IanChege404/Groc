import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/return_request_model.dart';

class ReturnService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> initializeReturn(ReturnRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection('return_requests')
          .add(request.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to initialize return: $e');
    }
  }

  Stream<List<ReturnRequestModel>> getUserReturns(String userId) {
    return _firestore
        .collection('return_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReturnRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<ReturnRequestModel?> getReturnRequest(String returnId) {
    return _firestore
        .collection('return_requests')
        .doc(returnId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ReturnRequestModel.fromMap(
          snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  Stream<List<ReturnRequestModel>> getOrderReturns(String orderId) {
    return _firestore
        .collection('return_requests')
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReturnRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateReturnStatus(
      String returnId, ReturnStatus status) async {
    try {
      final updates = {
        'status': status.value,
      };

      if (status == ReturnStatus.approved) {
        updates['approvedAt'] = Timestamp.now();
      } else if (status == ReturnStatus.completed) {
        updates['completedAt'] = Timestamp.now();
      }

      await _firestore
          .collection('return_requests')
          .doc(returnId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update return status: $e');
    }
  }

  Future<void> addAdminNotes(String returnId, String notes) async {
    try {
      await _firestore
          .collection('return_requests')
          .doc(returnId)
          .update({'adminNotes': notes});
    } catch (e) {
      throw Exception('Failed to add admin notes: $e');
    }
  }

  Future<void> processRefund(String returnId, double amount) async {
    try {
      final batch = _firestore.batch();

      final returnDocRef =
          _firestore.collection('return_requests').doc(returnId);
      batch.update(returnDocRef, {
        'status': ReturnStatus.completed.value,
        'completedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }

  Future<void> cancelReturn(String returnId) async {
    try {
      await _firestore.collection('return_requests').doc(returnId).delete();
    } catch (e) {
      throw Exception('Failed to cancel return: $e');
    }
  }

  Future<int> getReturnCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('return_requests')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get return count: $e');
    }
  }
}
