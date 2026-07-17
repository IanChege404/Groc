import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/return_request_model.dart';

class ShippingLabel {
  final String id;
  final String returnId;
  final String trackingNumber;
  final String fromAddress;
  final String toAddress;
  final String carrierName;
  final double weight;
  final DateTime createdAt;
  final String? labelUrl;

  ShippingLabel({
    required this.id,
    required this.returnId,
    required this.trackingNumber,
    required this.fromAddress,
    required this.toAddress,
    required this.carrierName,
    required this.weight,
    required this.createdAt,
    this.labelUrl,
  });

  factory ShippingLabel.fromMap(Map<String, dynamic> map, String docId) {
    return ShippingLabel(
      id: docId,
      returnId: map['returnId'] ?? '',
      trackingNumber: map['trackingNumber'] ?? '',
      fromAddress: map['fromAddress'] ?? '',
      toAddress: map['toAddress'] ?? '',
      carrierName: map['carrierName'] ?? 'Standard Courier',
      weight: (map['weight'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      labelUrl: map['labelUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'returnId': returnId,
      'trackingNumber': trackingNumber,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'carrierName': carrierName,
      'weight': weight,
      'createdAt': Timestamp.fromDate(createdAt),
      'labelUrl': labelUrl,
    };
  }
}

class ShippingLabelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ShippingLabel> generateShippingLabel(
    ReturnRequestModel returnRequest,
    String userAddress,
  ) async {
    try {
      // Generate tracking number (format: GRC + timestamp)
      final trackingNumber =
          'GRC${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';

      // Warehouse address (default - should be configurable)
      const warehouseAddress =
          'Groc Warehouse\nNairobi, Kenya\nP.O. Box 12345';

      final label = ShippingLabel(
        id: '',
        returnId: returnRequest.id,
        trackingNumber: trackingNumber,
        fromAddress: userAddress,
        toAddress: warehouseAddress,
        carrierName: 'Express Courier',
        weight: 1.0, // Default weight, should be product-specific
        createdAt: DateTime.now(),
        labelUrl: null, // Will be set after PDF generation
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('return_requests')
          .doc(returnRequest.id)
          .collection('shipping_labels')
          .add(label.toMap());

      return ShippingLabel(
        id: docRef.id,
        returnId: label.returnId,
        trackingNumber: label.trackingNumber,
        fromAddress: label.fromAddress,
        toAddress: label.toAddress,
        carrierName: label.carrierName,
        weight: label.weight,
        createdAt: label.createdAt,
        labelUrl: label.labelUrl,
      );
    } catch (e) {
      throw Exception('Failed to generate shipping label: $e');
    }
  }

  Stream<ShippingLabel?> getShippingLabel(String returnId) {
    return _firestore
        .collection('return_requests')
        .doc(returnId)
        .collection('shipping_labels')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return ShippingLabel.fromMap(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  Future<void> updateLabelUrl(String returnId, String labelId, String url) async {
    try {
      await _firestore
          .collection('return_requests')
          .doc(returnId)
          .collection('shipping_labels')
          .doc(labelId)
          .update({'labelUrl': url});
    } catch (e) {
      throw Exception('Failed to update label URL: $e');
    }
  }

  Future<List<ShippingLabel>> getReturnShippingLabels(String returnId) async {
    try {
      final snapshot = await _firestore
          .collection('return_requests')
          .doc(returnId)
          .collection('shipping_labels')
          .get();

      return snapshot.docs
          .map((doc) => ShippingLabel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get shipping labels: $e');
    }
  }
}
