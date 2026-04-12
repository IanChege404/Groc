import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

/// Hive local cache service for offline-first persistence
class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  static const String _productsBox = 'products_cache';
  static const String _cartBox = 'cart_cache';
  static const String _categoriesBox = 'categories_cache';
  static const String _recipesBox = 'recipes_cache';
  static const String _dealsBox = 'deals_cache';
  static const String _metaBox = 'meta';

  bool _initialized = false;

  /// Initialise Hive and open all boxes
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox<String>(_productsBox),
        Hive.openBox<String>(_cartBox),
        Hive.openBox<String>(_categoriesBox),
        Hive.openBox<String>(_recipesBox),
        Hive.openBox<String>(_dealsBox),
        Hive.openBox<String>(_metaBox),
      ]);
      _initialized = true;
      Logger.info('Hive initialized with all boxes open', 'HiveService');
    } catch (e) {
      Logger.error('Hive initialization failed: $e', 'HiveService');
    }
  }

  // ── Generic helpers ──────────────────────────────────────────────────────────

  Future<void> _put(String boxName, String key, String value) async {
    try {
      final box = Hive.box<String>(boxName);
      await box.put(key, value);
    } catch (e) {
      Logger.error('Hive put error ($boxName/$key): $e', 'HiveService');
    }
  }

  String? _get(String boxName, String key) {
    try {
      final box = Hive.box<String>(boxName);
      return box.get(key);
    } catch (e) {
      Logger.error('Hive get error ($boxName/$key): $e', 'HiveService');
      return null;
    }
  }

  Future<void> _delete(String boxName, String key) async {
    try {
      final box = Hive.box<String>(boxName);
      await box.delete(key);
    } catch (e) {
      Logger.error('Hive delete error ($boxName/$key): $e', 'HiveService');
    }
  }

  Future<void> _clearBox(String boxName) async {
    try {
      final box = Hive.box<String>(boxName);
      await box.clear();
    } catch (e) {
      Logger.error('Hive clear error ($boxName): $e', 'HiveService');
    }
  }

  // ── Products ─────────────────────────────────────────────────────────────────

  Future<void> cacheProducts(String jsonData) =>
      _put(_productsBox, 'all', jsonData);

  String? getCachedProducts() => _get(_productsBox, 'all');

  Future<void> cacheProductsByCategory(
    String categoryId,
    String jsonData,
  ) =>
      _put(_productsBox, 'cat_$categoryId', jsonData);

  String? getCachedProductsByCategory(String categoryId) =>
      _get(_productsBox, 'cat_$categoryId');

  Future<void> clearProductsCache() => _clearBox(_productsBox);

  // ── Cart ─────────────────────────────────────────────────────────────────────

  Future<void> cacheCart(String userId, String jsonData) =>
      _put(_cartBox, userId, jsonData);

  String? getCachedCart(String userId) => _get(_cartBox, userId);

  Future<void> clearCartCache(String userId) =>
      _delete(_cartBox, userId);

  // ── Categories ───────────────────────────────────────────────────────────────

  Future<void> cacheCategories(String jsonData) =>
      _put(_categoriesBox, 'all', jsonData);

  String? getCachedCategories() => _get(_categoriesBox, 'all');

  // ── Recipes ──────────────────────────────────────────────────────────────────

  Future<void> cacheRecipes(String jsonData) =>
      _put(_recipesBox, 'all', jsonData);

  String? getCachedRecipes() => _get(_recipesBox, 'all');

  // ── Deals ────────────────────────────────────────────────────────────────────

  Future<void> cacheDeals(String jsonData) =>
      _put(_dealsBox, 'all', jsonData);

  String? getCachedDeals() => _get(_dealsBox, 'all');

  // ── Meta / TTL ───────────────────────────────────────────────────────────────

  Future<void> setLastSync(String key) =>
      _put(_metaBox, 'sync_$key', DateTime.now().toIso8601String());

  bool isStale(String key, {Duration ttl = const Duration(minutes: 30)}) {
    final raw = _get(_metaBox, 'sync_$key');
    if (raw == null) return true;
    final lastSync = DateTime.tryParse(raw);
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > ttl;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await Future.wait([
      _clearBox(_productsBox),
      _clearBox(_cartBox),
      _clearBox(_categoriesBox),
      _clearBox(_recipesBox),
      _clearBox(_dealsBox),
      _clearBox(_metaBox),
    ]);
    Logger.info('All Hive boxes cleared', 'HiveService');
  }
}
