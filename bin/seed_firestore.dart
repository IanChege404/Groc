import 'dart:convert';
import 'dart:io';

/// Firestore seed payload generator.
///
/// This script:
/// 1. Reads Cloudinary URLs from `.cloudinary-map.json`
/// 2. Validates required image coverage
/// 3. Builds Firestore-compatible payload for categories/products/bundles
/// 4. Exports payload to JSON for audit/use by admin seeders
///
/// Usage:
///   dart run bin/seed_firestore.dart
///   dart run bin/seed_firestore.dart --dry-run
///   dart run bin/seed_firestore.dart --export=build/reports/seed_firestore.json
///   dart run bin/seed_firestore.dart --map-file=.cloudinary-map.json

class _SeedConfig {
  final String mapFilePath;
  final String exportPath;
  final bool dryRun;

  const _SeedConfig({
    required this.mapFilePath,
    required this.exportPath,
    required this.dryRun,
  });

  factory _SeedConfig.fromArgs(List<String> args) {
    var mapFilePath = '.cloudinary-map.json';
    var exportPath = 'build/reports/seed_firestore_payload.json';
    var dryRun = false;

    for (final arg in args) {
      if (arg == '--dry-run') {
        dryRun = true;
        continue;
      }

      if (arg.startsWith('--map-file=')) {
        mapFilePath = arg.substring('--map-file='.length).trim();
        continue;
      }

      if (arg.startsWith('--export=')) {
        exportPath = arg.substring('--export='.length).trim();
        continue;
      }

      if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      }

      stderr.writeln('Unknown argument: $arg');
      _printUsage();
      exit(2);
    }

    return _SeedConfig(
      mapFilePath: mapFilePath,
      exportPath: exportPath,
      dryRun: dryRun,
    );
  }
}

class _CloudinaryMap {
  final Map<String, String> byFileName;

  const _CloudinaryMap(this.byFileName);

  String? resolve(String fileName) => byFileName[fileName.toLowerCase()];
}

class _CategorySeed {
  final String id;
  final String name;
  final String description;
  final String iconFileName;
  final String color;

  const _CategorySeed({
    required this.id,
    required this.name,
    required this.description,
    required this.iconFileName,
    required this.color,
  });
}

class _ProductSeed {
  final String id;
  final String name;
  final String description;
  final String categoryName;
  final String categoryId;
  final double price;
  final double mainPrice;
  final int stock;
  final String imageFileName;
  final double rating;
  final int reviewCount;
  final String weight;

  const _ProductSeed({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.categoryId,
    required this.price,
    required this.mainPrice,
    required this.stock,
    required this.imageFileName,
    required this.rating,
    required this.reviewCount,
    required this.weight,
  });
}

class _BundleSeed {
  final String id;
  final String name;
  final String description;
  final String imageFileName;
  final List<String> itemNames;
  final List<String> productIds;
  final double price;
  final double mainPrice;
  final double rating;
  final int reviewCount;

  const _BundleSeed({
    required this.id,
    required this.name,
    required this.description,
    required this.imageFileName,
    required this.itemNames,
    required this.productIds,
    required this.price,
    required this.mainPrice,
    required this.rating,
    required this.reviewCount,
  });
}

void main(List<String> arguments) async {
  final config = _SeedConfig.fromArgs(arguments);

  print('=== Pro Grocery Firestore Seed Payload Generator ===\n');

  final cloudinaryMap = _loadCloudinaryMap(config.mapFilePath);
  final now = DateTime.now().toUtc().toIso8601String();

  final categories = _buildCategories(
    _categoriesSeed,
    cloudinaryMap,
    createdAtIso: now,
  );

  final products = _buildProducts(
    _productsSeed,
    cloudinaryMap,
    createdAtIso: now,
    updatedAtIso: now,
  );

  final bundles = _buildBundles(
    _bundlesSeed,
    cloudinaryMap,
    createdAtIso: now,
    updatedAtIso: now,
  );

  final payload = <String, dynamic>{
    'generatedAt': now,
    'sourceMapFile': config.mapFilePath,
    'collections': {
      'categories': categories,
      'products': products,
      'bundles': bundles,
    },
  };

  _printSummary(categories, products, bundles);

  if (!config.dryRun) {
    final exportFile = File(config.exportPath);
    exportFile.parent.createSync(recursive: true);
    exportFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    print('\n✓ Exported Firestore seed payload: ${exportFile.path}');
  } else {
    print('\n✓ Dry-run complete. No files written.');
  }

  print(
    '\nNext: run admin seeder at functions/src/seed_firestore.ts to write data.',
  );
}

_CloudinaryMap _loadCloudinaryMap(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Cloudinary map not found: $path');
    exit(2);
  }

  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final entries = decoded['entries'];
  if (entries is! List) {
    stderr.writeln('Invalid map format: missing "entries" list in $path');
    exit(2);
  }

  final byFileName = <String, String>{};
  for (final item in entries) {
    if (item is! Map<String, dynamic>) continue;
    final name = (item['fileName'] as String?)?.toLowerCase();
    final url = item['secureUrl'] as String?;
    if (name == null || name.isEmpty || url == null || url.isEmpty) {
      continue;
    }

    final existing = byFileName[name];
    if (existing != null && existing != url) {
      stderr.writeln(
        'Warning: duplicate Cloudinary entries for "$name". Keeping first URL.',
      );
      continue;
    }
    byFileName[name] = url;
  }

  return _CloudinaryMap(byFileName);
}

List<Map<String, dynamic>> _buildCategories(
  List<_CategorySeed> items,
  _CloudinaryMap map, {
  required String createdAtIso,
}) {
  return items
      .map(
        (item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'icon': _requiredImage(map, item.iconFileName),
          'color': item.color,
          'createdAt': createdAtIso,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _buildProducts(
  List<_ProductSeed> items,
  _CloudinaryMap map, {
  required String createdAtIso,
  required String updatedAtIso,
}) {
  return items
      .map(
        (item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'category': item.categoryName,
          'categoryId': item.categoryId,
          'price': item.price,
          'mainPrice': item.mainPrice,
          'stock': item.stock,
          'image': _requiredImage(map, item.imageFileName),
          'images': [_requiredImage(map, item.imageFileName)],
          'rating': item.rating,
          'reviewCount': item.reviewCount,
          'weight': item.weight,
          'createdAt': createdAtIso,
          'updatedAt': updatedAtIso,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _buildBundles(
  List<_BundleSeed> items,
  _CloudinaryMap map, {
  required String createdAtIso,
  required String updatedAtIso,
}) {
  return items
      .map(
        (item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'image': _requiredImage(map, item.imageFileName),
          'images': [_requiredImage(map, item.imageFileName)],
          'itemNames': item.itemNames,
          'productIds': item.productIds,
          'price': item.price,
          'mainPrice': item.mainPrice,
          'rating': item.rating,
          'reviewCount': item.reviewCount,
          'createdAt': createdAtIso,
          'updatedAt': updatedAtIso,
        },
      )
      .toList();
}

String _requiredImage(_CloudinaryMap map, String fileName) {
  final resolved = map.resolve(fileName);
  if (resolved == null) {
    stderr.writeln('Missing required Cloudinary URL for file: $fileName');
    exit(2);
  }
  return resolved;
}

void _printSummary(
  List<Map<String, dynamic>> categories,
  List<Map<String, dynamic>> products,
  List<Map<String, dynamic>> bundles,
) {
  print('Generated ${categories.length} categories:');
  for (final cat in categories) {
    print('  - ${cat['id']} :: ${cat['name']}');
  }

  print('\nGenerated ${products.length} products:');
  for (final prod in products) {
    print(
      '  - ${prod['id']} :: ${prod['name']} (${prod['weight']}) [${prod['category']}]',
    );
  }

  print('\nGenerated ${bundles.length} bundles:');
  for (final bundle in bundles) {
    print(
      '  - ${bundle['id']} :: ${bundle['name']} (products: ${(bundle['productIds'] as List).length})',
    );
  }
}

void _printUsage() {
  stdout.writeln('Firestore seed payload generator');
  stdout.writeln('Usage:');
  stdout.writeln('  dart run bin/seed_firestore.dart [options]');
  stdout.writeln('Options:');
  stdout.writeln(
    '  --dry-run                     Validate/generate only, no export',
  );
  stdout.writeln(
    '  --map-file=<path>             Cloudinary map (default: .cloudinary-map.json)',
  );
  stdout.writeln(
    '  --export=<path>               Output JSON payload (default: build/reports/seed_firestore_payload.json)',
  );
  stdout.writeln('  --help, -h                    Show help');
}

const List<_CategorySeed> _categoriesSeed = [
  _CategorySeed(
    id: 'category_dairy_eggs',
    name: 'Dairy & Eggs',
    description: 'Fresh milk, yogurt, cheese, and eggs',
    iconFileName: 'app_logo.png',
    color: '#E8F5E9',
  ),
  _CategorySeed(
    id: 'category_bakery',
    name: 'Bakery',
    description: 'Fresh bread, pastries, and baked goods',
    iconFileName: 'app_logo.png',
    color: '#FFF3E0',
  ),
  _CategorySeed(
    id: 'category_frozen_foods',
    name: 'Frozen Foods',
    description: 'Ice cream, frozen vegetables, and frozen meals',
    iconFileName: 'app_logo.png',
    color: '#E1F5FE',
  ),
  _CategorySeed(
    id: 'category_pantry_staples',
    name: 'Pantry Staples',
    description: 'Oil, salt, spices, and cooking essentials',
    iconFileName: 'app_logo.png',
    color: '#FCE4EC',
  ),
  _CategorySeed(
    id: 'category_meat_seafood',
    name: 'Meat & Seafood',
    description: 'Fresh meat, poultry, and seafood',
    iconFileName: 'app_logo.png',
    color: '#F3E5F5',
  ),
];

const List<_ProductSeed> _productsSeed = [
  _ProductSeed(
    id: 'product_perrys_ice_cream_banana_800gm',
    name: 'Perry\'s Ice Cream Banana',
    description:
        'Delicious banana-flavored ice cream by Perry\'s, perfect for dessert',
    categoryName: 'Frozen Foods',
    categoryId: 'category_frozen_foods',
    price: 13,
    mainPrice: 15,
    stock: 45,
    imageFileName: 'app_logo.png',
    rating: 4.5,
    reviewCount: 128,
    weight: '800 gm',
  ),
  _ProductSeed(
    id: 'product_vanilla_ice_cream_banana_500gm',
    name: 'Vanilla Ice Cream Banana',
    description:
        'Classic vanilla ice cream with banana flavor, smooth and creamy',
    categoryName: 'Frozen Foods',
    categoryId: 'category_frozen_foods',
    price: 12,
    mainPrice: 15,
    stock: 32,
    imageFileName: 'app_logo.png',
    rating: 4.3,
    reviewCount: 95,
    weight: '500 gm',
  ),
  _ProductSeed(
    id: 'product_premium_meat_selection_1kg',
    name: 'Premium Meat Selection',
    description: 'High-quality fresh meat, vacuum-sealed for optimal freshness',
    categoryName: 'Meat & Seafood',
    categoryId: 'category_meat_seafood',
    price: 15,
    mainPrice: 18,
    stock: 28,
    imageFileName: 'app_logo.png',
    rating: 4.7,
    reviewCount: 156,
    weight: '1 Kg',
  ),
  _ProductSeed(
    id: 'product_organic_onions_1kg',
    name: 'Organic Onions',
    description: 'Fresh organic onions, locally sourced and pesticide-free',
    categoryName: 'Pantry Staples',
    categoryId: 'category_pantry_staples',
    price: 3.5,
    mainPrice: 5,
    stock: 120,
    imageFileName: 'coupon_background_1.png',
    rating: 4.2,
    reviewCount: 42,
    weight: '1 Kg',
  ),
  _ProductSeed(
    id: 'product_premium_cooking_oil_1litre',
    name: 'Premium Cooking Oil',
    description: 'Pure vegetable oil, ideal for cooking and baking',
    categoryName: 'Pantry Staples',
    categoryId: 'category_pantry_staples',
    price: 8.5,
    mainPrice: 10,
    stock: 67,
    imageFileName: 'coupon_background_2.png',
    rating: 4.6,
    reviewCount: 89,
    weight: '1 Litre',
  ),
  _ProductSeed(
    id: 'product_sea_salt_premium_grade_500gm',
    name: 'Sea Salt - Premium Grade',
    description: 'Fine white sea salt for cooking and seasoning',
    categoryName: 'Pantry Staples',
    categoryId: 'category_pantry_staples',
    price: 2.5,
    mainPrice: 3.5,
    stock: 200,
    imageFileName: 'coupon_background_3.png',
    rating: 4.4,
    reviewCount: 73,
    weight: '500 gm',
  ),
  _ProductSeed(
    id: 'product_mixed_spice_collection_250gm',
    name: 'Mixed Spice Collection',
    description: 'Assorted premium spices for authentic cooking',
    categoryName: 'Pantry Staples',
    categoryId: 'category_pantry_staples',
    price: 12,
    mainPrice: 15,
    stock: 55,
    imageFileName: 'coupon_background_4.png',
    rating: 4.8,
    reviewCount: 167,
    weight: '250 gm',
  ),
  _ProductSeed(
    id: 'product_fresh_whole_milk_1litre',
    name: 'Fresh Whole Milk',
    description: 'Fresh whole milk, pasteurized and homogenized',
    categoryName: 'Dairy & Eggs',
    categoryId: 'category_dairy_eggs',
    price: 3.2,
    mainPrice: 4,
    stock: 89,
    imageFileName: 'profile_page_background.png',
    rating: 4.5,
    reviewCount: 134,
    weight: '1 Litre',
  ),
];

const List<_BundleSeed> _bundlesSeed = [
  _BundleSeed(
    id: 'bundle_essential_cooking_pack',
    name: 'Essential Cooking Bundle Pack',
    description: 'Everything you need for basic cooking: onions, oil, and salt',
    imageFileName: 'coupon_background_1.png',
    itemNames: ['Onion 1Kg', 'Cooking Oil 1L', 'Sea Salt 500gm'],
    productIds: [
      'product_organic_onions_1kg',
      'product_premium_cooking_oil_1litre',
      'product_sea_salt_premium_grade_500gm',
    ],
    price: 12.5,
    mainPrice: 16.5,
    rating: 4.6,
    reviewCount: 234,
  ),
  _BundleSeed(
    id: 'bundle_premium_spices',
    name: 'Premium Spices Bundle',
    description: 'Complete spice collection for exotic and traditional dishes',
    imageFileName: 'coupon_background_2.png',
    itemNames: ['Mixed Spices 250gm', 'Cooking Oil 1L'],
    productIds: [
      'product_mixed_spice_collection_250gm',
      'product_premium_cooking_oil_1litre',
    ],
    price: 18,
    mainPrice: 22,
    rating: 4.7,
    reviewCount: 156,
  ),
  _BundleSeed(
    id: 'bundle_frozen_dessert',
    name: 'Frozen Dessert Bundle',
    description: 'Ice cream treats for the whole family',
    imageFileName: 'coupon_background_3.png',
    itemNames: ['Perry\'s Ice Cream 800gm', 'Vanilla Ice Cream 500gm'],
    productIds: [
      'product_perrys_ice_cream_banana_800gm',
      'product_vanilla_ice_cream_banana_500gm',
    ],
    price: 22,
    mainPrice: 28,
    rating: 4.8,
    reviewCount: 289,
  ),
  _BundleSeed(
    id: 'bundle_complete_breakfast',
    name: 'Complete Breakfast Bundle',
    description: 'Fresh dairy products for a complete breakfast',
    imageFileName: 'coupon_background_4.png',
    itemNames: ['Fresh Milk 1L', 'Mixed Spices 250gm'],
    productIds: [
      'product_fresh_whole_milk_1litre',
      'product_mixed_spice_collection_250gm',
    ],
    price: 13.5,
    mainPrice: 17,
    rating: 4.5,
    reviewCount: 198,
  ),
];
