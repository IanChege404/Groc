import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/catalog_provider.dart';

class SearchResultPage extends ConsumerStatefulWidget {
  const SearchResultPage({super.key});

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trimmedQuery = _query.trim();
    final resultsAsync = trimmedQuery.isEmpty
        ? null
        : ref.watch(searchProductsProvider(trimmedQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchResults),
        leading: const AppBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Semantics(
              label: l10n.searchField,
              child: TextField(
                controller: _controller,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.searchField,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    child: SvgPicture.asset(AppIcons.search),
                  ),
                  suffixIconConstraints: const BoxConstraints(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
              ),
              child: Text(
                trimmedQuery.isEmpty
                    ? l10n.startTypingToSearch
                    : l10n.searchResultsFor(trimmedQuery),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          Expanded(
            child: resultsAsync == null
                ? Center(child: Text(l10n.enterProductNameToSearch))
                : resultsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => RetryableErrorView(
                      title: l10n.failedToSearchProducts,
                      message: l10n.checkConnectionAndRetry,
                      onRetry: () => setState(() {}),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return Center(child: Text(l10n.noProductsFound));
                      }
                      return Semantics(
                        container: true,
                        label: l10n.resultsFound(products.length),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(
                            top: AppDefaults.padding,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductTileSquare(data: products[index]);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
