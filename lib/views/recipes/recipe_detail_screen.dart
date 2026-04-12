import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/recipe_model.dart';
import '../../core/providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late int _servings;
  late TabController _tabController;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(recipe),
                  const SizedBox(height: 16),
                  _buildServingSelector(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  _buildTabContent(recipe),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAddToCartBar(recipe),
    );
  }

  Widget _buildAppBar(RecipeModel recipe) {
    return SliverAppBar(
      leading: const AppBackButton(),
      expandedHeight: 240,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.imageUrl.isNotEmpty
            ? Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariantLight),
              )
            : Container(color: AppColors.surfaceVariantLight),
      ),
    );
  }

  Widget _buildHeader(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          recipe.description,
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _InfoChip(
              icon: Icons.timer_outlined,
              label: '${recipe.totalTimeMinutes} min',
            ),
            const SizedBox(width: 8),
            _InfoChip(
              icon: Icons.bar_chart,
              label: recipe.difficulty,
            ),
            const SizedBox(width: 8),
            _InfoChip(
              icon: Icons.star,
              label: recipe.rating.toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServingSelector() {
    return Row(
      children: [
        const Text(
          'Servings:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const Spacer(),
        _QuantityButton(
          icon: Icons.remove,
          onTap: () {
            if (_servings > 1) setState(() => _servings--);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$_servings',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: () => setState(() => _servings++),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.primary,
      tabs: const [
        Tab(text: 'Ingredients'),
        Tab(text: 'Instructions'),
      ],
    );
  }

  Widget _buildTabContent(RecipeModel recipe) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index == 0) {
          return _buildIngredients(recipe);
        }
        return _buildInstructions(recipe);
      },
    );
  }

  Widget _buildIngredients(RecipeModel recipe) {
    final scale = _servings / recipe.servings;
    return Column(
      children: recipe.ingredients.map((ing) {
        final qty = (ing.quantity * scale);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 16,
            backgroundImage: ing.imageUrl != null
                ? NetworkImage(ing.imageUrl!)
                : null,
            child: ing.imageUrl == null
                ? const Icon(Icons.shopping_basket, size: 16)
                : null,
          ),
          title: Text(ing.productName),
          trailing: Text(
            '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} ${ing.unit}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructions(RecipeModel recipe) {
    return Column(
      children: recipe.instructions.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Text(
                  '${entry.key + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.value, style: const TextStyle(height: 1.5)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddToCartBar(RecipeModel recipe) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isAddingToCart
              ? null
              : () async {
                  setState(() => _isAddingToCart = true);
                  final added = await addRecipeToCart(
                    ref: ref,
                    recipe: recipe,
                    targetServings: _servings,
                  );
                  setState(() => _isAddingToCart = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added > 0
                            ? '$added ingredients added to cart!'
                            : 'Please sign in to add items.',
                      ),
                    ),
                  );
                },
          icon: _isAddingToCart
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add_shopping_cart),
          label: const Text('Add All Ingredients to Cart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
