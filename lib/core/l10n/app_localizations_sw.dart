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
  String get standardDelivery => 'Kuletwa Kawaida (Siku 2-4)';

  @override
  String get expressDelivery => 'Kuletwa Haraka (Siku ijayo)';

  @override
  String get sameDayDelivery => 'Kuletwa Siku Moja (Leo)';

  @override
  String get storePickup => 'Mkutano katika Duka';

  @override
  String get free => 'Bure';

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
  String requestExpiresIn(Object minutes, Object seconds) {
    return 'Ombi linaishia $minutes:$seconds';
  }

  @override
  String get tryAgain => 'Jaribu Tena';

  @override
  String get payNow => 'Lipa Sasa';

  @override
  String get processingPayment => 'Inashughulikia...';

  @override
  String get confirmPaymentTitle => 'Thibitisha Malipo';

  @override
  String confirmPaymentMessage(Object amount, Object phoneNumber) {
    return 'Utatozwa KES $amount kupitia M-Pesa kwa $phoneNumber. Je, unataka kuendelea?';
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
  String get rememberCardDetails => 'Kumbuka Maelezo ya Kadi Yangu';

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
  String get invalidPhoneNumber =>
      'Weka nambari sahihi ya simu ya Kenya, mfano +254712345678';

  @override
  String get orderCreationFailed =>
      'Hatukuweza kuunda agizo lako. Tafadhali angalia muunganisho wako na ujaribu tena.';

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
  String get allOrders => 'Zote';

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
  String get failedToLoadProducts =>
      'Imeshindikana kupakia bidhaa. Angalia muunganisho wako na ujaribu tena.';

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
  String get searchHint => 'Tafuta bidhaa...';

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
}
