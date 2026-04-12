/// Payment method identifiers
class PaymentConstants {
  // Payment methods
  static const String mpesa = 'mpesa';
  static const String card = 'card';
  static const String wallet = 'wallet';
  static const String cashOnDelivery = 'cash_on_delivery';

  // Payment statuses
  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';
  static const String statusRefunded = 'refunded';

  // M-Pesa specific
  static const String mpesaSandboxBaseUrl =
      'https://sandbox.safaricom.co.ke';
  static const String mpesaProductionBaseUrl =
      'https://api.safaricom.co.ke';
  static const String mpesaOauthEndpoint = '/oauth/v1/generate';
  static const String mpesaStkPushEndpoint =
      '/mpesa/stkpush/v1/processrequest';
  static const String mpesaStkQueryEndpoint =
      '/mpesa/stkpushquery/v1/query';
  static const int mpesaTransactionType = 4; // CustomerPayBillOnline = 4

  // Flutterwave specific
  static const String flutterwaveSandboxBaseUrl =
      'https://api.flutterwave.com/v3';
  static const String flutterwaveProductionBaseUrl =
      'https://api.flutterwave.com/v3';
  static const String flutterwavePaymentEndpoint = '/payments';
  static const String flutterwaveVerifyEndpoint = '/transactions';

  // Currency
  static const String currencyKes = 'KES';
  static const String currencyUsd = 'USD';

  // Loyalty points: earn 10 points per KES 100 spent
  static const double pointsPerKes = 0.1;
  // Redeem: 100 points = KES 1
  static const double kesPerPoint = 0.01;

  // Loyalty tiers — minimum total points required per tier (index = tier - 1)
  // tier 1 = Bronze (0), tier 2 = Silver (500), tier 3 = Gold (2000), tier 4 = Platinum (5000)
  static const List<int> loyaltyTierThresholds = [0, 500, 2000, 5000];
  static const List<String> loyaltyTierNames = [
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
  ];

  // Minimum amounts
  static const double minMpesaAmount = 1.0;
  static const double maxMpesaAmount = 150000.0;
  static const int minRedeemablePoints = 100;
}
