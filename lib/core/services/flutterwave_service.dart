import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Flutterwave card payment service
class FlutterwaveService {
  static final FlutterwaveService _instance =
      FlutterwaveService._internal();

  factory FlutterwaveService() => _instance;

  FlutterwaveService._internal();

  static const String _baseUrl = 'https://api.flutterwave.com/v3';

  String get _secretKey => EnvConfig.flutterwaveSecretKey();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      };

  /// Initiate a standard card payment
  Future<FlutterwavePaymentResponse> initiatePayment({
    required String txRef,
    required double amount,
    required String currency,
    required String redirectUrl,
    required String customerEmail,
    required String customerName,
    String? customerPhone,
    String? paymentTitle,
    String? paymentDescription,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final body = {
        'tx_ref': txRef,
        'amount': amount.toString(),
        'currency': currency,
        'redirect_url': redirectUrl,
        'payment_options': 'card,ussd,mobile_money',
        'customer': {
          'email': customerEmail,
          'name': customerName,
          if (customerPhone != null) 'phonenumber': customerPhone,
        },
        'customizations': {
          'title': paymentTitle ?? 'Groc Payment',
          'description': paymentDescription ?? 'Order payment on Groc',
        },
        if (meta != null) 'meta': meta,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/payments'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      Logger.info(
        'Flutterwave initiate response: ${response.statusCode}',
        'FlutterwaveService',
      );

      final data = json.decode(response.body) as Map<String, dynamic>;
      return FlutterwavePaymentResponse.fromJson(data);
    } catch (e) {
      Logger.error('Flutterwave initiatePayment error: $e', 'FlutterwaveService');
      rethrow;
    }
  }

  /// Verify a transaction by its ID
  Future<FlutterwaveVerifyResponse> verifyTransaction(
    String transactionId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/transactions/$transactionId/verify'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = json.decode(response.body) as Map<String, dynamic>;
      return FlutterwaveVerifyResponse.fromJson(data);
    } catch (e) {
      Logger.error(
        'Flutterwave verifyTransaction error: $e',
        'FlutterwaveService',
      );
      rethrow;
    }
  }
}

class FlutterwavePaymentResponse {
  final String status;
  final String message;
  final String? paymentLink;

  FlutterwavePaymentResponse({
    required this.status,
    required this.message,
    this.paymentLink,
  });

  factory FlutterwavePaymentResponse.fromJson(Map<String, dynamic> json) {
    return FlutterwavePaymentResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      paymentLink: (json['data'] as Map<String, dynamic>?)?['link'] as String?,
    );
  }

  bool get isSuccessful => status == 'success';
}

class FlutterwaveVerifyResponse {
  final String status;
  final String message;
  final String? transactionStatus;
  final double? amount;
  final String? currency;
  final String? txRef;

  FlutterwaveVerifyResponse({
    required this.status,
    required this.message,
    this.transactionStatus,
    this.amount,
    this.currency,
    this.txRef,
  });

  factory FlutterwaveVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return FlutterwaveVerifyResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      transactionStatus: data?['status'] as String?,
      amount: (data?['amount'] as num?)?.toDouble(),
      currency: data?['currency'] as String?,
      txRef: data?['tx_ref'] as String?,
    );
  }

  bool get isSuccessful =>
      status == 'success' && transactionStatus == 'successful';
}
