import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../views/auth/forget_password_page.dart';
import '../../views/auth/intro_login_page.dart';
import '../../views/auth/language_select_screen.dart';
import '../../views/auth/login_or_signup_page.dart';
import '../../views/auth/login_page.dart';
import '../../views/auth/number_verification_page.dart';
import '../../views/auth/password_reset_page.dart';
import '../../views/auth/sign_up_page.dart';
import '../../views/splash/video_splash_screen.dart';
import '../../views/cart/cart_page.dart';
import '../../views/cart/checkout_page.dart';
import '../../views/cart/delivery_method_screen.dart';
import '../../views/cart/m_pesa_processing_screen.dart';
import '../../views/drawer/about_us_page.dart';
import '../../views/drawer/contact_us_page.dart';
import '../../views/drawer/drawer_page.dart';
import '../../views/drawer/faq_page.dart';
import '../../views/drawer/help_page.dart';
import '../../views/drawer/privacy_policy_page.dart';
import '../../views/drawer/terms_and_conditions_page.dart';
import '../../views/entrypoint/entrypoint_ui.dart';
import '../../views/home/home_page.dart';
import '../../views/home/bundle_create_page.dart';
import '../../views/home/bundle_details_page.dart';
import '../../views/home/bundle_product_details_page.dart';
import '../../views/home/new_item_page.dart';
import '../../views/home/order_failed_page.dart';
import '../../views/home/order_successfull_page.dart';
import '../../views/home/popular_pack_page.dart';
import '../../views/home/product_details_page.dart';
import '../../views/home/search_page.dart';
import '../../views/home/search_result_page.dart';
import '../../views/menu/category_page.dart';
import '../../views/onboarding/onboarding_page.dart';
import '../../views/profile/address/address_page.dart';
import '../../views/profile/address/new_address_page.dart';
import '../../views/profile/coupon/coupon_details_page.dart';
import '../../views/profile/coupon/coupon_page.dart';
import '../../views/profile/notification_page.dart';
import '../../views/profile/order/my_order_page.dart';
import '../../views/profile/order/order_details.dart';
import '../../views/profile/order_tracking_screen.dart';
import '../../views/profile/payment_method/add_new_card_page.dart';
import '../../views/checkout/payment_selection_screen.dart';
import '../../views/checkout/card_payment_screen.dart';
import '../../views/checkout/web_payment_screen.dart';
import '../../views/recipes/recipes_screen.dart';
import '../../views/recipes/recipe_detail_screen.dart';
import '../../views/deals/flash_deals_screen.dart';
import '../../views/loyalty/loyalty_points_screen.dart';
import '../../views/profile/wallet_screen.dart';
import '../../views/profile/payment_method/payment_method_page.dart';
import '../../views/profile/profile_edit_page.dart';
import '../../views/profile/profile_page.dart';
import '../../views/profile/settings/change_password_page.dart';
import '../../views/profile/settings/change_phone_number_page.dart';
import '../../views/profile/settings/language_settings_page.dart';
import '../../views/profile/settings/location_settings_page.dart';
import '../../views/profile/settings/notifications_settings_page.dart';
import '../../views/profile/settings/settings_page.dart';
import '../../views/review/review_page.dart';
import '../../views/review/submit_review_page.dart';
import '../../views/save/save_page.dart';
import '../../views/referral/referral_page.dart';
import '../../views/referral/referral_code_entry_screen.dart';
import '../../views/home/ai_search_page.dart';
import '../../views/home/bundle_edit_page.dart';
import '../../views/home/my_bundles_page.dart';
import '../../core/models/bundle_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/coupon_model.dart';
import '../../core/models/recipe_model.dart';
import 'unknown_page.dart';

bool _isAuthenticated() => FirebaseAuth.instance.currentUser != null;

/// Helper function to create a custom transition page with slide and fade animations
CustomTransitionPage<T> _buildTransitionPage<T>({
  required Widget child,
  required String name,
}) {
  return CustomTransitionPage<T>(
    name: name,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: animation, curve: Curves.easeInOutCubic)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = _isAuthenticated();
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/loginOrSignup' ||
        state.matchedLocation == '/forgotPassword' ||
        state.matchedLocation == '/passwordReset' ||
        state.matchedLocation == '/onboarding' ||
        state.matchedLocation == '/languageSelect';

    final protectedPaths = [
      '/cartPage',
      '/checkoutPage',
      '/deliveryMethod',
      '/mpesaProcessing',
      '/myOrder',
      '/orderDetails',
      '/orderTracking',
      '/deliveryAddress',
      '/newAddress',
      '/paymentMethod',
      '/paymentCardAdd',
      '/wallet',
      '/profileEdit',
      '/notifications',
      '/settings',
      '/settingsLanguage',
      '/settingsNotifications',
      '/settingsLocation',
      '/changePassword',
      '/changePhoneNumber',
      '/profile',
      '/coupon',
      '/couponDetails',
      '/review',
      '/submitReview',
      '/paymentSelection',
      '/cardPayment',
      '/loyaltyPoints',
      '/referral',
      '/referralCodeEntry',
      '/aiSearch',
      '/bundleEdit',
      '/myBundles',
    ];

    final isProtected = protectedPaths.any(
      (path) => state.matchedLocation == path,
    );

    if (isProtected && !isLoggedIn) {
      return '/loginOrSignup';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/entry_point';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VideoSplashScreen(),
    ),
    GoRoute(
      path: '/intro_login',
      builder: (context, state) => const IntroLoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/languageSelect',
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: '/entry_point',
      builder: (context, state) => const EntryPointUI(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/searchResult',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final query = extra?['query'] as String?;
        return _buildTransitionPage(
          name: 'searchResult',
          child: SearchResultPage(initialQuery: query),
        );
      },
    ),
    GoRoute(
      path: '/cartPage',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'cartPage',
        child: const CartPage(),
      ),
    ),
    GoRoute(
      path: '/favouriteList',
      builder: (context, state) => const SavePage(),
    ),
    GoRoute(
      path: '/checkoutPage',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'checkoutPage',
        child: const CheckoutPage(),
      ),
    ),
    GoRoute(
      path: '/deliveryMethod',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'deliveryMethod',
        child: const DeliveryMethodScreen(),
      ),
    ),
    GoRoute(
      path: '/mpesaProcessing',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildTransitionPage(
          name: 'mpesaProcessing',
          child: MpesaProcessingScreen(
            amount: extra?['amount'] ?? 0.0,
            phoneNumber: extra?['phoneNumber'] ?? '+254 XXX XXX XXX',
            orderId: extra?['orderId'] ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/categoryDetails',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildTransitionPage(
          name: 'categoryDetails',
          child: CategoryProductPage(
            categoryId: extra?['categoryId'] as String?,
            categoryName: extra?['categoryName'] as String?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/loginOrSignup',
      builder: (context, state) => const LoginOrSignUpPage(),
    ),
    GoRoute(
      path: '/numberVerification',
      builder: (context, state) => const NumberVerificationPage(),
    ),
    GoRoute(
      path: '/forgotPassword',
      builder: (context, state) => const ForgetPasswordPage(),
    ),
    GoRoute(
      path: '/passwordReset',
      builder: (context, state) => const PasswordResetPage(),
    ),
    GoRoute(
      path: '/newItems',
      builder: (context, state) => const NewItemsPage(),
    ),
    GoRoute(
      path: '/popularItems',
      builder: (context, state) => const PopularPackPage(),
    ),
    GoRoute(
      path: '/bundleProduct',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildTransitionPage(
          name: 'bundleProduct',
          child: BundleProductDetailsPage(
            bundle: extra?['bundle'] as BundleModel?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/bundleDetailsPage',
      builder: (context, state) => const BundleDetailsPage(),
    ),
    GoRoute(
      path: '/productDetails',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildTransitionPage(
          name: 'productDetails',
          child: ProductDetailsPage(
            product: extra?['product'] as ProductModel?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/createMyPack',
      builder: (context, state) => const BundleCreatePage(),
    ),
    GoRoute(
      path: '/orderSuccessfull',
      builder: (context, state) => const OrderSuccessfullPage(),
    ),
    GoRoute(
      path: '/orderFailed',
      builder: (context, state) => const OrderFailedPage(),
    ),
    GoRoute(
      path: '/myOrder',
      builder: (context, state) => const AllOrderPage(),
    ),
    GoRoute(
      path: '/orderDetails',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildTransitionPage(
          name: 'orderDetails',
          child: OrderDetailsPage(orderId: extra?['orderId'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: '/coupon',
      builder: (context, state) => const CouponAndOffersPage(),
    ),
    GoRoute(
      path: '/couponDetails',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CouponDetailsPage(
          coupon: extra?['coupon'] as CouponModel?,
        );
      },
    ),
    GoRoute(
      path: '/profileEdit',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'profileEdit',
        child: const ProfileEditPage(),
      ),
    ),
    GoRoute(
      path: '/newAddress',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'newAddress',
        child: const NewAddressPage(),
      ),
    ),
    GoRoute(
      path: '/deliveryAddress',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'deliveryAddress',
        child: const AddressPage(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: '/settingsNotifications',
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'settings',
        child: const SettingsPage(),
      ),
    ),
    GoRoute(
      path: '/settingsLanguage',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'settingsLanguage',
        child: const LanguageSettingsPage(),
      ),
    ),
    GoRoute(
      path: '/settingsLocation',
      builder: (context, state) => const LocationSettingsPage(),
    ),
    GoRoute(
      path: '/changePassword',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/changePhoneNumber',
      builder: (context, state) => const ChangePhoneNumberPage(),
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ReviewPage(
          productId: extra?['productId'] ?? '',
          productName: extra?['productName'],
          productImage: extra?['productImage'],
        );
      },
    ),
    GoRoute(
      path: '/submitReview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SubmitReviewPage(
          productId: extra?['productId'] ?? '',
          productName: extra?['productName'],
          productImage: extra?['productImage'],
        );
      },
    ),
    GoRoute(
      path: '/drawerPage',
      builder: (context, state) => const DrawerPage(),
    ),
    GoRoute(
      path: '/aboutUs',
      builder: (context, state) => const AboutUsPage(),
    ),
    GoRoute(
      path: '/termsAndConditions',
      builder: (context, state) => const TermsAndConditionsPage(),
    ),
    GoRoute(
      path: '/faq',
      builder: (context, state) => const FAQPage(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpPage(),
    ),
    GoRoute(
      path: '/contactUs',
      builder: (context, state) => const ContactUsPage(),
    ),
    GoRoute(
      path: '/privacyPolicy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/paymentMethod',
      builder: (context, state) => const PaymentMethodPage(),
    ),
    GoRoute(
      path: '/paymentCardAdd',
      builder: (context, state) => const AddNewCardPage(),
    ),
    GoRoute(
      path: '/paymentSelection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentSelectionScreen(
          amount: (extra?['amount'] as num?)?.toDouble() ?? 0.0,
          orderId: extra?['orderId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/cardPayment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CardPaymentScreen(
          amount: (extra?['amount'] as num?)?.toDouble() ?? 0.0,
          orderId: extra?['orderId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/stripePayment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WebPaymentScreen(
          provider: WebPaymentProvider.stripe,
          amount: (extra?['amount'] as num?)?.toDouble() ?? 0.0,
          orderId: extra?['orderId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/paypalPayment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WebPaymentScreen(
          provider: WebPaymentProvider.paypal,
          amount: (extra?['amount'] as num?)?.toDouble() ?? 0.0,
          orderId: extra?['orderId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipesScreen(),
    ),
    GoRoute(
      path: '/recipeDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final recipe = extra?['recipe'] as RecipeModel?;
        if (recipe == null) return const UnknownPage();
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/flashDeals',
      builder: (context, state) => const FlashDealsScreen(),
    ),
    GoRoute(
      path: '/loyaltyPoints',
      builder: (context, state) => const LoyaltyPointsScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/orderTracking',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OrderTrackingScreen(orderId: extra?['orderId'] ?? '');
      },
    ),
    GoRoute(
      path: '/referral',
      builder: (context, state) => const ReferralPage(),
    ),
    GoRoute(
      path: '/referralCodeEntry',
      builder: (context, state) => const ReferralCodeEntryScreen(),
    ),
    GoRoute(
      path: '/aiSearch',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AiSearchPage(initialQuery: extra?['query'] as String?);
      },
    ),
    GoRoute(
      path: '/bundleEdit',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final bundle = extra?['bundle'] as BundleModel?;
        if (bundle == null) return const UnknownPage();
        return BundleEditPage(bundle: bundle);
      },
    ),
    GoRoute(
      path: '/myBundles',
      builder: (context, state) => const MyBundlesPage(),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildTransitionPage(
        name: 'profile',
        child: const ProfilePage(),
      ),
    ),
  ],
);
