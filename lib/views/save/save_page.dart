import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/providers/wishlist_provider.dart';
import 'components/single_wishlist_item_tile.dart';
import 'empty_save_page.dart';

class SavePage extends ConsumerStatefulWidget {
  const SavePage({super.key, this.isHomePage = false});

  final bool isHomePage;

  @override
  ConsumerState<SavePage> createState() => _SavePageState();
}

class _SavePageState extends ConsumerState<SavePage> {
  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistItemsProvider);

    return Scaffold(
      appBar: widget.isHomePage
          ? null
          : AppBar(
              leading: const AppBackButton(),
              title: const Text('Wishlist'),
            ),
      body: SafeArea(
        child: wishlistState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load wishlist: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the wishlist data
                      ref.invalidate(wishlistItemsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptySavePage();
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh the wishlist data
                ref.invalidate(wishlistItemsProvider);
                // Wait a moment for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final wishlistItem = items[index];
                  return SingleWishlistItemTile(
                    key: ValueKey(wishlistItem.id),
                    wishlistItem: wishlistItem,
                    onRemove: () => ref
                        .read(wishlistItemsProvider.notifier)
                        .removeFromWishlist(wishlistItem.id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
