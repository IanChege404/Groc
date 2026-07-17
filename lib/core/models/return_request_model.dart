import 'package:cloud_firestore/cloud_firestore.dart';

enum ReturnStatus { pending, approved, rejected, completed }

extension ReturnStatusExtension on ReturnStatus {
  String get displayName {
    switch (this) {
      case ReturnStatus.pending:
        return 'Pending';
      case ReturnStatus.approved:
        return 'Approved';
      case ReturnStatus.rejected:
        return 'Rejected';
      case ReturnStatus.completed:
        return 'Completed';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}

class ReturnRequestModel {
  final String id;
  final String orderId;
  final String userId;
  final String productId;
  final String productName;
  final String productImage;
  final String reason;
  final String description;
  final ReturnStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final double refundAmount;
  final String? adminNotes;
  final int itemCount;

  ReturnRequestModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.refundAmount,
    this.approvedAt,
    this.completedAt,
    this.adminNotes,
    this.itemCount = 1,
  });

  factory ReturnRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReturnRequestModel(
      id: docId,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      status: _parseStatus(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      refundAmount: (map['refundAmount'] ?? 0).toDouble(),
      approvedAt: map['approvedAt'] is Timestamp
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      adminNotes: map['adminNotes'],
      itemCount: map['itemCount'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'reason': reason,
      'description': description,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'refundAmount': refundAmount,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'adminNotes': adminNotes,
      'itemCount': itemCount,
    };
  }

  static ReturnStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return ReturnStatus.approved;
      case 'rejected':
        return ReturnStatus.rejected;
      case 'completed':
        return ReturnStatus.completed;
      default:
        return ReturnStatus.pending;
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }

  bool get canBeRequested => status == ReturnStatus.pending;
  bool get isApproved => status == ReturnStatus.approved;
  bool get isCompleted => status == ReturnStatus.completed;
  bool get isRejected => status == ReturnStatus.rejected;
}
