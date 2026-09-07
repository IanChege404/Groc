import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Stripe payment service using Checkout Sessions (hosted payment page).
class StripeService {
  static final StripeService _instance = StripeService._internal();

  factory StripeService() => _instance;

  StripeService._internal();

  static const String _baseUrl = 'https://api.stripe.com/v1';

  String get _secretKey => EnvConfig.stripeSecretKey();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  /// Create a Checkout Session and return the hosted payment URL.
  Future<StripeCheckoutResponse> createCheckoutSession({
    required String orderId,
    required double amount,
    required String currency,
    required String customerEmail,
    String? customerName,
  }) async {
    try {
      final amountInMinor = (amount * 100).round();

      final body = {
        'mode': 'payment',
        'success_url': 'https://groc.app/payment/success?order_id=$orderId',
        'cancel_url': 'https://groc.app/payment/cancel?order_id=$orderId',
        'client_reference_id': orderId,
        'customer_email': customerEmail,
        if (customerName != null) 'customer_name': customerName,
        'line_items[0][quantity]': '1',
        'line_items[0][price_data][currency]': currency.toLowerCase(),
        'line_items[0][price_data][unit_amount]': '$amountInMinor',
        'line_items[0][price_data][product_data][name]': 'Groc Order $orderId',
        'line_items[0][price_data][product_data][description]':
            'Order payment on Groc',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/checkout/sessions'),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      Logger.info(
        'Stripe create session response: ${response.statusCode}',
        'StripeService',
      );

      final data = json.decode(response.body) as Map<String, dynamic>;
      return StripeCheckoutResponse.fromJson(data);
    } catch (e) {
      Logger.error('Stripe createCheckoutSession error: $e', 'StripeService');
      rethrow;
    }
  }

  /// Retrieve a Checkout Session by id to verify payment status.
  Future<StripeSessionStatus> retrieveSession(String sessionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/checkout/sessions/$sessionId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = json.decode(response.body) as Map<String, dynamic>;
      return StripeSessionStatus(
        id: data['id'] as String? ?? sessionId,
        paymentStatus: data['payment_status'] as String? ?? 'unpaid',
      );
    } catch (e) {
      Logger.error('Stripe retrieveSession error: $e', 'StripeService');
      rethrow;
    }
  }
}

class StripeCheckoutResponse {
  final String id;
  final String url;
  final String? error;

  StripeCheckoutResponse({
    required this.id,
    required this.url,
    this.error,
  });

  bool get isSuccess => error == null && url.isNotEmpty;

  factory StripeCheckoutResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      final errorJson = json['error'] as Map<String, dynamic>;
      return StripeCheckoutResponse(
        id: '',
        url: '',
        error: errorJson['message'] as String? ?? 'Stripe error',
      );
    }
    return StripeCheckoutResponse(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class StripeSessionStatus {
  final String id;
  final String paymentStatus;

  StripeSessionStatus({required this.id, required this.paymentStatus});

  bool get isPaid => paymentStatus == 'paid';
}
