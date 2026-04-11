import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
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
    final trimmedQuery = _query.trim();
    final resultsAsync = trimmedQuery.isEmpty
        ? null
        : ref.watch(searchProductsProvider(trimmedQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        leading: const AppBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                labelText: 'Search Field',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: SvgPicture.asset(AppIcons.search),
                ),
                suffixIconConstraints: const BoxConstraints(),
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
                    ? 'Start typing to search products'
                    : 'Search results for "$trimmedQuery"',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: resultsAsync == null
                ? const Center(child: Text('Enter a product name to search'))
                : resultsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Failed to search products: $error'),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }
                      return GridView.builder(
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
