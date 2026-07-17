import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Doc ID is the reviewer's uid, capping each user to one review per
  /// product: a second submission targets the same doc and is rejected by
  /// the `create`-only security rule (see firestore.rules).
  Future<void> submitReview(ReviewModel review) async {
    try {
      final batch = _firestore.batch();

      // Save review
      final reviewRef = _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .doc(review.userId);
      batch.set(reviewRef, review.toMap());

      // Update product rating
      await _updateProductRating(review.productId, batch);

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> _updateProductRating(String productId, WriteBatch? batch) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc['rating'] as double;
      }

      final averageRating = totalRating / snapshot.docs.length;

      final productRef = _firestore.collection('products').doc(productId);

      if (batch != null) {
        batch.update(productRef, {'rating': averageRating});
      } else {
        await productRef.update({'rating': averageRating});
      }
    } catch (e) {
      throw Exception('Failed to update product rating: $e');
    }
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<double> getProductAverageRating(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc['rating'] as double;
      }
      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  Future<int> getProductReviewCount(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get review count: $e');
    }
  }

  Future<void> updateHelpfulCount(
      String productId, String reviewId, int count) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .update({'helpfulCount': count});
    } catch (e) {
      throw Exception('Failed to update helpful count: $e');
    }
  }

  Future<void> deleteReview(String productId, String reviewId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firestore
        .collectionGroup('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
