import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/ui_util.dart';
import 'dialogs/product_filters_dialog.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  static const _searchHistoryKey = 'search_history';
  static const _maxHistoryItems = 20;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_searchHistoryKey) ?? [];
    if (mounted) {
      setState(() => _searchHistory = history);
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > _maxHistoryItems) {
            _searchHistory.removeLast();
          }
        });
        _saveSearchHistory();
      }
      context.push('/searchResult', extra: {'query': query});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SearchPageHeader(
              searchController: _searchController,
              onSearch: _performSearch,
            ),
            const SizedBox(height: 8),
            _RecentSearchList(
              searchHistory: _searchHistory,
              onTap: _performSearch,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchList extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onTap;

  const _RecentSearchList({
    required this.searchHistory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.recentSearch,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          Expanded(
            child: searchHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      child: Text(
                        AppLocalizations.of(context)!.startTypingToSearch,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 16),
                    itemBuilder: (context, index) {
                      return SearchHistoryTile(
                        query: searchHistory[index],
                        onTap: () => onTap(searchHistory[index]),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(thickness: 0.1),
                    itemCount: searchHistory.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchPageHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const _SearchPageHeader({
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              children: [
                Form(
                  child: Semantics(
                    label: AppLocalizations.of(context)!.searchField,
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.searchProductsHint,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          child: SvgPicture.asset(
                            AppIcons.search,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                        contentPadding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      textInputAction: TextInputAction.search,
                      autofocus: true,
                      onChanged: (String? value) {},
                      onFieldSubmitted: (query) {
                        onSearch(query);
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  height: 56,
                  child: Semantics(
                    button: true,
                    label: AppLocalizations.of(context)!.filterButton,
                    child: SizedBox(
                      width: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          UiUtil.openBottomSheet(
                            context: context,
                            widget: const ProductFiltersDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: SvgPicture.asset(AppIcons.filter),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const SearchHistoryTile({
    super.key,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: query,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Text(query, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              SvgPicture.asset(AppIcons.searchTileArrow),
            ],
          ),
        ),
      ),
    );
  }
}
