// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Afri-Commerce';

  @override
  String get appTagline => 'Your Market, Everywhere';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboarding1Title => 'Discover Local Markets';

  @override
  String get onboarding1Subtitle =>
      'Shop from thousands of African vendors, right from your phone';

  @override
  String get onboarding2Title => 'Everything In One Place';

  @override
  String get onboarding2Subtitle =>
      'Groceries, fashion, electronics — all delivered to you';

  @override
  String get onboarding3Title => 'Pay the Way You Know';

  @override
  String get onboarding3Subtitle =>
      'M-Pesa, Airtel Money, card, or cash on delivery';

  @override
  String get onboarding4Title => 'Track Every Order';

  @override
  String get onboarding4Subtitle =>
      'Real-time tracking from seller to your door';

  @override
  String get chooseLanguage => 'Choose Your Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get continueAction => 'Continue';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get login => 'Log In';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => '— or continue with —';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get termsAgreement => 'I agree to the Terms & Privacy Policy';

  @override
  String get continueWithEmailOrPhone => 'Continue with Email or Phone';

  @override
  String get createAccount => 'Create an account';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get resetPasswordDescription =>
      'Please enter your number. We will send a code\nto your phone to reset your password.';

  @override
  String get sendMeLink => 'Send me link';

  @override
  String get welcomeToOur => 'Welcome to our';

  @override
  String get eGrocery => 'E-Grocery';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get enterYourDigitCode => 'Enter your 4-digit code';

  @override
  String get didntGetCode => 'Didn\'t get your code?';

  @override
  String get resend => 'Resend';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verify => 'Verify';

  @override
  String get pleaseEnterAllDigits => 'Please enter all 4 digits';

  @override
  String weSentCodeTo(Object phoneNumber) {
    return 'We sent a 6-digit code to $phoneNumber';
  }

  @override
  String resendCodeIn(Object minutes, Object seconds) {
    return 'Resend code in $minutes:$seconds';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get changeNumber => 'Change number';

  @override
  String get verified => 'Verified!';

  @override
  String get verifiedSuccessMessage =>
      'You have successfully\nverified your account.';

  @override
  String get browseHome => 'Browse Home';

  @override
  String get invalidOtp => 'Invalid code. Please try again.';

  @override
  String get phoneVerificationFailed =>
      'Phone verification failed. Please try again.';

  @override
  String get newPassword => 'New Password';

  @override
  String get addNewPassword => 'Add New Password';

  @override
  String get done => 'Done';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully';

  @override
  String get passwordUpdateFailed => 'Password update failed';

  @override
  String get pleaseSignInAgain => 'Please sign in again';

  @override
  String get errorUpdatingPassword => 'Error updating password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordResetLinkSent => 'Password reset link sent to your phone';

  @override
  String get failedToSendResetLink =>
      'Failed to send reset link. Please try again.';

  @override
  String get googleSignInSuccess => 'Signed in with Google';

  @override
  String get googleSignInFailed => 'Sign in failed. Please try again.';

  @override
  String get appleSignInComingSoon => 'Apple Sign-In coming soon';

  @override
  String get otpVerificationComingSoon => 'OTP verification coming soon';

  @override
  String get loginWithEmail => 'Login With Email';

  @override
  String get groceryShop => 'grocery shop';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMustHaveSpecialChar =>
      'Password must have at least one special character';

  @override
  String get fullName => 'Full Name';

  @override
  String get displayName => 'Display Name';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get phoneHint => 'Enter your phone number';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get emailOptional => 'Email (for receipts)';

  @override
  String get city => 'City/Town';

  @override
  String get termsAndConditions => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String requiredField(Object field) {
    return '$field is required';
  }

  @override
  String get loginFailed =>
      'Login failed. Please check your credentials and try again.';

  @override
  String get signupFailed =>
      'Sign up failed. Please check your details and try again.';

  @override
  String greeting1(Object name) {
    return 'Habari, $name 👋';
  }

  @override
  String greeting2(Object name) {
    return 'Habari Asubuhi, $name';
  }

  @override
  String greetingAfternoon(Object name) {
    return 'Habari Mchana, $name';
  }

  @override
  String greetingEvening(Object name) {
    return 'Habari Jioni, $name';
  }

  @override
  String deliveringTo(Object location) {
    return 'Delivering to: $location';
  }

  @override
  String get searchProducts => 'Search products, shops...';

  @override
  String get flashSales => 'Flash Sales';

  @override
  String get topSellersNearYou => 'Top Sellers Near You';

  @override
  String get freshPicks => 'Fresh Picks';

  @override
  String get seeAll => 'See All';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get productList => 'Products';

  @override
  String get categories => 'Categories';

  @override
  String get filters => 'Filters';

  @override
  String get sort => 'Sort';

  @override
  String get relevance => 'Relevance';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get newest => 'Newest';

  @override
  String get rating => 'Rating';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get productDetails => 'Product Details';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String onlyNLeft(Object count) {
    return 'Only $count left';
  }

  @override
  String get notifyMe => 'Notify Me';

  @override
  String get sizeGuide => 'Size Guide';

  @override
  String get viewShop => 'View Shop';

  @override
  String get chatSeller => 'Chat Seller';

  @override
  String deliveredTo(Object location) {
    return 'Delivered to: $location';
  }

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String deliveryFee(Object fee) {
    return 'Delivery Fee: $fee';
  }

  @override
  String estimatedDelivery(Object date) {
    return 'Est. Delivery: $date';
  }

  @override
  String get returnPolicy => '7-day Returns';

  @override
  String get reviews => 'Reviews';

  @override
  String seeAllReviews(Object count) {
    return 'See all $count reviews';
  }

  @override
  String get search => 'Search';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearAll => 'Clear All';

  @override
  String get trendingSearches => 'Trending Searches';

  @override
  String get yourCartIsEmpty => 'Your Cart is Empty';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String cartItems(Object count) {
    return '$count items';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get applyCoupon => 'Apply Coupon';

  @override
  String get couponCode => 'Coupon Code';

  @override
  String get remove => 'Remove';

  @override
  String get quantity => 'Quantity';

  @override
  String get checkout => 'Checkout';

  @override
  String get step1 => 'Address';

  @override
  String get step2 => 'Delivery';

  @override
  String get step3 => 'Review';

  @override
  String get step4 => 'Payment';

  @override
  String get selectAddress => 'Select Delivery Address';

  @override
  String get addNewAddress => '+ Add New Address';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get deliveryMethod => 'Delivery Method';

  @override
  String get standardDelivery => 'Standard Delivery';

  @override
  String get expressDelivery => 'Express Delivery';

  @override
  String get sameDayDelivery => 'Same-Day Delivery (Today)';

  @override
  String get storePickup => 'Store Pickup';

  @override
  String get free => 'FREE';

  @override
  String get reviewOrder => 'Review & Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get mPesa => 'M-Pesa';

  @override
  String get airtelMoney => 'Airtel Money';

  @override
  String get debitCard => 'Debit/Credit Card';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get afriWallet => 'Afri Wallet';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get checkYourPhone => 'Check your phone';

  @override
  String mPesaPaymentRequest(Object phoneNumber) {
    return 'We\'ve sent a payment request to $phoneNumber. Enter your M-Pesa PIN to complete.';
  }

  @override
  String get requestExpiresIn => 'Request expires in';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get payNow => 'Pay Now';

  @override
  String get processingPayment => 'Processing...';

  @override
  String get confirmPaymentTitle => 'Confirm Payment';

  @override
  String confirmPaymentMessage(Object amount, Object phone) {
    return 'Confirm payment of KES $amount to $phone?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get selectPaymentSystem => 'Select Payment System';

  @override
  String get cardName => 'Card Name';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expirationDate => 'Expiration Date';

  @override
  String get cvv => 'CVV';

  @override
  String get rememberCardDetails => 'Remember card details';

  @override
  String increaseQuantity(Object productName, Object quantity) {
    return 'Increase $productName quantity to $quantity';
  }

  @override
  String decreaseQuantity(Object productName, Object quantity) {
    return 'Decrease $productName quantity to $quantity';
  }

  @override
  String removeFromCart(Object productName) {
    return 'Remove $productName from cart';
  }

  @override
  String paymentMethodSelected(Object label) {
    return '$label, selected';
  }

  @override
  String paymentMethodNotSelected(Object label) {
    return '$label, not selected';
  }

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get orderCreationFailed => 'Failed to create order';

  @override
  String get retry => 'Retry';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String orderNumber(Object number) {
    return 'Order #$number';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get continueShoppingBtn => 'Continue Shopping';

  @override
  String get share => 'Share';

  @override
  String get myOrders => 'My Orders';

  @override
  String get myOrder => 'My Order';

  @override
  String get allOrders => 'All Orders';

  @override
  String get activeOrders => 'Active';

  @override
  String get completedOrders => 'Completed';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get pending => 'Pending';

  @override
  String get outForDelivery => 'Out for Delivery';

  @override
  String get delivery => 'Delivery';

  @override
  String get returns => 'Returns';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get reorder => 'Reorder';

  @override
  String get returnItem => 'Return Item';

  @override
  String get noOrdersYet => 'No Orders Yet';

  @override
  String get noOrdersYetDescription => 'You haven\'t placed any orders yet.';

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get noCompletedOrders => 'No completed orders';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get trackMyOrder => 'Track My Order';

  @override
  String get orderId => 'Order ID';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get status => 'Status';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get paidFrom => 'Paid From';

  @override
  String get orderPlacedSuccess => 'Order Placed Successfully';

  @override
  String get orderPlacedSuccessDesc =>
      'Thanks for your order. Your order has been placed successfully. You can track your order status from My Orders.';

  @override
  String get orderFailedTitle => 'Order Failed';

  @override
  String get orderFailedDesc =>
      'Payment could not be processed. Please try again or contact support if the issue persists.';

  @override
  String get orderConfirmation => 'Order Confirmed!';

  @override
  String get orderConfirmationDesc =>
      'Your order has been confirmed. We\'ll notify you when it ships.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get goToOrders => 'Go to Orders';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivery => 'Out for Delivery';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderDetails => 'Order Details';

  @override
  String placedOn(Object date) {
    return 'Placed on $date';
  }

  @override
  String estimatedDeliveryDate(Object date) {
    return 'Est. Delivery: $date';
  }

  @override
  String get orderConfirmed => 'Order Confirmed';

  @override
  String get processingOrder => 'Processing Order';

  @override
  String get itemShipped => 'Item Shipped';

  @override
  String get itemDelivered => 'Item Delivered';

  @override
  String get tracking => 'Tracking';

  @override
  String riderLocation(Object name) {
    return '$name is on the way!';
  }

  @override
  String distance(Object distance) {
    return '$distance km away';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myAddresses => 'Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get afriWalletBalance => 'Afri Wallet';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get transactions => 'Transactions';

  @override
  String get wallet => 'Wallet';

  @override
  String get topUp => 'Top Up';

  @override
  String get send => 'Send';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get balance => 'Balance';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get helpCenter => 'Help Centre';

  @override
  String get chatSupport => 'Chat Support';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get aboutUs => 'About Us';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get signOut => 'Sign Out';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get howCanWeHelp => 'How can we help you?';

  @override
  String get sendMessage => 'Send';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get searchField => 'Search Field';

  @override
  String get startTypingToSearch => 'Start typing to search products';

  @override
  String searchResultsFor(Object query) {
    return 'Search results for \"$query\"';
  }

  @override
  String get enterProductNameToSearch => 'Enter a product name to search';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get newItems => 'New Items';

  @override
  String get createBundle => 'Create Bundle';

  @override
  String get createMyBundle => 'Create My Bundle';

  @override
  String get myBundles => 'My Bundles';

  @override
  String get editBundle => 'Edit Bundle';

  @override
  String get bundleDetails => 'Bundle Details';

  @override
  String get bundleName => 'Bundle Name';

  @override
  String get description => 'Description';

  @override
  String get pricing => 'Pricing';

  @override
  String get priceKes => 'Price (KES)';

  @override
  String get discountPrice => 'Discount Price';

  @override
  String get productsInBundle => 'Products in Bundle';

  @override
  String get addProduct => 'Add Product';

  @override
  String get addProductComingSoon => 'Add product functionality coming soon';

  @override
  String get removeProductComingSoon =>
      'Remove product functionality coming soon';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deleteBundle => 'Delete Bundle';

  @override
  String get bundleUpdatedSuccessfully => 'Bundle updated successfully!';

  @override
  String get bundleDeleted => 'Bundle deleted';

  @override
  String get noBundlesYet => 'No Bundles Yet';

  @override
  String get createFirstBundleToSave =>
      'Create your first bundle to save money';

  @override
  String get popularPacks => 'Popular Packs';

  @override
  String get ourNewItem => 'Our New Item';

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get checkConnectionAndRetry =>
      'Check your internet connection and try again.';

  @override
  String get failedToSearchProducts =>
      'Check your connection and try searching again.';

  @override
  String get tryDifferentKeywords => 'Try searching with different keywords';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get failedToLoadNewItems => 'Could not load new items';

  @override
  String get failedToLoadPopularPacks => 'Could not load popular packs';

  @override
  String get errorLoadingData => 'Something went wrong loading data';

  @override
  String get aiSearch => 'AI Search';

  @override
  String get searchProductsHint => 'Search products...';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get startSearching => 'Start Searching';

  @override
  String get typeForAiRecommendations =>
      'Type to see AI-powered recommendations';

  @override
  String noResultsForQuery(Object query) {
    return 'No products found for \"$query\"';
  }

  @override
  String get browseCatalog => 'Browse Catalog';

  @override
  String resultsFound(Object count) {
    return '$count results found';
  }

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort By';

  @override
  String get popularity => 'Popularity';

  @override
  String get priceRange => 'Price Range';

  @override
  String get brand => 'Brand';

  @override
  String get ratingStar => 'Rating Star';

  @override
  String get any => 'Any';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get deleteBundleQuestion => 'Delete Bundle?';

  @override
  String get deleteBundleWarning =>
      'This action cannot be undone. All bundle data will be permanently removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDelete => 'Delete';

  @override
  String typeDeleteToConfirm(Object name) {
    return 'Type \"$name\" to confirm deletion';
  }

  @override
  String productLabel(Object name, Object price, Object rating) {
    return '$name, KES $price, $rating stars';
  }

  @override
  String addToWishlistLabel(Object name) {
    return 'Add $name to wishlist';
  }

  @override
  String removeFromWishlistLabel(Object name) {
    return 'Remove $name from wishlist';
  }

  @override
  String get addedToWishlist => 'Added to wishlist';

  @override
  String get removedFromWishlist => 'Removed from wishlist';

  @override
  String get failedToUpdateWishlist => 'Could not update wishlist';

  @override
  String items(Object count) {
    return '$count items';
  }

  @override
  String get price => 'Price';

  @override
  String get officeSupplies => 'Office Supplies';

  @override
  String get gardening => 'Gardening';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fishAndMeat => 'Fish And Meat';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgainLater => 'Please try again later';

  @override
  String get noInternet => 'No Internet Connection';

  @override
  String get checkConnection => 'Please check your internet connection';

  @override
  String get noResults => 'No Results Found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get goHome => 'Go Home';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get success => 'Success!';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get searchHint => 'Search';

  @override
  String get aiSearchSubtitle => 'Type to see AI-powered recommendations';

  @override
  String get createMyPack => 'Create My Pack';

  @override
  String get bundleUpdated => 'Bundle updated successfully!';

  @override
  String get bundleUpdateFailed => 'Could not update bundle. Please try again.';

  @override
  String get deleteBundleConfirm => 'Delete Bundle?';

  @override
  String get delete => 'Delete';

  @override
  String get bundleDeleteFailed => 'Could not delete bundle. Please try again.';

  @override
  String get priceKES => 'Price (KES)';

  @override
  String get createFirstBundle => 'Create your first bundle to save money';

  @override
  String get applyFilter => 'Apply Filters';

  @override
  String get priceLabel => 'Price';

  @override
  String get anyBrand => 'Any';

  @override
  String get bundleDetailsPage => 'Bundle Details';

  @override
  String productImage(Object name) {
    return '$name image';
  }

  @override
  String addToWishlist(Object name) {
    return 'Add $name to wishlist';
  }

  @override
  String removeFromWishlist(Object name) {
    return 'Remove $name from wishlist';
  }

  @override
  String priceKESLabel(Object amount) {
    return 'Price KES $amount';
  }

  @override
  String get wishlistUpdated => 'Added to wishlist';

  @override
  String get wishlistRemoved => 'Removed from wishlist';

  @override
  String get wishlistFailed => 'Could not update wishlist. Please try again.';

  @override
  String get totalItems => 'Total Items';

  @override
  String get shipping => 'Shipping';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get itemRemovedFromCart => 'Item removed from cart';

  @override
  String productsCount(Object count) {
    return '$count products';
  }

  @override
  String get packDetails => 'Pack Details';

  @override
  String get includedInThisBundle => 'Included in this bundle';

  @override
  String itemCount(Object number) {
    return 'Item $number';
  }

  @override
  String get pleaseSignInFirst => 'Please sign in first';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get couponRedeemedSuccessfully => 'Coupon redeemed successfully';

  @override
  String get invalidOrAlreadyUsedCoupon => 'Invalid or already-used coupon';

  @override
  String get offersAndPromos => 'Offers and Promos';

  @override
  String get cardPayment => 'Card Payment';

  @override
  String get stripePayment => 'Stripe';

  @override
  String get paypalPayment => 'PayPal';

  @override
  String payWith(Object method) {
    return 'Pay with $method';
  }

  @override
  String get secureHostedPaymentHint =>
      'You will be redirected to a secure hosted payment page to complete your purchase.';

  @override
  String get paymentLaunchFailed =>
      'Could not open the payment page. Please try again.';

  @override
  String get paymentInitiationFailed =>
      'Payment could not be initiated. Please try again.';

  @override
  String get statusLabel => 'Status';

  @override
  String get orderIdLabel => 'Order ID';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get chooseHowToPay => 'Choose how to pay';

  @override
  String get payViaMpesaStkPush => 'Pay via Safaricom M-Pesa STK Push';

  @override
  String get visaMastercardViaFlutterwave => 'Visa, Mastercard via Flutterwave';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get payUsingYourWallet => 'Pay using your Groc wallet';

  @override
  String get cashOnDeliveryDesc => 'Pay when your order arrives';

  @override
  String continueWith(Object method) {
    return 'Continue with $method';
  }

  @override
  String get mpesaCheckYourPhone => 'Check Your Phone';

  @override
  String mpesaWeVeSent(Object phoneNumber) {
    return 'We sent a payment request to SMS to $phoneNumber';
  }

  @override
  String get mpesaEnterPin => 'Enter your M-Pesa PIN to complete payment';

  @override
  String get mpesaTimeoutTitle => 'Payment Timeout';

  @override
  String get mpesaTimeoutMessage => 'Your payment request has expired';

  @override
  String get mpesaProcessing => 'Processing Payment...';

  @override
  String get mpesaResend => 'Resend Request';

  @override
  String get recentSearch => 'Recent Search';

  @override
  String get createOwnPack => 'Create Own Pack';

  @override
  String get failedToLoadBundles => 'Could not load bundles';

  @override
  String get noBundlesFound => 'No bundles found';

  @override
  String get bundleInformationMissing => 'Bundle information is missing';

  @override
  String get productInformationMissing => 'Product information is missing';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get weight => 'Weight';

  @override
  String stockAvailable(Object count) {
    return 'In Stock ($count available)';
  }

  @override
  String get itemsLabel => 'Items';

  @override
  String get reviewsLabel => 'Reviews';

  @override
  String get saveLabel => 'Save';

  @override
  String get searchProductHint => 'Search Product';

  @override
  String get bundleUpdatedFailed =>
      'Could not update bundle. Please try again.';

  @override
  String get searchFilters => 'Search Filters';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get sidebarMenu => 'Sidebar menu';

  @override
  String get searchButton => 'Search';

  @override
  String get adSpace => 'Advertisement';

  @override
  String get filterButton => 'Filter products';

  @override
  String get createPackButton => 'Create your own pack';

  @override
  String get continueToHome => 'Go to home';

  @override
  String get emptyCartTitle => 'Oops!';

  @override
  String get emptyCartMessage => 'Sorry, you have no products in your cart';

  @override
  String get startBrowsing => 'Start Browsing';

  @override
  String get pleaseLogIn => 'Please log in to continue';

  @override
  String get cartIsEmpty => 'Your cart is empty';

  @override
  String get totalToPay => 'Total to pay:';

  @override
  String get processingPaymentLabel => 'Processing...';

  @override
  String get payNowButton => 'Pay Now';

  @override
  String get securedByFlutterwave => 'Secured by Flutterwave';

  @override
  String paymentFailedError(Object error) {
    return 'Payment failed: $error';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get selectDeliveryAddress => 'Select Delivery Address';

  @override
  String get addNew => 'Add New';

  @override
  String get homeAddress => 'Home Address';

  @override
  String get officeAddress => 'Office Address';

  @override
  String get cardNumberLabel => 'Card Number';

  @override
  String get expiryDateLabel => 'Expiry Date';

  @override
  String get cvvLabel => 'CVV';

  @override
  String get cardHolderNameLabel => 'Card Holder Name';

  @override
  String get totalAmountLabel => 'Total Amount';

  @override
  String get resendRequest => 'Resend Request';

  @override
  String get waiting => 'Waiting...';

  @override
  String get standardDeliveryDesc => '2–4 business days';

  @override
  String get standardDeliveryEta => '2–4 days';

  @override
  String get expressDeliveryDesc => 'Delivered next day';

  @override
  String get expressDeliveryEta => 'Next day';

  @override
  String get bodaBodaSameDay => 'Boda Boda Same-Day';

  @override
  String get bodaBodaSameDayDesc => 'Today (Nairobi & Kampala only)';

  @override
  String get bodaBodaSameDayEta => 'Today';

  @override
  String get storePickupDesc => 'Pick up at our store';

  @override
  String get storePickupEta => '2–3 hours';

  @override
  String get chooseACategory => 'Choose a category';

  @override
  String get allProducts => 'All Products';

  @override
  String categoryLabel(Object name) {
    return '$name category';
  }

  @override
  String browseCategory(Object name) {
    return 'Browse $name';
  }

  @override
  String get goBack => 'Go back';

  @override
  String get vouchers => 'Vouchers';

  @override
  String get address => 'Address';

  @override
  String get notifications => 'Notifications';

  @override
  String get setting => 'Settings';

  @override
  String get payment => 'Payment';

  @override
  String get logout => 'Logout';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone';

  @override
  String get gender => 'Gender';

  @override
  String get birthday => 'Birthday';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get profileSavedSuccess => 'Profile saved successfully';

  @override
  String get profileSaveError => 'Error saving profile';

  @override
  String get unableToLoadProfile => 'Unable to load profile';

  @override
  String get couldNotLoadProfile => 'Could not load profile';

  @override
  String get checkConnectionRetry =>
      'Please check your connection and try again.';

  @override
  String get noSavedPaymentMethodsYet => 'No saved payment methods yet';

  @override
  String get savedPaymentMethods => 'Saved Payment Methods';

  @override
  String get paymentOption => 'Payment Option';

  @override
  String get deletePaymentMethodTitle => 'Delete Payment Method';

  @override
  String get deletePaymentMethodConfirm =>
      'Are you sure you want to remove this payment method? This action cannot be undone.';

  @override
  String get newAddress => 'New Address';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get fullAddressName => 'Full Name';

  @override
  String get addressLine1 => 'Address Line 1';

  @override
  String get addressLine2 => 'Address Line 2';

  @override
  String get state => 'State';

  @override
  String get zipCode => 'Zip Code';

  @override
  String get makeDefaultShippingAddress => 'Make Default Shipping Address';

  @override
  String get pleaseSignInAgainToSave => 'Please sign in again to save address';

  @override
  String get pleaseSignInAgainToEdit =>
      'Please sign in again to edit your profile.';

  @override
  String get errorLoadingProfile =>
      'Could not load your profile details. Pull to refresh or retry.';

  @override
  String get pleaseSignInAgainToSaveProfile =>
      'Please sign in again to save profile';

  @override
  String get unableToLoadPaymentMethods => 'Unable to load payment methods';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePhoneNumber => 'Change Phone Number';

  @override
  String get editHomeAddress => 'Edit Home Address';

  @override
  String get location => 'Location';

  @override
  String get profileSetting => 'Profile Setting';

  @override
  String get deactivateAccount => 'Deactivate Account';

  @override
  String get pickLocationOnMap => 'Pick Location on Map';

  @override
  String get useThisLocation => 'Use This Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get searchAddress => 'Search address';

  @override
  String get dragToAdjust => 'Drag map to adjust location';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get enableLocationServices => 'Enable location services';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get noLocationSelected => 'No location selected';
}
