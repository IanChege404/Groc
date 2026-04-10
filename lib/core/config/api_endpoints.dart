import 'env_config.dart';

class ApiEndpoints {
  // Base URL
  static String get baseUrl => EnvConfig.apiBaseUrl();

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String passwordReset = '/auth/password-reset';
  static const String verifyOtp = '/auth/verify-otp';

  // Product Endpoints
  static const String getProducts = '/products';
  static String getProductById(String id) => '/products/$id';
  static const String getNewProducts = '/products/new';
  static const String getPopularProducts = '/products/popular';
  static const String searchProducts = '/products/search';
  static String getProductsByCategory(String categoryId) =>
      '/products/category/$categoryId';

  // Cart Endpoints
  static const String getCart = '/cart';
  static const String addToCart = '/cart/items';
  static String removeFromCart(String itemId) => '/cart/items/$itemId';
  static String updateCartItem(String itemId) => '/cart/items/$itemId';
  static const String clearCart = '/cart/clear';

  // Order Endpoints
  static const String createOrder = '/orders';
  static const String getOrders = '/orders';
  static String getOrderById(String orderId) => '/orders/$orderId';
  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';
  static String trackOrder(String orderId) => '/orders/$orderId/track';

  // Payment Endpoints
  static const String initiatePayment = '/payments/initiate';
  static const String mpesaPayment = '/payments/mpesa';
  static String confirmPayment(String paymentId) =>
      '/payments/$paymentId/confirm';
  static String getPaymentStatus(String paymentId) =>
      '/payments/$paymentId/status';

  // Profile Endpoints
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile';
  static const String getAddresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses';
  static String updateAddress(String addressId) =>
      '/profile/addresses/$addressId';
  static String deleteAddress(String addressId) =>
      '/profile/addresses/$addressId';

  // Wishlist/Favorites Endpoints
  static const String getWishlist = '/wishlist';
  static const String addToWishlist = '/wishlist';
  static String removeFromWishlist(String productId) => '/wishlist/$productId';

  // Review Endpoints
  static const String getProductReviews = '/reviews';
  static const String submitReview = '/reviews';
  static String updateReview(String reviewId) => '/reviews/$reviewId';

  // Category Endpoints
  static const String getCategories = '/categories';
  static String getCategoryById(String id) => '/categories/$id';

  // Bundle/Promo Endpoints
  static const String getBundles = '/bundles';
  static String getBundleById(String id) => '/bundles/$id';
  static const String getPromos = '/promos';

  // Support Endpoints
  static const String contactSupport = '/support/contact';
  static const String getFaq = '/support/faq';
  static const String getTerms = '/support/terms';
  static const String getPrivacy = '/support/privacy';
}
