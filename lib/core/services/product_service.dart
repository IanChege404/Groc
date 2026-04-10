import '../config/api_endpoints.dart';
import '../network/api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  /// Get all products with pagination
  Future<ApiResponse<PaginatedProducts>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
    String? sortBy,
  }) {
    return _apiClient.get<PaginatedProducts>(
      ApiEndpoints.getProducts,
      queryParameters: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
      },
      fromJson: (json) => PaginatedProducts.fromJson(json),
    );
  }

  /// Get product by ID
  Future<ApiResponse<Product>> getProductById(String id) {
    return _apiClient.get<Product>(
      ApiEndpoints.getProductById(id),
      fromJson: (json) => Product.fromJson(json),
    );
  }

  /// Get new products
  Future<ApiResponse<List<Product>>> getNewProducts({int limit = 10}) {
    return _apiClient.get<List<Product>>(
      ApiEndpoints.getNewProducts,
      queryParameters: {'limit': limit.toString()},
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Product.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Get popular/trending products
  Future<ApiResponse<List<Product>>> getPopularProducts({int limit = 10}) {
    return _apiClient.get<List<Product>>(
      ApiEndpoints.getPopularProducts,
      queryParameters: {'limit': limit.toString()},
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Product.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Search products
  Future<ApiResponse<List<Product>>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _apiClient.get<List<Product>>(
      ApiEndpoints.searchProducts,
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Product.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Get products by category
  Future<ApiResponse<List<Product>>> getProductsByCategory(
    String categoryId, {
    int page = 1,
  }) {
    return _apiClient.get<List<Product>>(
      ApiEndpoints.getProductsByCategory(categoryId),
      queryParameters: {'page': page.toString()},
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Product.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Get all categories
  Future<ApiResponse<List<Category>>> getCategories() {
    return _apiClient.get<List<Category>>(
      ApiEndpoints.getCategories,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Category.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Get category by ID
  Future<ApiResponse<Category>> getCategoryById(String id) {
    return _apiClient.get<Category>(
      ApiEndpoints.getCategoryById(id),
      fromJson: (json) => Category.fromJson(json),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final String? image;
  final List<String>? images;
  final String categoryId;
  final int stock;
  final Map<String, String>? attributes;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.image,
    this.images,
    required this.categoryId,
    this.stock = 0,
    this.attributes,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      image: json['image'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      categoryId: json['category_id'] as String,
      stock: json['stock'] as int? ?? 0,
      attributes: (json['attributes'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'rating': rating,
      'review_count': reviewCount,
      'image': image,
      'images': images,
      'category_id': categoryId,
      'stock': stock,
      'attributes': attributes,
      'is_favorite': isFavorite,
    };
  }

  bool get isOnSale => discountPrice != null && discountPrice! < price;

  double get discountPercentage {
    if (!isOnSale) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  double get effectivePrice => discountPrice ?? price;
}

class PaginatedProducts {
  final List<Product> products;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  PaginatedProducts({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final productsList = (json['data'] as List<dynamic>?)
            ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return PaginatedProducts(
      products: productsList,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': products.map((p) => p.toJson()).toList(),
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_count': totalCount,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'image': image,
    };
  }
}
