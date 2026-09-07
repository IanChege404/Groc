// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'Afri-Commerce';

  @override
  String get appTagline => 'Soko Lako, Kila Mahali';

  @override
  String get skip => 'Ruka';

  @override
  String get next => 'Inayofuata';

  @override
  String get getStarted => 'Kuanza';

  @override
  String get onboarding1Title => 'Gundua Masoko ya Karibu';

  @override
  String get onboarding1Subtitle =>
      'Kununua kutoka kwa wanachama wengi wa Kiafrika, moja kwa moja kutoka kwa simu yako';

  @override
  String get onboarding2Title => 'Kila Kitu Mahali Pamoja';

  @override
  String get onboarding2Subtitle =>
      'Mboga safi, mavazi, elektroniki — yote inayoletwa kwako';

  @override
  String get onboarding3Title => 'Lipa Unavyojua';

  @override
  String get onboarding3Subtitle =>
      'M-Pesa, Airtel Money, kadi, au pesa katika kuweka';

  @override
  String get onboarding4Title => 'Fuatilia Kila Agizo';

  @override
  String get onboarding4Subtitle =>
      'Fuatiliano halisi mula kwa muuzaji hadi mlangoni mwako';

  @override
  String get chooseLanguage => 'Chagua Lugha Yako';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get continueAction => 'Endelea';

  @override
  String get welcomeBack => 'Karibu Tena';

  @override
  String get login => 'Ingia';

  @override
  String get signIn => 'Ingia';

  @override
  String get signUp => 'Jisajili';

  @override
  String get name => 'Jina';

  @override
  String get phoneNumber => 'Nambari ya Simu';

  @override
  String get password => 'Nenosiri';

  @override
  String get confirmPassword => 'Thibitisha Nenosiri';

  @override
  String get forgotPassword => 'Umesahau Nenosiri?';

  @override
  String get orContinueWith => '— au endelea na —';

  @override
  String get dontHaveAccount => 'Huna akaunti?';

  @override
  String get haveAccount => 'Tayari una akaunti?';

  @override
  String get termsAgreement => 'Nakubali Masharti & Sera ya Faragha';

  @override
  String get continueWithEmailOrPhone => 'Endelea na Barua Pepe au Simu';

  @override
  String get createAccount => 'Fungua akaunti';

  @override
  String get resetYourPassword => 'Weka upya nenosiri lako';

  @override
  String get resetPasswordDescription =>
      'Tafadhali weka nambari yako. Tutatumia nambari\nkwa simu yako ili kuweka upya nenosiri lako.';

  @override
  String get sendMeLink => 'Nitumie kiungo';

  @override
  String get welcomeToOur => 'Karibu';

  @override
  String get eGrocery => 'Soko la Mtandaoni';

  @override
  String get enterCode => 'Ingiza Nambari';

  @override
  String get enterYourDigitCode => 'Weka nambari yako ya tarakimu 4';

  @override
  String get didntGetCode => 'Hukupata nambari?';

  @override
  String get resend => 'Tuma Tena';

  @override
  String get verifyOtp => 'Thibitisha OTP';

  @override
  String get verify => 'Thibitisha';

  @override
  String get pleaseEnterAllDigits => 'Tafadhali weka tarakimu zote 4';

  @override
  String weSentCodeTo(Object phoneNumber) {
    return 'Tumetuma nambari ya tarakimu 6 kwa $phoneNumber';
  }

  @override
  String resendCodeIn(Object minutes, Object seconds) {
    return 'Tuma nambari tena katika $minutes:$seconds';
  }

  @override
  String get resendCode => 'Tuma Nambari Tena';

  @override
  String get changeNumber => 'Badilisha nambari';

  @override
  String get verified => 'Imethibitishwa!';

  @override
  String get verifiedSuccessMessage =>
      'Umefanikiwa\nkuthibitisha akaunti yako.';

  @override
  String get browseHome => 'Pitia Nyumbani';

  @override
  String get invalidOtp => 'Nambari si sahihi. Tafadhali jaribu tena.';

  @override
  String get phoneVerificationFailed =>
      'Uthibitishaji wa simu umeshindikana. Tafadhali jaribu tena.';

  @override
  String get newPassword => 'Nenosiri Jipya';

  @override
  String get addNewPassword => 'Ongeza Nenosiri Jipya';

  @override
  String get done => 'Imekamilika';

  @override
  String get passwordsDoNotMatch => 'Nenosiri hazifanani';

  @override
  String get passwordTooShort => 'Nenosiri lazima iwe na angalau herufi 8';

  @override
  String get currentPassword => 'Nenosiri ya Sasa';

  @override
  String get updatePassword => 'Sasisha Nenosiri';

  @override
  String get passwordUpdatedSuccess => 'Nenosiri imesasishwa kwa mafanikio';

  @override
  String get passwordUpdateFailed => 'Usasishaji wa nenosiri umeshindikana';

  @override
  String get pleaseSignInAgain => 'Tafadhali ingia tena';

  @override
  String get errorUpdatingPassword => 'Hitilafu wakati wa kusasisha nenosiri';

  @override
  String get showPassword => 'Onyesha nenosiri';

  @override
  String get hidePassword => 'Ficha nenosiri';

  @override
  String get passwordResetLinkSent =>
      'Kiungo cha kuweka upya nenosiri kimetumwa kwa simu yako';

  @override
  String get failedToSendResetLink =>
      'Imeshindikana kutuma kiungo. Tafadhali jaribu tena.';

  @override
  String get googleSignInSuccess => 'Umeingia na Google';

  @override
  String get googleSignInFailed =>
      'Kuingia kumeshindikana. Tafadhali jaribu tena.';

  @override
  String get appleSignInComingSoon => 'Kuingia na Apple kinakuja hivi karibuni';

  @override
  String get otpVerificationComingSoon =>
      'Uthibitishaji wa OTP unakuja hivi karibuni';

  @override
  String get loginWithEmail => 'Ingia na Barua Pepe';

  @override
  String get groceryShop => 'soko la mboga';

  @override
  String get passwordRequired => 'Nenosiri inahitajika';

  @override
  String get passwordMustHaveSpecialChar =>
      'Nenosiri lazima iwe na angalau herufi maalum';

  @override
  String get fullName => 'Jina Kamili';

  @override
  String get displayName => 'Jina la Kuonyesha';

  @override
  String get email => 'Barua Pepe';

  @override
  String get emailHint => 'Weka anwani yako ya barua pepe';

  @override
  String get nameHint => 'Weka jina lako kamili';

  @override
  String get phoneHint => 'Weka nambari yako ya simu';

  @override
  String get passwordHint => 'Weka nenosiri lako';

  @override
  String get emailOptional => 'Barua Pepe (kwa risiti)';

  @override
  String get city => 'Jiji/Orodha';

  @override
  String get termsAndConditions => 'Masharti ya Huduma';

  @override
  String get privacyPolicy => 'Sera ya Faragha';

  @override
  String requiredField(Object field) {
    return '$field inahitajika';
  }

  @override
  String get loginFailed =>
      'Kuingia kumeshindikana. Tafadhali angalia taarifa zako na jaribu tena.';

  @override
  String get signupFailed =>
      'Usajili umeshindikana. Tafadhali angalia maelezo yako na jaribu tena.';

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
    return 'Kuletwa: $location';
  }

  @override
  String get searchProducts => 'Tafuta bidhaa, duka...';

  @override
  String get flashSales => 'Uuzaji Wa Haraka';

  @override
  String get topSellersNearYou => 'Wauzaji Wangu Karibu Nako';

  @override
  String get freshPicks => 'Chaguzi Mpya';

  @override
  String get seeAll => 'Tazama Zote';

  @override
  String get home => 'Nyumbani';

  @override
  String get discover => 'Gundua';

  @override
  String get cart => 'Kikapu';

  @override
  String get orders => 'Agizo';

  @override
  String get profile => 'Wasifu';

  @override
  String get productList => 'Bidhaa';

  @override
  String get categories => 'Aina';

  @override
  String get filters => 'Kichujio';

  @override
  String get sort => 'Panga';

  @override
  String get relevance => 'Kufaa';

  @override
  String get priceHighToLow => 'Bei: Juu hadi Chini';

  @override
  String get priceLowToHigh => 'Bei: Chini hadi Juu';

  @override
  String get newest => 'Mpya';

  @override
  String get rating => 'Tathmini';

  @override
  String get apply => 'Tekeleza';

  @override
  String get reset => 'Anza Tena';

  @override
  String get productDetails => 'Maelezo ya Bidhaa';

  @override
  String get addToCart => 'Ongeza Kwa Kikapu';

  @override
  String get buyNow => 'Nunua Sasa';

  @override
  String get inStock => 'Inapatikana';

  @override
  String get outOfStock => 'Haipo';

  @override
  String onlyNLeft(Object count) {
    return 'Iliyobaki $count tu';
  }

  @override
  String get notifyMe => 'Jaribu Mimi';

  @override
  String get sizeGuide => 'Mwongozo wa Ukubwa';

  @override
  String get viewShop => 'Tazama Duka';

  @override
  String get chatSeller => 'Jifunze na Muuzaji';

  @override
  String deliveredTo(Object location) {
    return 'Kuletwa: $location';
  }

  @override
  String get freeDelivery => 'Kuletwa Bure';

  @override
  String deliveryFee(Object fee) {
    return 'Bei ya Kuletwa: $fee';
  }

  @override
  String estimatedDelivery(Object date) {
    return 'Inatarajiwa Kuletwa: $date';
  }

  @override
  String get returnPolicy => 'Kurudisha kwa Siku 7';

  @override
  String get reviews => 'Maoni';

  @override
  String seeAllReviews(Object count) {
    return 'Tazama maoni yote $count';
  }

  @override
  String get search => 'Tafuta';

  @override
  String get recentSearches => 'Utafutaji wa Karibuni';

  @override
  String get clearAll => 'Futa Zote';

  @override
  String get trendingSearches => 'Utafutaji wa Maajabu';

  @override
  String get yourCartIsEmpty => 'Kikapu Chako Kiko Tupu';

  @override
  String get startShopping => 'Anza Kununua';

  @override
  String cartItems(Object count) {
    return 'bidhaa $count';
  }

  @override
  String get subtotal => 'Jumla ya Sehemu';

  @override
  String get discount => 'Punguzo';

  @override
  String get total => 'Jumla';

  @override
  String get proceedToCheckout => 'Endelea Ukalipie';

  @override
  String get applyCoupon => 'Tekeleza Kuponi';

  @override
  String get couponCode => 'Nambari ya Kuponi';

  @override
  String get remove => 'Ondoa';

  @override
  String get quantity => 'Kiasi';

  @override
  String get checkout => 'Ukalipie';

  @override
  String get step1 => 'Anwani';

  @override
  String get step2 => 'Kuletwa';

  @override
  String get step3 => 'Tathmini';

  @override
  String get step4 => 'Kulipwa';

  @override
  String get selectAddress => 'Chagua Anwani ya Kuletwa';

  @override
  String get addNewAddress => '+ Ongeza Anwani Mpya';

  @override
  String get setAsDefault => 'Weka Kama Kawaida';

  @override
  String get saveAddress => 'Hifadhi Anwani';

  @override
  String get editAddress => 'Hariri Anwani';

  @override
  String get deliveryMethod => 'Njia ya Kuletwa';

  @override
  String get standardDelivery => 'Kuletwa Kawaida';

  @override
  String get expressDelivery => 'Kuletwa Haraka';

  @override
  String get sameDayDelivery => 'Kuletwa Siku Moja (Leo)';

  @override
  String get storePickup => 'Mkutano katika Duka';

  @override
  String get free => 'BURE';

  @override
  String get reviewOrder => 'Tathmini & Kulipwa';

  @override
  String get paymentMethod => 'Njia ya Kulipwa';

  @override
  String get mPesa => 'M-Pesa';

  @override
  String get airtelMoney => 'Airtel Money';

  @override
  String get debitCard => 'Kadi ya Debit/Credit';

  @override
  String get cashOnDelivery => 'Pesa Kwa Kuweka';

  @override
  String get afriWallet => 'Hazina ya Afri';

  @override
  String get placeOrder => 'Weka Agizo';

  @override
  String get checkYourPhone => 'Angalia Simu Yako';

  @override
  String mPesaPaymentRequest(Object phoneNumber) {
    return 'Tumetuma ombi la kulipwa kwa $phoneNumber. Ingiza PIN yako ya M-Pesa kumaliza.';
  }

  @override
  String get requestExpiresIn => 'Ombi linaisha katika';

  @override
  String get tryAgain => 'Jaribu Tena';

  @override
  String get payNow => 'Lipa Sasa';

  @override
  String get processingPayment => 'Inashughulikia...';

  @override
  String get confirmPaymentTitle => 'Thibitisha Malipo';

  @override
  String confirmPaymentMessage(Object amount, Object phone) {
    return 'Thibitisha malipo ya KES $amount kwa $phone?';
  }

  @override
  String get confirm => 'Thibitisha';

  @override
  String get selectPaymentSystem => 'Chagua Njia ya Kulipa';

  @override
  String get cardName => 'Jina la Kadi';

  @override
  String get cardNumber => 'Nambari ya Kadi';

  @override
  String get expirationDate => 'Tarehe ya Mwisho';

  @override
  String get cvv => 'CVV';

  @override
  String get rememberCardDetails => 'Kumbuka maelezo ya kadi';

  @override
  String increaseQuantity(Object productName, Object quantity) {
    return 'Ongeza idadi ya $productName hadi $quantity';
  }

  @override
  String decreaseQuantity(Object productName, Object quantity) {
    return 'Punguza idadi ya $productName hadi $quantity';
  }

  @override
  String removeFromCart(Object productName) {
    return 'Ondoa $productName kwenye kikapu';
  }

  @override
  String paymentMethodSelected(Object label) {
    return '$label, imechaguliwa';
  }

  @override
  String paymentMethodNotSelected(Object label) {
    return '$label, haijachaguliwa';
  }

  @override
  String get invalidPhoneNumber => 'Nambari ya simu si sahihi';

  @override
  String get orderCreationFailed => 'Imeshindikana kuunda agizo';

  @override
  String get retry => 'Jaribu Tena';

  @override
  String get orderPlaced => 'Agizo Limewekwa!';

  @override
  String orderNumber(Object number) {
    return 'Agizo #$number';
  }

  @override
  String get trackOrder => 'Fuatilia Agizo';

  @override
  String get continueShoppingBtn => 'Endelea Kununua';

  @override
  String get share => 'Sambaza';

  @override
  String get myOrders => 'Agizo Zangu';

  @override
  String get myOrder => 'Agizo Langu';

  @override
  String get allOrders => 'Agizo Zote';

  @override
  String get activeOrders => 'Zinazofanya Kazi';

  @override
  String get completedOrders => 'Zilizokamilika';

  @override
  String get processing => 'Inashughulikiwa';

  @override
  String get shipped => 'Imetumwa';

  @override
  String get delivered => 'Imepokelewa';

  @override
  String get cancelled => 'Imeghairiwa';

  @override
  String get pending => 'Inasubiri';

  @override
  String get outForDelivery => 'Inatolewa';

  @override
  String get delivery => 'Kuletwa';

  @override
  String get returns => 'Kurudisha';

  @override
  String get cancelOrder => 'Ghairi Agizo';

  @override
  String get reorder => 'Agiza Tena';

  @override
  String get returnItem => 'Rudisha Bidhaa';

  @override
  String get noOrdersYet => 'Hakuna Agizo Bado';

  @override
  String get noOrdersYetDescription => 'Hujaweka agizo lolote bado.';

  @override
  String get noActiveOrders => 'Hakuna agizo zinazofanya kazi';

  @override
  String get noCompletedOrders => 'Hakuna agizo zilizokamilika';

  @override
  String get continueShopping => 'Endelea Kununua';

  @override
  String get trackMyOrder => 'Fuatilia Agizo Langu';

  @override
  String get orderId => 'Nambari ya Agizo';

  @override
  String get orderStatus => 'Hali ya Agizo';

  @override
  String get status => 'Hali';

  @override
  String get totalAmount => 'Jumla ya Kiasi';

  @override
  String get paidFrom => 'Imelipiwa Kutoka';

  @override
  String get orderPlacedSuccess => 'Agizo Limewekwa Kwa Mafanikio';

  @override
  String get orderPlacedSuccessDesc =>
      'Asante kwa agizo lako. Agizo lako limewekwa kwa mafanikio. Unaweza kufuatilia hali ya agizo lako kutoka Agizo Zangu.';

  @override
  String get orderFailedTitle => 'Agizo Limeshindikana';

  @override
  String get orderFailedDesc =>
      'Malipo hayakuweza kusindika. Tafadhali jaribu tena au wasiliana na msaada ikiwa tatizo linaendelea.';

  @override
  String get orderConfirmation => 'Agizo Limethibitishwa!';

  @override
  String get orderConfirmationDesc =>
      'Agizo lako limethibitishwa. Tutakuarifu linapotumwa.';

  @override
  String get goToHome => 'Rudi Nyumbani';

  @override
  String get goToOrders => 'Endelea Agizo';

  @override
  String get orderStatusPending => 'Inasubiri';

  @override
  String get orderStatusProcessing => 'Inashughulikiwa';

  @override
  String get orderStatusShipped => 'Imetumwa';

  @override
  String get orderStatusDelivery => 'Inatolewa';

  @override
  String get orderStatusCompleted => 'Imekamilika';

  @override
  String get orderStatusCancelled => 'Imeghairiwa';

  @override
  String get orderDetails => 'Maelezo ya Agizo';

  @override
  String placedOn(Object date) {
    return 'Kuwekwa: $date';
  }

  @override
  String estimatedDeliveryDate(Object date) {
    return 'Inatarajiwa Kuletwa: $date';
  }

  @override
  String get orderConfirmed => 'Agizo Limethibitishwa';

  @override
  String get processingOrder => 'Agizo Inashughulikiwa';

  @override
  String get itemShipped => 'Bidhaa Imetumwa';

  @override
  String get itemDelivered => 'Bidhaa Imepokelewa';

  @override
  String get tracking => 'Fuatiliano';

  @override
  String riderLocation(Object name) {
    return '$name anakuja!';
  }

  @override
  String distance(Object distance) {
    return '$distance km karibu';
  }

  @override
  String get refresh => 'Anza Tena';

  @override
  String get myProfile => 'Wasifu Wangu';

  @override
  String get editProfile => 'Hariri Wasifu';

  @override
  String get myAddresses => 'Anwani';

  @override
  String get paymentMethods => 'Njia za Kulipwa';

  @override
  String get afriWalletBalance => 'Hazina ya Afri';

  @override
  String get myWallet => 'Hazina Yangu';

  @override
  String get transactions => 'Miamala';

  @override
  String get wallet => 'Hazina';

  @override
  String get topUp => 'Jaza';

  @override
  String get send => 'Tuma';

  @override
  String get withdraw => 'Toa';

  @override
  String get balance => 'Salio';

  @override
  String get notificationSettings => 'Mipangilio ya Arifa';

  @override
  String get darkMode => 'Hali Giza';

  @override
  String get language => 'Lugha';

  @override
  String get settings => 'Mipangilio';

  @override
  String get helpCenter => 'Kituo cha Usaidizi';

  @override
  String get chatSupport => 'Chati ya Msaada';

  @override
  String get rateApp => 'Tathmini Programu';

  @override
  String get termsOfService => 'Masharti ya Huduma';

  @override
  String get aboutUs => 'Juu Yetu';

  @override
  String get contactUs => 'Wasiliana Nasi';

  @override
  String get signOut => 'Toka';

  @override
  String get faq => 'Swali Linaloulizwa Mara Kwa Mara';

  @override
  String get contactSupport => 'Wasiliana na Msaada';

  @override
  String get howCanWeHelp => 'Tunaweza kukusaidia vipi?';

  @override
  String get sendMessage => 'Tuma';

  @override
  String get typeMessage => 'Andika ujumbe...';

  @override
  String get searchResults => 'Matokeo ya Utafutaji';

  @override
  String get searchField => 'Uga wa Utafutaji';

  @override
  String get startTypingToSearch => 'Anza kuandika kutafuta bidhaa';

  @override
  String searchResultsFor(Object query) {
    return 'Matokeo ya utafutaji kwa \"$query\"';
  }

  @override
  String get enterProductNameToSearch => 'Weka jina la bidhaa kutafuta';

  @override
  String get noProductsFound => 'Hakuna bidhaa zilizopatikana';

  @override
  String get newItems => 'Bidhaa Mpya';

  @override
  String get createBundle => 'Unda Kifurushi';

  @override
  String get createMyBundle => 'Unda Kifurushi Changu';

  @override
  String get myBundles => 'Vifurushi Vyangu';

  @override
  String get editBundle => 'Hariri Kifurushi';

  @override
  String get bundleDetails => 'Maelezo ya Kifurushi';

  @override
  String get bundleName => 'Jina la Kifurushi';

  @override
  String get description => 'Maelezo';

  @override
  String get pricing => 'Bei';

  @override
  String get priceKes => 'Bei (KES)';

  @override
  String get discountPrice => 'Bei ya Punguzo';

  @override
  String get productsInBundle => 'Bidhaa ndani ya Kifurushi';

  @override
  String get addProduct => 'Ongeza Bidhaa';

  @override
  String get addProductComingSoon =>
      'Kazi ya kuongeza bidhaa inakuja hivi karibuni';

  @override
  String get removeProductComingSoon =>
      'Kazi ya kuondoa bidhaa inakuja hivi karibuni';

  @override
  String get saveChanges => 'Hifadhi Mabadiliko';

  @override
  String get deleteBundle => 'Futa Kifurushi';

  @override
  String get bundleUpdatedSuccessfully => 'Kifurushi kimesasishwa!';

  @override
  String get bundleDeleted => 'Kifurushi kimefutwa';

  @override
  String get noBundlesYet => 'Hakuna Vifurushi Bado';

  @override
  String get createFirstBundleToSave =>
      'Unda kifurushi chako cha kwanza ili kujifedha';

  @override
  String get popularPacks => 'Vifurushi maarufu';

  @override
  String get ourNewItem => 'Bidhaa yetu Mpya';

  @override
  String get failedToLoadProducts => 'Imeshindikana kupakia bidhaa';

  @override
  String get checkConnectionAndRetry =>
      'Angalia muunganisho wako wa intaneti na ujaribu tena.';

  @override
  String get failedToSearchProducts =>
      'Angalia muunganisho wako na ujaribu tena kutafuta.';

  @override
  String get tryDifferentKeywords => 'Jaribu kutafuta kwa maneno tofauti';

  @override
  String get failedToLoadCategories => 'Imeshindikana kupakia aina';

  @override
  String get failedToLoadNewItems => 'Imeshindikana kupakia bidhaa mpya';

  @override
  String get failedToLoadPopularPacks =>
      'Imeshindikana kupakia vifurushi maarufu';

  @override
  String get errorLoadingData =>
      'Kuna kitu kimeenda vibaya wakati wa kupakia data';

  @override
  String get aiSearch => 'Utafutaji wa AI';

  @override
  String get searchProductsHint => 'Tafuta bidhaa...';

  @override
  String get suggestions => 'Mapendekezo';

  @override
  String get startSearching => 'Anza Kutafuta';

  @override
  String get typeForAiRecommendations => 'Andika kuona mapendekezo ya AI';

  @override
  String noResultsForQuery(Object query) {
    return 'Hakuna bidhaa zilizopatikana kwa \"$query\"';
  }

  @override
  String get browseCatalog => 'Pitia Orodha';

  @override
  String resultsFound(Object count) {
    return 'Matokeo $count yamepatikana';
  }

  @override
  String get filter => 'Kichujio';

  @override
  String get sortBy => 'Panga Kwa';

  @override
  String get popularity => 'Umaarufu';

  @override
  String get priceRange => 'Kiwango cha Bei';

  @override
  String get brand => 'Brandi';

  @override
  String get ratingStar => 'Nyota ya Tathmini';

  @override
  String get any => 'Yoyote';

  @override
  String get applyFilters => 'Tekeleza Vichujio';

  @override
  String get deleteBundleQuestion => 'Futa Kifurushi?';

  @override
  String get deleteBundleWarning =>
      'Kitendo hiki hakiwezi kutenduliwa. Data yote ya kifurushi itafutwa kabisa.';

  @override
  String get cancel => 'Ghairi';

  @override
  String get confirmDelete => 'Futa';

  @override
  String typeDeleteToConfirm(Object name) {
    return 'Weka \"$name\" kuthibitisha ufutaji';
  }

  @override
  String productLabel(Object name, Object price, Object rating) {
    return '$name, KES $price, nyota $rating';
  }

  @override
  String addToWishlistLabel(Object name) {
    return 'Ongeza $name kwenye orodha ya mapendeleo';
  }

  @override
  String removeFromWishlistLabel(Object name) {
    return 'Ondoa $name kwenye orodha ya mapendeleo';
  }

  @override
  String get addedToWishlist => 'Imeongezwa kwenye orodha ya mapendeleo';

  @override
  String get removedFromWishlist => 'Imeondolewa kutoka orodha ya mapendeleo';

  @override
  String get failedToUpdateWishlist =>
      'Imeshindikana kusasisha orodha ya mapendeleo';

  @override
  String items(Object count) {
    return 'bidhaa $count';
  }

  @override
  String get price => 'Bei';

  @override
  String get officeSupplies => 'Vifaa vya Ofisi';

  @override
  String get gardening => 'Ushamba';

  @override
  String get vegetables => 'Mboga';

  @override
  String get fishAndMeat => 'Samaki Nyama';

  @override
  String get somethingWentWrong => 'Kitu kilisababisha';

  @override
  String get tryAgainLater => 'Tafadhali jaribu tena baadaye';

  @override
  String get noInternet => 'Hakuna Mtandao wa Intaneti';

  @override
  String get checkConnection => 'Tafadhali angalia mtandao wako wa intaneti';

  @override
  String get noResults => 'Hakuna Matokeo Yaliyopatikana';

  @override
  String get tryDifferentSearch => 'Jaribu neno tofauti la utafutaji';

  @override
  String get pageNotFound => 'Ukurasa Haupatikani';

  @override
  String get goHome => 'Rudi Nyumbani';

  @override
  String get loading => 'Inapakia...';

  @override
  String get pleaseWait => 'Tafadhali subiri';

  @override
  String get success => 'Imefanikiwa!';

  @override
  String get error => 'Hitilafu';

  @override
  String get warning => 'Onyo';

  @override
  String get info => 'Habari';

  @override
  String get searchHint => 'Tafuta';

  @override
  String get aiSearchSubtitle => 'Andika kuona mapendekezo ya AI';

  @override
  String get createMyPack => 'Unda Kifurushi Changu';

  @override
  String get bundleUpdated => 'Kifurushi kimehaririwa kwa mafanikio!';

  @override
  String get bundleUpdateFailed =>
      'Imeshindikana kuhariri kifurushi. Tafadhali jaribu tena.';

  @override
  String get deleteBundleConfirm => 'Futa Kifurushi?';

  @override
  String get delete => 'Futa';

  @override
  String get bundleDeleteFailed =>
      'Imeshindikana kufuta kifurushi. Tafadhali jaribu tena.';

  @override
  String get priceKES => 'Bei (KES)';

  @override
  String get createFirstBundle =>
      'Unda kifurushi chako cha kwanza ili kujifaidi';

  @override
  String get applyFilter => 'Tekeleza Vichujio';

  @override
  String get priceLabel => 'Bei';

  @override
  String get anyBrand => 'Yoyote';

  @override
  String get bundleDetailsPage => 'Maelezo ya Kifurushi';

  @override
  String productImage(Object name) {
    return 'Picha ya $name';
  }

  @override
  String addToWishlist(Object name) {
    return 'Ongeza $name kwenye orodha ya matakwa';
  }

  @override
  String removeFromWishlist(Object name) {
    return 'Ondoa $name kwenye orodha ya matakwa';
  }

  @override
  String priceKESLabel(Object amount) {
    return 'Bei KES $amount';
  }

  @override
  String get wishlistUpdated => 'Imeongezwa kwenye orodha ya matakwa';

  @override
  String get wishlistRemoved => 'Imeondolewa kutoka orodha ya matakwa';

  @override
  String get wishlistFailed =>
      'Imeshindikana kusasisha orodha ya matakwa. Tafadhali jaribu tena.';

  @override
  String get totalItems => 'Jumla ya Bidhaa';

  @override
  String get shipping => 'Kutuma';

  @override
  String get totalPrice => 'Bei ya Jumla';

  @override
  String get itemRemovedFromCart => 'Bidhaa imeondolewa kwenye karata';

  @override
  String productsCount(Object count) {
    return 'Bidhaa $count';
  }

  @override
  String get packDetails => 'Maelezo ya Kifurushi';

  @override
  String get includedInThisBundle => 'Imejumlishwa ndani ya hiki kifurushi';

  @override
  String itemCount(Object number) {
    return 'Bidhaa $number';
  }

  @override
  String get pleaseSignInFirst => 'Tafadhali ingia kwanza';

  @override
  String get enterCouponCode => 'Ingiza nambari ya coupon';

  @override
  String get couponRedeemedSuccessfully => 'Coupon imeredeemed kwa mafanikio';

  @override
  String get invalidOrAlreadyUsedCoupon =>
      'Coupon si halali au tayari imetumika';

  @override
  String get offersAndPromos => 'Matoleo na Ofisi';

  @override
  String get cardPayment => 'Malipo ya Kadi';

  @override
  String get stripePayment => 'Stripe';

  @override
  String get paypalPayment => 'PayPal';

  @override
  String payWith(Object method) {
    return 'Lipa kwa $method';
  }

  @override
  String get secureHostedPaymentHint =>
      'Utaelekezwa kwenye ukurasa salama wa malipo ili kukamilisha ununuzi wako.';

  @override
  String get paymentLaunchFailed =>
      'Imeshindwa kufungua ukurasa wa malipo. Tafadhali jaribu tena.';

  @override
  String get paymentInitiationFailed =>
      'Malipo hayakuweza kuanzishwa. Tafadhali jaribu tena.';

  @override
  String get statusLabel => 'Hali';

  @override
  String get orderIdLabel => 'Kitambulisho cha Amri';

  @override
  String get selectPaymentMethod => 'Chagua Njia ya Malipo';

  @override
  String get chooseHowToPay => 'Chagua jinsi ya kulipa';

  @override
  String get payViaMpesaStkPush => 'Lipa kupitia STK Push ya Safaricom M-Pesa';

  @override
  String get visaMastercardViaFlutterwave =>
      'Visa, Mastercard kupitia Flutterwave';

  @override
  String get walletBalance => 'Salio la Akaunti';

  @override
  String get payUsingYourWallet => 'Lipa kwa kutumia akaunti yako ya Groc';

  @override
  String get cashOnDeliveryDesc => 'Lipa wakati amri yako inapofikia';

  @override
  String continueWith(Object method) {
    return 'Endelea na $method';
  }

  @override
  String get mpesaCheckYourPhone => 'Angalia Simu Yako';

  @override
  String mpesaWeVeSent(Object phoneNumber) {
    return 'Tumetuma ombi la malipo kupitia SMS kwa $phoneNumber';
  }

  @override
  String get mpesaEnterPin =>
      'Ingiza PIN yako ya M-Pesa ili kukamilisha malipo';

  @override
  String get mpesaTimeoutTitle => 'Wakati wa Malipo Umepita';

  @override
  String get mpesaTimeoutMessage => 'Ombi lako la malipo limepita wakati';

  @override
  String get mpesaProcessing => 'Inaprosesa Malipo...';

  @override
  String get mpesaResend => 'Tuma Tena Ombi';

  @override
  String get recentSearch => 'Utafutaji wa Karibuni';

  @override
  String get createOwnPack => 'Unda Kifurushi Chako';

  @override
  String get failedToLoadBundles => 'Imeshindikana kupakia vifurushi';

  @override
  String get noBundlesFound => 'Hakuna vifurushi vilivyopatikana';

  @override
  String get bundleInformationMissing => 'Taarifa za kifurushi hazipatikani';

  @override
  String get productInformationMissing => 'Taarifa za bidhaa hazipatikani';

  @override
  String get productDetailsTitle => 'Maelezo ya Bidhaa';

  @override
  String get weight => 'Uzito';

  @override
  String stockAvailable(Object count) {
    return 'Inapatikana ($count zimebaki)';
  }

  @override
  String get itemsLabel => 'Bidhaa';

  @override
  String get reviewsLabel => 'Maoni';

  @override
  String get saveLabel => 'Okoa';

  @override
  String get searchProductHint => 'Tafuta Bidhaa';

  @override
  String get bundleUpdatedFailed =>
      'Imeshindikana kusasisha kifurushi. Tafadhali jaribu tena.';

  @override
  String get searchFilters => 'Vichujio vya Utafutaji';

  @override
  String get clearSearch => 'Futa utafutaji';

  @override
  String get sidebarMenu => 'Menyu ya upande';

  @override
  String get searchButton => 'Tafuta';

  @override
  String get adSpace => 'Matangazo';

  @override
  String get filterButton => 'Chuja bidhaa';

  @override
  String get createPackButton => 'Unda kifurushi chako mwenyewe';

  @override
  String get continueToHome => 'Rudi nyumbani';

  @override
  String get emptyCartTitle => 'Oops!';

  @override
  String get emptyCartMessage => 'Pole, huna bidhaa katika karata yako';

  @override
  String get startBrowsing => 'Anza Kutafuta';

  @override
  String get pleaseLogIn => 'Tafadhali ingia ili kuendelea';

  @override
  String get cartIsEmpty => 'Karata yako ni tupu';

  @override
  String get totalToPay => 'Jumla ya kulipa:';

  @override
  String get processingPaymentLabel => 'Inaprosesa...';

  @override
  String get payNowButton => 'Lipa Sasa';

  @override
  String get securedByFlutterwave => 'Imelindwa na Flutterwave';

  @override
  String paymentFailedError(Object error) {
    return 'Malipo yameshindikana: $error';
  }

  @override
  String get continueButton => 'Endelea';

  @override
  String get selectDeliveryAddress => 'Chagua Anwani ya Kuletwa';

  @override
  String get addNew => 'Ongeza Mpya';

  @override
  String get homeAddress => 'Anwani ya Nyumbani';

  @override
  String get officeAddress => 'Anwani ya Ofisi';

  @override
  String get cardNumberLabel => 'Nambari ya Kadi';

  @override
  String get expiryDateLabel => 'Tarehe ya Kufa';

  @override
  String get cvvLabel => 'CVV';

  @override
  String get cardHolderNameLabel => 'Jina la Mmiliki wa Kadi';

  @override
  String get totalAmountLabel => 'Jumla ya Kiasi';

  @override
  String get resendRequest => 'Tuma Tena Ombi';

  @override
  String get waiting => 'Inasubiri...';

  @override
  String get standardDeliveryDesc => 'Siku 2–4 za biashara';

  @override
  String get standardDeliveryEta => 'Siku 2-4';

  @override
  String get expressDeliveryDesc => 'Kuletwa siku ijayo';

  @override
  String get expressDeliveryEta => 'Siku ijayo';

  @override
  String get bodaBodaSameDay => 'Sarakasi Siku Moja';

  @override
  String get bodaBodaSameDayDesc => 'Leo (Nairobi & Kampala tu)';

  @override
  String get bodaBodaSameDayEta => 'Leo';

  @override
  String get storePickupDesc => 'Chukua katika duka letu';

  @override
  String get storePickupEta => 'Saa 2-3';

  @override
  String get chooseACategory => 'Chagua aina';

  @override
  String get allProducts => 'Bidhaa Zote';

  @override
  String categoryLabel(Object name) {
    return 'Aina ya $name';
  }

  @override
  String browseCategory(Object name) {
    return 'Vinjari $name';
  }

  @override
  String get goBack => 'Rudi';

  @override
  String get vouchers => 'Vochi';

  @override
  String get address => 'Anwani';

  @override
  String get notifications => 'Arifa';

  @override
  String get setting => 'Mipangilio';

  @override
  String get payment => 'Malipo';

  @override
  String get logout => 'Toka';

  @override
  String get firstName => 'Jina la Kwanza';

  @override
  String get lastName => 'Jina la Mwisho';

  @override
  String get phone => 'Simu';

  @override
  String get gender => 'Jinsia';

  @override
  String get birthday => 'Siku ya Kuzaliwa';

  @override
  String get save => 'Hifadhi';

  @override
  String get saving => 'Inahifadhi...';

  @override
  String get profileSavedSuccess => 'Wasifu umehifadhiwa kwa mafanikio';

  @override
  String get profileSaveError => 'Hitilafu wakati wa kuhifadhi wasifu';

  @override
  String get unableToLoadProfile => 'Haiwezi kupakia wasifu';

  @override
  String get couldNotLoadProfile => 'Haiwezi kupakia maelezo ya wasifu';

  @override
  String get checkConnectionRetry =>
      'Tafadhali angalia muunganisho wako na jaribu tena.';

  @override
  String get noSavedPaymentMethodsYet =>
      'Hakuna njia za kulipwa zilizohifadhiwa bado';

  @override
  String get savedPaymentMethods => 'Njia za Kulipwa Zilizohifadhiwa';

  @override
  String get paymentOption => 'Chaguo la Malipo';

  @override
  String get deletePaymentMethodTitle => 'Futa Njia ya Kulipwa';

  @override
  String get deletePaymentMethodConfirm =>
      'Una uhakika unataka kuondoa njia hii ya kulipwa? Kitendo hiki hakiwezi kutenduliwa.';

  @override
  String get newAddress => 'Anwani Mpya';

  @override
  String get phoneRequired => 'Nambari ya simu inahitajika';

  @override
  String get fullAddressName => 'Jina Kamili';

  @override
  String get addressLine1 => 'Anwani Mstari wa 1';

  @override
  String get addressLine2 => 'Anwani Mstari wa 2';

  @override
  String get state => 'Jimbo';

  @override
  String get zipCode => 'Msimu wa Posta';

  @override
  String get makeDefaultShippingAddress =>
      'Weka Kama Anwani ya Kuletwa ya Kawaida';

  @override
  String get pleaseSignInAgainToSave =>
      'Tafadhali ingia tena ili kuhifadhi anwani';

  @override
  String get pleaseSignInAgainToEdit =>
      'Tafadhali ingia tena ili kuhariri wasifu wako.';

  @override
  String get errorLoadingProfile =>
      'Haiwezi kupakia maelezo ya wasifu wako. Buruta kupitia kusasisha au jaribu tena.';

  @override
  String get pleaseSignInAgainToSaveProfile =>
      'Tafadhali ingia tena ili kuhifadhi wasifu';

  @override
  String get unableToLoadPaymentMethods => 'Haiwezi kupakia njia za kulipwa';

  @override
  String get changePassword => 'Badilisha Nenosiri';

  @override
  String get changePhoneNumber => 'Badilisha Nambari ya Simu';

  @override
  String get editHomeAddress => 'Hariri Anwani ya Nyumbani';

  @override
  String get location => 'Eneo';

  @override
  String get profileSetting => 'Mipangilio ya Wasifu';

  @override
  String get deactivateAccount => 'Katisha Akaunti';

  @override
  String get pickLocationOnMap => 'Chagua Eneo kwenye Ramani';

  @override
  String get useThisLocation => 'Tumia Eneo Hili';

  @override
  String get currentLocation => 'Eneo la Sasa';

  @override
  String get searchAddress => 'Tafuta anwani';

  @override
  String get dragToAdjust => 'Sogea ramani kubadilisha eneo';

  @override
  String get locationPermissionDenied => 'Ruhusa ya eneo imekataliwa';

  @override
  String get enableLocationServices => 'Washa huduma za eneo';

  @override
  String get selectedLocation => 'Eneo lililochaguliwa';

  @override
  String get noLocationSelected => 'Hakuna eneo lililochaguliwa';
}
