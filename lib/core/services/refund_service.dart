import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/return_request_model.dart';

enum RefundStatus { pending, processing, completed, failed }

class RefundRecord {
  final String id;
  final String returnId;
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String phoneNumber;
  final RefundStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? errorMessage;

  RefundRecord({
    required this.id,
    required this.returnId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
  });

  factory RefundRecord.fromMap(Map<String, dynamic> map, String docId) {
    return RefundRecord(
      id: docId,
      returnId: map['returnId'] ?? '',
      orderId: map['orderId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      status: _parseStatus(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      transactionId: map['transactionId'],
      errorMessage: map['errorMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'returnId': returnId,
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'phoneNumber': phoneNumber,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionId': transactionId,
      'errorMessage': errorMessage,
    };
  }

  static RefundStatus _parseStatus(String status) {
    switch (status) {
      case 'processing':
        return RefundStatus.processing;
      case 'completed':
        return RefundStatus.completed;
      case 'failed':
        return RefundStatus.failed;
      default:
        return RefundStatus.pending;
    }
  }
}

class RefundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> initializeRefund(
    ReturnRequestModel returnRequest,
    String phoneNumber,
    String paymentMethod,
  ) async {
    try {
      final refund = RefundRecord(
        id: '',
        returnId: returnRequest.id,
        orderId: returnRequest.orderId,
        amount: returnRequest.refundAmount,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
        status: RefundStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection('refunds').add(refund.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to initialize refund: $e');
    }
  }

  Future<void> processRefund(
    String refundId,
    String phoneNumber,
    double amount,
  ) async {
    try {
      // Update refund status to processing
      await _firestore.collection('refunds').doc(refundId).update({
        'status': RefundStatus.processing.name,
      });

      // TODO: Integrate with M-Pesa or other payment gateway
      // For now, this is a placeholder that would call actual API
      // await _processMpesaRefund(phoneNumber, amount);

      // Mark as completed
      await _firestore.collection('refunds').doc(refundId).update({
        'status': RefundStatus.completed.name,
        'completedAt': Timestamp.now(),
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      // Mark as failed
      await _firestore.collection('refunds').doc(refundId).update({
        'status': RefundStatus.failed.name,
        'errorMessage': e.toString(),
      });
      throw Exception('Failed to process refund: $e');
    }
  }

  /// Mock M-Pesa refund processor (replace with real API call)
  Future<void> _processMpesaRefund(String phoneNumber, double amount) async {
    // This would integrate with Daraja API to send refund
    // await _mpesaService.initiateRefund(phoneNumber, amount);
    // For now, simulate a delay
    await Future.delayed(const Duration(seconds: 2));
  }

  Stream<RefundRecord?> getRefund(String refundId) {
    return _firestore
        .collection('refunds')
        .doc(refundId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return RefundRecord.fromMap(
          snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  Stream<List<RefundRecord>> getReturnRefunds(String returnId) {
    return _firestore
        .collection('refunds')
        .where('returnId', isEqualTo: returnId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RefundRecord.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<RefundRecord?> getLatestRefundForReturn(String returnId) async {
    try {
      final snapshot = await _firestore
          .collection('refunds')
          .where('returnId', isEqualTo: returnId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return RefundRecord.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      throw Exception('Failed to get refund record: $e');
    }
  }

  Future<void> retryRefund(String refundId) async {
    try {
      final refundDoc = await _firestore.collection('refunds').doc(refundId).get();
      if (!refundDoc.exists) {
        throw Exception('Refund not found');
      }

      final refund = RefundRecord.fromMap(
          refundDoc.data() as Map<String, dynamic>, refundId);

      // Reset to pending and try again
      await processRefund(
        refundId,
        refund.phoneNumber,
        refund.amount,
      );
    } catch (e) {
      throw Exception('Failed to retry refund: $e');
    }
  }

  Future<List<RefundRecord>> getPendingRefunds() async {
    try {
      final snapshot = await _firestore
          .collection('refunds')
          .where('status', isEqualTo: RefundStatus.pending.name)
          .get();

      return snapshot.docs
          .map((doc) => RefundRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending refunds: $e');
    }
  }
}
