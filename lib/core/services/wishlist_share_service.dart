import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../utils/logger.dart';

class WishlistShareService {
  final _firestore = FirebaseFirestore.instance;

  /// Creates a shareable wishlist link
  /// Returns a unique share code that can be used to access the wishlist
  Future<String> createShareLink(
    String userId,
    List<String> itemIds,
    String? customName,
  ) async {
    try {
      final shareCode = _generateShareCode();
      final timestamp = DateTime.now();
      final expiresAt = timestamp.add(const Duration(days: 30));

      final shareData = {
        'shareCode': shareCode,
        'userId': userId,
        'itemIds': itemIds,
        'name': customName ?? 'My Wishlist',
        'createdAt': Timestamp.fromDate(timestamp),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'accessCount': 0,
      };

      await _firestore
          .collection('wishlist_shares')
          .doc(shareCode)
          .set(shareData);

      Logger.info(
        'Created wishlist share link: $shareCode',
        'WishlistShareService.createShareLink',
      );

      return shareCode;
    } catch (e, stack) {
      Logger.error(
        'Error creating share link: $e\nStack: $stack',
        'WishlistShareService.createShareLink',
      );
      rethrow;
    }
  }

  /// Retrieves a shared wishlist by share code
  Future<Map<String, dynamic>?> getSharedWishlist(String shareCode) async {
    try {
      final doc =
          await _firestore.collection('wishlist_shares').doc(shareCode).get();

      if (!doc.exists) {
        Logger.warning(
          'Share code not found: $shareCode',
          'WishlistShareService.getSharedWishlist',
        );
        return null;
      }

      final data = doc.data()!;

      // Check if expired
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        Logger.warning(
          'Share link expired: $shareCode',
          'WishlistShareService.getSharedWishlist',
        );
        // Optionally delete expired shares
        await _firestore.collection('wishlist_shares').doc(shareCode).delete();
        return null;
      }

      // Increment access count
      await _firestore.collection('wishlist_shares').doc(shareCode).update({
        'accessCount': FieldValue.increment(1),
        'lastAccessedAt': Timestamp.now(),
      });

      return data;
    } catch (e, stack) {
      Logger.error(
        'Error retrieving shared wishlist: $e\nStack: $stack',
        'WishlistShareService.getSharedWishlist',
      );
      rethrow;
    }
  }

  /// Imports a shared wishlist into current user's wishlist
  Future<void> importSharedWishlist(
    String currentUserId,
    String shareCode,
  ) async {
    try {
      final sharedData = await getSharedWishlist(shareCode);
      if (sharedData == null) {
        throw Exception('Share link not found or expired');
      }

      final itemIds = List<String>.from(sharedData['itemIds'] ?? []);

      // Add each item to current user's wishlist
      final batch = _firestore.batch();
      for (final itemId in itemIds) {
        final docId = '${currentUserId}_product_$itemId';
        batch.set(
          _firestore.collection('wishlist').doc(docId),
          {
            'userId': currentUserId,
            'itemId': itemId,
            'itemType': 'product',
            'addedAt': Timestamp.now(),
            'importedFrom': shareCode,
          },
        );
      }

      await batch.commit();

      Logger.info(
        'Imported ${itemIds.length} items from shared wishlist',
        'WishlistShareService.importSharedWishlist',
      );
    } catch (e, stack) {
      Logger.error(
        'Error importing shared wishlist: $e\nStack: $stack',
        'WishlistShareService.importSharedWishlist',
      );
      rethrow;
    }
  }

  /// Deletes a share link
  Future<void> deleteShareLink(String shareCode) async {
    try {
      await _firestore.collection('wishlist_shares').doc(shareCode).delete();
      Logger.info(
        'Deleted share link: $shareCode',
        'WishlistShareService.deleteShareLink',
      );
    } catch (e, stack) {
      Logger.error(
        'Error deleting share link: $e\nStack: $stack',
        'WishlistShareService.deleteShareLink',
      );
      rethrow;
    }
  }

  /// Gets all share links for a user
  Future<List<Map<String, dynamic>>> getUserShareLinks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist_shares')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, stack) {
      Logger.error(
        'Error getting user share links: $e\nStack: $stack',
        'WishlistShareService.getUserShareLinks',
      );
      return [];
    }
  }

  /// Generates a unique 8-character share code
  String _generateShareCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final encoded = utf8.encode(random);
    final hash = sha256.convert(encoded).toString();
    return hash.substring(0, 8).toUpperCase();
  }
}
