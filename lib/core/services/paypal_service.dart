import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../utils/logger.dart';

/// PayPal payment service using the Orders API v2 (hosted approval flow).
class PaypalService {
  static final PaypalService _instance = PaypalService._internal();

  factory PaypalService() => _instance;

  PaypalService._internal();

  static const String _baseUrl = 'https://api-m.sandbox.paypal.com';

  String get _clientId => EnvConfig.paypalClientId();

  String get _secretKey => EnvConfig.paypalSecretKey();

  String get _basicAuth =>
      'Basic ${base64Encode(utf8.encode('$_clientId:$_secretKey'))}';

  /// Exchange client credentials for an access token.
  Future<String> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/oauth2/token'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('PayPal token error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  /// Create an order and return the hosted approval URL.
  Future<PaypalOrderResponse> createOrder({
    required String orderId,
    required double amount,
    required String currency,
    String? returnUrl,
  }) async {
    try {
      final token = await _getAccessToken();

      final body = {
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'reference_id': orderId,
            'description': 'Groc order $orderId payment',
            'amount': {
              'currency_code': currency,
              'value': amount.toStringAsFixed(2),
            },
          },
        ],
        'application_context': {
          'brand_name': 'Groc',
          'user_action': 'PAY_NOW',
          'shipping_preference': 'NO_SHIPPING',
          if (returnUrl != null) 'return_url': returnUrl,
          'cancel_url': 'https://groc.app/payment/cancel?order_id=$orderId',
        },
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/v2/checkout/orders'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      Logger.info(
        'PayPal create order response: ${response.statusCode}',
        'PaypalService',
      );

      final data = json.decode(response.body) as Map<String, dynamic>;
      return PaypalOrderResponse.fromJson(data);
    } catch (e) {
      Logger.error('PayPal createOrder error: $e', 'PaypalService');
      rethrow;
    }
  }

  /// Capture an approved order.
  Future<bool> captureOrder(String paypalOrderId) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders/$paypalOrderId/capture'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      Logger.info(
        'PayPal capture status: $status',
        'PaypalService',
      );
      return status == 'COMPLETED';
    } catch (e) {
      Logger.error('PayPal captureOrder error: $e', 'PaypalService');
      rethrow;
    }
  }
}

class PaypalOrderResponse {
  final String id;
  final String approveUrl;
  final String? error;

  PaypalOrderResponse({
    required this.id,
    required this.approveUrl,
    this.error,
  });

  bool get isSuccess => error == null && approveUrl.isNotEmpty;

  factory PaypalOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      final errorJson = json['error'] as Map<String, dynamic>;
      return PaypalOrderResponse(
        id: '',
        approveUrl: '',
        error: errorJson['message'] as String? ?? 'PayPal error',
      );
    }
    final links = (json['links'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    String approveUrl = '';
    for (final link in links) {
      if (link['rel'] == 'approve') {
        approveUrl = link['href'] as String? ?? '';
        break;
      }
    }
    return PaypalOrderResponse(
      id: json['id'] as String? ?? '',
      approveUrl: approveUrl,
    );
  }
}
