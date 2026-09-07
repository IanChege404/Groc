import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Afri-Commerce'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Market, Everywhere'**
  String get appTagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover Local Markets'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop from thousands of African vendors, right from your phone'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Everything In One Place'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Groceries, fashion, electronics — all delivered to you'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Pay the Way You Know'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa, Airtel Money, card, or cash on delivery'**
  String get onboarding3Subtitle;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Track Every Order'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking from seller to your door'**
  String get onboarding4Subtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'— or continue with —'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Privacy Policy'**
  String get termsAgreement;

  /// No description provided for @continueWithEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email or Phone'**
  String get continueWithEmailOrPhone;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your number. We will send a code\nto your phone to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendMeLink.
  ///
  /// In en, this message translates to:
  /// **'Send me link'**
  String get sendMeLink;

  /// No description provided for @welcomeToOur.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our'**
  String get welcomeToOur;

  /// No description provided for @eGrocery.
  ///
  /// In en, this message translates to:
  /// **'E-Grocery'**
  String get eGrocery;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @enterYourDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit code'**
  String get enterYourDigitCode;

  /// No description provided for @didntGetCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get your code?'**
  String get didntGetCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @pleaseEnterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 4 digits'**
  String get pleaseEnterAllDigits;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phoneNumber}'**
  String weSentCodeTo(Object phoneNumber);

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {minutes}:{seconds}'**
  String resendCodeIn(Object minutes, Object seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified!'**
  String get verified;

  /// No description provided for @verifiedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You have successfully\nverified your account.'**
  String get verifiedSuccessMessage;

  /// No description provided for @browseHome.
  ///
  /// In en, this message translates to:
  /// **'Browse Home'**
  String get browseHome;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidOtp;

  /// No description provided for @phoneVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Phone verification failed. Please try again.'**
  String get phoneVerificationFailed;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @addNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Add New Password'**
  String get addNewPassword;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccess;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Password update failed'**
  String get passwordUpdateFailed;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get pleaseSignInAgain;

  /// No description provided for @errorUpdatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error updating password'**
  String get errorUpdatingPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your phone'**
  String get passwordResetLinkSent;

  /// No description provided for @failedToSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link. Please try again.'**
  String get failedToSendResetLink;

  /// No description provided for @googleSignInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get googleSignInSuccess;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @appleSignInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In coming soon'**
  String get appleSignInComingSoon;

  /// No description provided for @otpVerificationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'OTP verification coming soon'**
  String get otpVerificationComingSoon;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login With Email'**
  String get loginWithEmail;

  /// No description provided for @groceryShop.
  ///
  /// In en, this message translates to:
  /// **'grocery shop'**
  String get groceryShop;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMustHaveSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least one special character'**
  String get passwordMustHaveSpecialChar;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (for receipts)'**
  String get emailOptional;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City/Town'**
  String get city;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String requiredField(Object field);

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials and try again.'**
  String get loginFailed;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please check your details and try again.'**
  String get signupFailed;

  /// No description provided for @greeting1.
  ///
  /// In en, this message translates to:
  /// **'Habari, {name} 👋'**
  String greeting1(Object name);

  /// No description provided for @greeting2.
  ///
  /// In en, this message translates to:
  /// **'Habari Asubuhi, {name}'**
  String greeting2(Object name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Habari Mchana, {name}'**
  String greetingAfternoon(Object name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Habari Jioni, {name}'**
  String greetingEvening(Object name);

  /// No description provided for @deliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to: {location}'**
  String deliveringTo(Object location);

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products, shops...'**
  String get searchProducts;

  /// No description provided for @flashSales.
  ///
  /// In en, this message translates to:
  /// **'Flash Sales'**
  String get flashSales;

  /// No description provided for @topSellersNearYou.
  ///
  /// In en, this message translates to:
  /// **'Top Sellers Near You'**
  String get topSellersNearYou;

  /// No description provided for @freshPicks.
  ///
  /// In en, this message translates to:
  /// **'Fresh Picks'**
  String get freshPicks;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productList;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @onlyNLeft.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String onlyNLeft(Object count);

  /// No description provided for @notifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify Me'**
  String get notifyMe;

  /// No description provided for @sizeGuide.
  ///
  /// In en, this message translates to:
  /// **'Size Guide'**
  String get sizeGuide;

  /// No description provided for @viewShop.
  ///
  /// In en, this message translates to:
  /// **'View Shop'**
  String get viewShop;

  /// No description provided for @chatSeller.
  ///
  /// In en, this message translates to:
  /// **'Chat Seller'**
  String get chatSeller;

  /// No description provided for @deliveredTo.
  ///
  /// In en, this message translates to:
  /// **'Delivered to: {location}'**
  String deliveredTo(Object location);

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee: {fee}'**
  String deliveryFee(Object fee);

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Est. Delivery: {date}'**
  String estimatedDelivery(Object date);

  /// No description provided for @returnPolicy.
  ///
  /// In en, this message translates to:
  /// **'7-day Returns'**
  String get returnPolicy;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @seeAllReviews.
  ///
  /// In en, this message translates to:
  /// **'See all {count} reviews'**
  String seeAllReviews(Object count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @trendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get trendingSearches;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Cart is Empty'**
  String get yourCartIsEmpty;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @cartItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cartItems(Object count);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCode;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get step4;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get selectAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Address'**
  String get addNewAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @deliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get deliveryMethod;

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get standardDelivery;

  /// No description provided for @expressDelivery.
  ///
  /// In en, this message translates to:
  /// **'Express Delivery'**
  String get expressDelivery;

  /// No description provided for @sameDayDelivery.
  ///
  /// In en, this message translates to:
  /// **'Same-Day Delivery (Today)'**
  String get sameDayDelivery;

  /// No description provided for @storePickup.
  ///
  /// In en, this message translates to:
  /// **'Store Pickup'**
  String get storePickup;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review & Payment'**
  String get reviewOrder;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @mPesa.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa'**
  String get mPesa;

  /// No description provided for @airtelMoney.
  ///
  /// In en, this message translates to:
  /// **'Airtel Money'**
  String get airtelMoney;

  /// No description provided for @debitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit/Credit Card'**
  String get debitCard;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @afriWallet.
  ///
  /// In en, this message translates to:
  /// **'Afri Wallet'**
  String get afriWallet;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @checkYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Check your phone'**
  String get checkYourPhone;

  /// No description provided for @mPesaPaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a payment request to {phoneNumber}. Enter your M-Pesa PIN to complete.'**
  String mPesaPaymentRequest(Object phoneNumber);

  /// No description provided for @requestExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Request expires in'**
  String get requestExpiresIn;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingPayment;

  /// No description provided for @confirmPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPaymentTitle;

  /// No description provided for @confirmPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment of KES {amount} to {phone}?'**
  String confirmPaymentMessage(Object amount, Object phone);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @selectPaymentSystem.
  ///
  /// In en, this message translates to:
  /// **'Select Payment System'**
  String get selectPaymentSystem;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @rememberCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Remember card details'**
  String get rememberCardDetails;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase {productName} quantity to {quantity}'**
  String increaseQuantity(Object productName, Object quantity);

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease {productName} quantity to {quantity}'**
  String decreaseQuantity(Object productName, Object quantity);

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove {productName} from cart'**
  String removeFromCart(Object productName);

  /// No description provided for @paymentMethodSelected.
  ///
  /// In en, this message translates to:
  /// **'{label}, selected'**
  String paymentMethodSelected(Object label);

  /// No description provided for @paymentMethodNotSelected.
  ///
  /// In en, this message translates to:
  /// **'{label}, not selected'**
  String paymentMethodNotSelected(Object label);

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @orderCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create order'**
  String get orderCreationFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(Object number);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @continueShoppingBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShoppingBtn;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myOrder.
  ///
  /// In en, this message translates to:
  /// **'My Order'**
  String get myOrder;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeOrders;

  /// No description provided for @completedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedOrders;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @outForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get outForDelivery;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @returnItem.
  ///
  /// In en, this message translates to:
  /// **'Return Item'**
  String get returnItem;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersYetDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any orders yet.'**
  String get noOrdersYetDescription;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get noCompletedOrders;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @trackMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Track My Order'**
  String get trackMyOrder;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paidFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid From'**
  String get paidFrom;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully'**
  String get orderPlacedSuccess;

  /// No description provided for @orderPlacedSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your order. Your order has been placed successfully. You can track your order status from My Orders.'**
  String get orderPlacedSuccessDesc;

  /// No description provided for @orderFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Failed'**
  String get orderFailedTitle;

  /// No description provided for @orderFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be processed. Please try again or contact support if the issue persists.'**
  String get orderFailedDesc;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmation;

  /// No description provided for @orderConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed. We\'ll notify you when it ships.'**
  String get orderConfirmationDesc;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @goToOrders.
  ///
  /// In en, this message translates to:
  /// **'Go to Orders'**
  String get goToOrders;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get orderStatusDelivery;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placedOn(Object date);

  /// No description provided for @estimatedDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Est. Delivery: {date}'**
  String estimatedDeliveryDate(Object date);

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get orderConfirmed;

  /// No description provided for @processingOrder.
  ///
  /// In en, this message translates to:
  /// **'Processing Order'**
  String get processingOrder;

  /// No description provided for @itemShipped.
  ///
  /// In en, this message translates to:
  /// **'Item Shipped'**
  String get itemShipped;

  /// No description provided for @itemDelivered.
  ///
  /// In en, this message translates to:
  /// **'Item Delivered'**
  String get itemDelivered;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @riderLocation.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the way!'**
  String riderLocation(Object name);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distance(Object distance);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get myAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @afriWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Afri Wallet'**
  String get afriWalletBalance;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Centre'**
  String get helpCenter;

  /// No description provided for @chatSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat Support'**
  String get chatSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @searchField.
  ///
  /// In en, this message translates to:
  /// **'Search Field'**
  String get searchField;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search products'**
  String get startTypingToSearch;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search results for \"{query}\"'**
  String searchResultsFor(Object query);

  /// No description provided for @enterProductNameToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name to search'**
  String get enterProductNameToSearch;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @newItems.
  ///
  /// In en, this message translates to:
  /// **'New Items'**
  String get newItems;

  /// No description provided for @createBundle.
  ///
  /// In en, this message translates to:
  /// **'Create Bundle'**
  String get createBundle;

  /// No description provided for @createMyBundle.
  ///
  /// In en, this message translates to:
  /// **'Create My Bundle'**
  String get createMyBundle;

  /// No description provided for @myBundles.
  ///
  /// In en, this message translates to:
  /// **'My Bundles'**
  String get myBundles;

  /// No description provided for @editBundle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bundle'**
  String get editBundle;

  /// No description provided for @bundleDetails.
  ///
  /// In en, this message translates to:
  /// **'Bundle Details'**
  String get bundleDetails;

  /// No description provided for @bundleName.
  ///
  /// In en, this message translates to:
  /// **'Bundle Name'**
  String get bundleName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @priceKes.
  ///
  /// In en, this message translates to:
  /// **'Price (KES)'**
  String get priceKes;

  /// No description provided for @discountPrice.
  ///
  /// In en, this message translates to:
  /// **'Discount Price'**
  String get discountPrice;

  /// No description provided for @productsInBundle.
  ///
  /// In en, this message translates to:
  /// **'Products in Bundle'**
  String get productsInBundle;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @addProductComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add product functionality coming soon'**
  String get addProductComingSoon;

  /// No description provided for @removeProductComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Remove product functionality coming soon'**
  String get removeProductComingSoon;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteBundle.
  ///
  /// In en, this message translates to:
  /// **'Delete Bundle'**
  String get deleteBundle;

  /// No description provided for @bundleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bundle updated successfully!'**
  String get bundleUpdatedSuccessfully;

  /// No description provided for @bundleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bundle deleted'**
  String get bundleDeleted;

  /// No description provided for @noBundlesYet.
  ///
  /// In en, this message translates to:
  /// **'No Bundles Yet'**
  String get noBundlesYet;

  /// No description provided for @createFirstBundleToSave.
  ///
  /// In en, this message translates to:
  /// **'Create your first bundle to save money'**
  String get createFirstBundleToSave;

  /// No description provided for @popularPacks.
  ///
  /// In en, this message translates to:
  /// **'Popular Packs'**
  String get popularPacks;

  /// No description provided for @ourNewItem.
  ///
  /// In en, this message translates to:
  /// **'Our New Item'**
  String get ourNewItem;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @checkConnectionAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkConnectionAndRetry;

  /// No description provided for @failedToSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try searching again.'**
  String get failedToSearchProducts;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @failedToLoadNewItems.
  ///
  /// In en, this message translates to:
  /// **'Could not load new items'**
  String get failedToLoadNewItems;

  /// No description provided for @failedToLoadPopularPacks.
  ///
  /// In en, this message translates to:
  /// **'Could not load popular packs'**
  String get failedToLoadPopularPacks;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading data'**
  String get errorLoadingData;

  /// No description provided for @aiSearch.
  ///
  /// In en, this message translates to:
  /// **'AI Search'**
  String get aiSearch;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsHint;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @startSearching.
  ///
  /// In en, this message translates to:
  /// **'Start Searching'**
  String get startSearching;

  /// No description provided for @typeForAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Type to see AI-powered recommendations'**
  String get typeForAiRecommendations;

  /// No description provided for @noResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String noResultsForQuery(Object query);

  /// No description provided for @browseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Browse Catalog'**
  String get browseCatalog;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} results found'**
  String resultsFound(Object count);

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @popularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @ratingStar.
  ///
  /// In en, this message translates to:
  /// **'Rating Star'**
  String get ratingStar;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @deleteBundleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Bundle?'**
  String get deleteBundleQuestion;

  /// No description provided for @deleteBundleWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All bundle data will be permanently removed.'**
  String get deleteBundleWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDelete;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \"{name}\" to confirm deletion'**
  String typeDeleteToConfirm(Object name);

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, KES {price}, {rating} stars'**
  String productLabel(Object name, Object price, Object rating);

  /// No description provided for @addToWishlistLabel.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to wishlist'**
  String addToWishlistLabel(Object name);

  /// No description provided for @removeFromWishlistLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from wishlist'**
  String removeFromWishlistLabel(Object name);

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @failedToUpdateWishlist.
  ///
  /// In en, this message translates to:
  /// **'Could not update wishlist'**
  String get failedToUpdateWishlist;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String items(Object count);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @officeSupplies.
  ///
  /// In en, this message translates to:
  /// **'Office Supplies'**
  String get officeSupplies;

  /// No description provided for @gardening.
  ///
  /// In en, this message translates to:
  /// **'Gardening'**
  String get gardening;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fishAndMeat.
  ///
  /// In en, this message translates to:
  /// **'Fish And Meat'**
  String get fishAndMeat;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkConnection;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @aiSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type to see AI-powered recommendations'**
  String get aiSearchSubtitle;

  /// No description provided for @createMyPack.
  ///
  /// In en, this message translates to:
  /// **'Create My Pack'**
  String get createMyPack;

  /// No description provided for @bundleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bundle updated successfully!'**
  String get bundleUpdated;

  /// No description provided for @bundleUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update bundle. Please try again.'**
  String get bundleUpdateFailed;

  /// No description provided for @deleteBundleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Bundle?'**
  String get deleteBundleConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @bundleDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete bundle. Please try again.'**
  String get bundleDeleteFailed;

  /// No description provided for @priceKES.
  ///
  /// In en, this message translates to:
  /// **'Price (KES)'**
  String get priceKES;

  /// No description provided for @createFirstBundle.
  ///
  /// In en, this message translates to:
  /// **'Create your first bundle to save money'**
  String get createFirstBundle;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilter;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @anyBrand.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyBrand;

  /// No description provided for @bundleDetailsPage.
  ///
  /// In en, this message translates to:
  /// **'Bundle Details'**
  String get bundleDetailsPage;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'{name} image'**
  String productImage(Object name);

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to wishlist'**
  String addToWishlist(Object name);

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from wishlist'**
  String removeFromWishlist(Object name);

  /// No description provided for @priceKESLabel.
  ///
  /// In en, this message translates to:
  /// **'Price KES {amount}'**
  String priceKESLabel(Object amount);

  /// No description provided for @wishlistUpdated.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get wishlistUpdated;

  /// No description provided for @wishlistRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get wishlistRemoved;

  /// No description provided for @wishlistFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update wishlist. Please try again.'**
  String get wishlistFailed;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productsCount(Object count);

  /// No description provided for @packDetails.
  ///
  /// In en, this message translates to:
  /// **'Pack Details'**
  String get packDetails;

  /// No description provided for @includedInThisBundle.
  ///
  /// In en, this message translates to:
  /// **'Included in this bundle'**
  String get includedInThisBundle;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String itemCount(Object number);

  /// No description provided for @pleaseSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first'**
  String get pleaseSignInFirst;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @couponRedeemedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Coupon redeemed successfully'**
  String get couponRedeemedSuccessfully;

  /// No description provided for @invalidOrAlreadyUsedCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid or already-used coupon'**
  String get invalidOrAlreadyUsedCoupon;

  /// No description provided for @offersAndPromos.
  ///
  /// In en, this message translates to:
  /// **'Offers and Promos'**
  String get offersAndPromos;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// No description provided for @stripePayment.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get stripePayment;

  /// No description provided for @paypalPayment.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypalPayment;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with {method}'**
  String payWith(Object method);

  /// No description provided for @secureHostedPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to a secure hosted payment page to complete your purchase.'**
  String get secureHostedPaymentHint;

  /// No description provided for @paymentLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the payment page. Please try again.'**
  String get paymentLaunchFailed;

  /// No description provided for @paymentInitiationFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be initiated. Please try again.'**
  String get paymentInitiationFailed;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @orderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderIdLabel;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @chooseHowToPay.
  ///
  /// In en, this message translates to:
  /// **'Choose how to pay'**
  String get chooseHowToPay;

  /// No description provided for @payViaMpesaStkPush.
  ///
  /// In en, this message translates to:
  /// **'Pay via Safaricom M-Pesa STK Push'**
  String get payViaMpesaStkPush;

  /// No description provided for @visaMastercardViaFlutterwave.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard via Flutterwave'**
  String get visaMastercardViaFlutterwave;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @payUsingYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay using your Groc wallet'**
  String get payUsingYourWallet;

  /// No description provided for @cashOnDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay when your order arrives'**
  String get cashOnDeliveryDesc;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {method}'**
  String continueWith(Object method);

  /// No description provided for @mpesaCheckYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Check Your Phone'**
  String get mpesaCheckYourPhone;

  /// No description provided for @mpesaWeVeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a payment request to SMS to {phoneNumber}'**
  String mpesaWeVeSent(Object phoneNumber);

  /// No description provided for @mpesaEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your M-Pesa PIN to complete payment'**
  String get mpesaEnterPin;

  /// No description provided for @mpesaTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Timeout'**
  String get mpesaTimeoutTitle;

  /// No description provided for @mpesaTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment request has expired'**
  String get mpesaTimeoutMessage;

  /// No description provided for @mpesaProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get mpesaProcessing;

  /// No description provided for @mpesaResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Request'**
  String get mpesaResend;

  /// No description provided for @recentSearch.
  ///
  /// In en, this message translates to:
  /// **'Recent Search'**
  String get recentSearch;

  /// No description provided for @createOwnPack.
  ///
  /// In en, this message translates to:
  /// **'Create Own Pack'**
  String get createOwnPack;

  /// No description provided for @failedToLoadBundles.
  ///
  /// In en, this message translates to:
  /// **'Could not load bundles'**
  String get failedToLoadBundles;

  /// No description provided for @noBundlesFound.
  ///
  /// In en, this message translates to:
  /// **'No bundles found'**
  String get noBundlesFound;

  /// No description provided for @bundleInformationMissing.
  ///
  /// In en, this message translates to:
  /// **'Bundle information is missing'**
  String get bundleInformationMissing;

  /// No description provided for @productInformationMissing.
  ///
  /// In en, this message translates to:
  /// **'Product information is missing'**
  String get productInformationMissing;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @stockAvailable.
  ///
  /// In en, this message translates to:
  /// **'In Stock ({count} available)'**
  String stockAvailable(Object count);

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @searchProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search Product'**
  String get searchProductHint;

  /// No description provided for @bundleUpdatedFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update bundle. Please try again.'**
  String get bundleUpdatedFailed;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Search Filters'**
  String get searchFilters;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @sidebarMenu.
  ///
  /// In en, this message translates to:
  /// **'Sidebar menu'**
  String get sidebarMenu;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @adSpace.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get adSpace;

  /// No description provided for @filterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter products'**
  String get filterButton;

  /// No description provided for @createPackButton.
  ///
  /// In en, this message translates to:
  /// **'Create your own pack'**
  String get createPackButton;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get continueToHome;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you have no products in your cart'**
  String get emptyCartMessage;

  /// No description provided for @startBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Start Browsing'**
  String get startBrowsing;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get pleaseLogIn;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay:'**
  String get totalToPay;

  /// No description provided for @processingPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingPaymentLabel;

  /// No description provided for @payNowButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNowButton;

  /// No description provided for @securedByFlutterwave.
  ///
  /// In en, this message translates to:
  /// **'Secured by Flutterwave'**
  String get securedByFlutterwave;

  /// No description provided for @paymentFailedError.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailedError(Object error);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get selectDeliveryAddress;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @officeAddress.
  ///
  /// In en, this message translates to:
  /// **'Office Address'**
  String get officeAddress;

  /// No description provided for @cardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumberLabel;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDateLabel;

  /// No description provided for @cvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvvLabel;

  /// No description provided for @cardHolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderNameLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmountLabel;

  /// No description provided for @resendRequest.
  ///
  /// In en, this message translates to:
  /// **'Resend Request'**
  String get resendRequest;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// No description provided for @standardDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'2–4 business days'**
  String get standardDeliveryDesc;

  /// No description provided for @standardDeliveryEta.
  ///
  /// In en, this message translates to:
  /// **'2–4 days'**
  String get standardDeliveryEta;

  /// No description provided for @expressDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Delivered next day'**
  String get expressDeliveryDesc;

  /// No description provided for @expressDeliveryEta.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get expressDeliveryEta;

  /// No description provided for @bodaBodaSameDay.
  ///
  /// In en, this message translates to:
  /// **'Boda Boda Same-Day'**
  String get bodaBodaSameDay;

  /// No description provided for @bodaBodaSameDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Today (Nairobi & Kampala only)'**
  String get bodaBodaSameDayDesc;

  /// No description provided for @bodaBodaSameDayEta.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get bodaBodaSameDayEta;

  /// No description provided for @storePickupDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick up at our store'**
  String get storePickupDesc;

  /// No description provided for @storePickupEta.
  ///
  /// In en, this message translates to:
  /// **'2–3 hours'**
  String get storePickupEta;

  /// No description provided for @chooseACategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseACategory;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} category'**
  String categoryLabel(Object name);

  /// No description provided for @browseCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse {name}'**
  String browseCategory(Object name);

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @vouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSavedSuccess;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get profileSaveError;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get couldNotLoadProfile;

  /// No description provided for @checkConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionRetry;

  /// No description provided for @noSavedPaymentMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved payment methods yet'**
  String get noSavedPaymentMethodsYet;

  /// No description provided for @savedPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Saved Payment Methods'**
  String get savedPaymentMethods;

  /// No description provided for @paymentOption.
  ///
  /// In en, this message translates to:
  /// **'Payment Option'**
  String get paymentOption;

  /// No description provided for @deletePaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Method'**
  String get deletePaymentMethodTitle;

  /// No description provided for @deletePaymentMethodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this payment method? This action cannot be undone.'**
  String get deletePaymentMethodConfirm;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get newAddress;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @fullAddressName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullAddressName;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get zipCode;

  /// No description provided for @makeDefaultShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Make Default Shipping Address'**
  String get makeDefaultShippingAddress;

  /// No description provided for @pleaseSignInAgainToSave.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to save address'**
  String get pleaseSignInAgainToSave;

  /// No description provided for @pleaseSignInAgainToEdit.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to edit your profile.'**
  String get pleaseSignInAgainToEdit;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile details. Pull to refresh or retry.'**
  String get errorLoadingProfile;

  /// No description provided for @pleaseSignInAgainToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to save profile'**
  String get pleaseSignInAgainToSaveProfile;

  /// No description provided for @unableToLoadPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Unable to load payment methods'**
  String get unableToLoadPaymentMethods;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneNumber;

  /// No description provided for @editHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Home Address'**
  String get editHomeAddress;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @profileSetting.
  ///
  /// In en, this message translates to:
  /// **'Profile Setting'**
  String get profileSetting;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @pickLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick Location on Map'**
  String get pickLocationOnMap;

  /// No description provided for @useThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use This Location'**
  String get useThisLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @dragToAdjust.
  ///
  /// In en, this message translates to:
  /// **'Drag map to adjust location'**
  String get dragToAdjust;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable location services'**
  String get enableLocationServices;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get noLocationSelected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
