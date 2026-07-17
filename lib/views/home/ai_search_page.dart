import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/ai_search_provider.dart';
import '../../core/utils/responsive_helper.dart';

class AiSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const AiSearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<AiSearchPage> createState() => _AiSearchPageState();
}

class _AiSearchPageState extends ConsumerState<AiSearchPage> {
  late TextEditingController _searchController;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _currentQuery = widget.initialQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchResults = ref.watch(aiSearchProvider(_currentQuery));
    final recommendations =
        ref.watch(searchRecommendationsProvider(_searchController.text));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.aiSearch),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: _SearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _currentQuery = value.trim());
                },
              ),
            ),
            if (_currentQuery.isEmpty && _searchController.text.length >= 2)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                child: recommendations.when(
                  data: (suggestions) {
                    if (suggestions.isEmpty) return const SizedBox();
                    return _SearchSuggestions(
                      suggestions: suggestions,
                      onTap: (suggestion) {
                        _searchController.text = suggestion;
                        setState(() => _currentQuery = suggestion);
                      },
                    );
                  },
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            Expanded(
              child: searchResults.when(
                data: (products) {
                  if (_currentQuery.isEmpty) {
                    return _EmptySearch();
                  }

                  if (products.isEmpty) {
                    return _NoResults(query: _currentQuery);
                  }

                  return _SearchResultsList(products: products);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => RetryableErrorView(
                  title: l10n.failedToSearchProducts,
                  message: l10n.checkConnectionAndRetry,
                  onRetry: () => setState(() {}),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: l10n.searchProductsHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SearchSuggestions({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: l10n.suggestions,
      child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.suggestions,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            ...suggestions.map(
              (suggestion) => Semantics(
                button: true,
                label: suggestion,
                child: ListTile(
                  leading: const Icon(Icons.history_rounded, size: 16),
                  title: Text(suggestion),
                  onTap: () => onTap(suggestion),
                  dense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List products;

  const _SearchResultsList({required this.products});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveHelper.getDeviceSize(
          BoxConstraints(maxWidth: screenWidth),
        ) ==
        DeviceSize.tablet;
    final crossAxisCount = isTablet ? 3 : 2;

    return Semantics(
      container: true,
      label: l10n.resultsFound(products.length),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.resultsFound(products.length),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return ProductTileSquare(data: product);
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: '${l10n.startSearching}. ${l10n.typeForAiRecommendations}',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.startSearching,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.typeForAiRecommendations,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;

  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: '${l10n.noResults}. ${l10n.noResultsForQuery(query)}',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResults,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noResultsForQuery(query),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.browseCatalog),
            ),
          ],
        ),
      ),
    );
  }
}
