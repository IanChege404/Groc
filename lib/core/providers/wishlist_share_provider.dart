import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wishlist_share_service.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final wishlistShareServiceProvider = Provider((ref) {
  return WishlistShareService();
});

final createWishlistShareLinkProvider = FutureProvider.family<
    String,
    ({
      List<String> itemIds,
      String? customName,
    })>((ref, params) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    final service = ref.read(wishlistShareServiceProvider);
    final shareCode = await service.createShareLink(
      userId,
      params.itemIds,
      params.customName,
    );

    return shareCode;
  } catch (e) {
    Logger.error('Error creating share link: $e', 'createWishlistShareLinkProvider');
    rethrow;
  }
});

final getSharedWishlistProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, shareCode) async {
  try {
    final service = ref.read(wishlistShareServiceProvider);
    return await service.getSharedWishlist(shareCode);
  } catch (e) {
    Logger.error('Error getting shared wishlist: $e', 'getSharedWishlistProvider');
    return null;
  }
});

final userShareLinksProvider = FutureProvider((ref) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final service = ref.read(wishlistShareServiceProvider);
    return await service.getUserShareLinks(userId);
  } catch (e) {
    Logger.error('Error getting user share links: $e', 'userShareLinksProvider');
    return <Map<String, dynamic>>[];
  }
});

final importSharedWishlistProvider = FutureProvider.family<void, String>((
  ref,
  shareCode,
) async {
  try {
    final authState = ref.watch(authProvider);
    final userId = authState.maybeWhen(
      data: (uid) => uid,
      orElse: () => null,
    );

    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    final service = ref.read(wishlistShareServiceProvider);
    await service.importSharedWishlist(userId, shareCode);

    // Refresh wishlist after import
    ref.invalidate(userShareLinksProvider);

    Logger.info(
      'Successfully imported shared wishlist',
      'importSharedWishlistProvider',
    );
  } catch (e) {
    Logger.error('Error importing shared wishlist: $e', 'importSharedWishlistProvider');
    rethrow;
  }
});
