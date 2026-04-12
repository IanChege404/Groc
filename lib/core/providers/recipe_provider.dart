import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe_model.dart';
import '../models/cart_item_model.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

final _firestore = FirebaseFirestore.instance;

// ── Recipes list provider ─────────────────────────────────────────────────────

final recipesProvider =
    StateNotifierProvider<RecipeNotifier, AsyncValue<List<RecipeModel>>>((ref) {
      return RecipeNotifier();
    });

class RecipeNotifier extends StateNotifier<AsyncValue<List<RecipeModel>>> {
  RecipeNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = const AsyncValue.loading();
      final snap = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();
      final recipes =
          snap.docs.map(RecipeModel.fromFirestore).toList();
      state = AsyncValue.data(recipes);
    } catch (e, st) {
      Logger.error('RecipeNotifier load error: $e', 'RecipeNotifier');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}

// ── Single recipe provider ────────────────────────────────────────────────────

final recipeDetailProvider =
    FutureProvider.family<RecipeModel?, String>((ref, recipeId) async {
      final doc =
          await _firestore.collection('recipes').doc(recipeId).get();
      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc);
    });

// ── Recipes filtered by tag ───────────────────────────────────────────────────

final recipesByTagProvider =
    FutureProvider.family<List<RecipeModel>, String>((ref, tag) async {
      final snap = await _firestore
          .collection('recipes')
          .where('tags', arrayContains: tag)
          .get();
      return snap.docs.map(RecipeModel.fromFirestore).toList();
    });

// ── Add all recipe ingredients to cart ───────────────────────────────────────

/// Add all scaled ingredients of a recipe to the user's cart.
/// Returns the number of items added.
Future<int> addRecipeToCart({
  required WidgetRef ref,
  required RecipeModel recipe,
  int targetServings = 0,
}) async {
  final authState = ref.read(authProvider);
  final userId = authState.maybeWhen(data: (uid) => uid, orElse: () => null);
  if (userId == null) return 0;

  final baseServings = recipe.servings;
  final scale = targetServings > 0
      ? targetServings / baseServings
      : 1.0;

  int added = 0;
  for (final ingredient in recipe.ingredients) {
    if (ingredient.productId.isEmpty) continue;

    final scaled = ingredient.scaledBy(scale);
    final qty = scaled.quantity.ceil();
    if (qty <= 0) continue;

    final item = CartItemModel(
      id: '${userId}_${ingredient.productId}',
      productId: ingredient.productId,
      quantity: qty,
      priceAtTimeOfAdd: ingredient.price ?? 0.0,
      userId: userId,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(cartItemsProvider.notifier).addToCart(item);
    added++;
  }

  Logger.info(
    'Added $added recipe ingredients to cart (scale: $scale)',
    'RecipeProvider',
  );
  return added;
}
