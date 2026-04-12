import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../constants/payment_constants.dart';
import '../utils/logger.dart';

/// Daraja M-Pesa STK Push service
class MpesaService {
  static final MpesaService _instance = MpesaService._internal();

  factory MpesaService() => _instance;

  MpesaService._internal();

  String get _baseUrl => EnvConfig.isProduction()
      ? PaymentConstants.mpesaProductionBaseUrl
      : PaymentConstants.mpesaSandboxBaseUrl;

  /// Obtain an OAuth access token from Safaricom
  Future<String> _getAccessToken() async {
    final key = EnvConfig.mpesaConsumerKey();
    final secret = EnvConfig.mpesaConsumerSecret();
    final credentials = base64Encode(utf8.encode('$key:$secret'));

    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl${PaymentConstants.mpesaOauthEndpoint}?grant_type=client_credentials',
          ),
          headers: {'Authorization': 'Basic $credentials'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['access_token'] as String;
    }
    throw Exception('Failed to get M-Pesa access token: ${response.body}');
  }

  /// Build the M-Pesa password (Base64 of shortcode+passkey+timestamp)
  String _buildPassword(String timestamp) {
    final shortcode = EnvConfig.mpesaBusinessShortcode();
    final passkey = EnvConfig.mpesaPasskey();
    return base64Encode(utf8.encode('$shortcode$passkey$timestamp'));
  }

  /// Current timestamp in yyyyMMddHHmmss format
  String _timestamp() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  /// Initiate STK Push request to user's phone
  Future<MpesaStkResponse> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String orderId,
    String? accountReference,
    String? description,
  }) async {
    try {
      final token = await _getAccessToken();
      final timestamp = _timestamp();
      final password = _buildPassword(timestamp);
      final shortcode = EnvConfig.mpesaBusinessShortcode();
      final callbackUrl = EnvConfig.mpesaCallbackUrl();

      // Normalise phone number to 2547XXXXXXXX format
      String phone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (phone.startsWith('0')) phone = '254${phone.substring(1)}';
      if (!phone.startsWith('254')) phone = '254$phone';

      final body = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.ceil().toString(),
        'PartyA': phone,
        'PartyB': shortcode,
        'PhoneNumber': phone,
        'CallBackURL': callbackUrl,
        'AccountReference': accountReference ?? orderId,
        'TransactionDesc': description ?? 'Groc order payment',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl${PaymentConstants.mpesaStkPushEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      Logger.info(
        'M-Pesa STK Push response: ${response.statusCode}',
        'MpesaService',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return MpesaStkResponse.fromJson(data);
      }
      throw Exception('M-Pesa STK Push failed: ${response.body}');
    } catch (e) {
      Logger.error('M-Pesa initiateStkPush error: $e', 'MpesaService');
      rethrow;
    }
  }

  /// Query the status of an STK Push request
  Future<MpesaStkQueryResponse> queryStkStatus({
    required String checkoutRequestId,
  }) async {
    try {
      final token = await _getAccessToken();
      final timestamp = _timestamp();
      final password = _buildPassword(timestamp);
      final shortcode = EnvConfig.mpesaBusinessShortcode();

      final body = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl${PaymentConstants.mpesaStkQueryEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return MpesaStkQueryResponse.fromJson(data);
      }
      throw Exception('M-Pesa query failed: ${response.body}');
    } catch (e) {
      Logger.error('M-Pesa queryStkStatus error: $e', 'MpesaService');
      rethrow;
    }
  }
}

class MpesaStkResponse {
  final String merchantRequestId;
  final String checkoutRequestId;
  final String responseCode;
  final String responseDescription;
  final String customerMessage;

  MpesaStkResponse({
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.responseCode,
    required this.responseDescription,
    required this.customerMessage,
  });

  factory MpesaStkResponse.fromJson(Map<String, dynamic> json) {
    return MpesaStkResponse(
      merchantRequestId: json['MerchantRequestID'] as String? ?? '',
      checkoutRequestId: json['CheckoutRequestID'] as String? ?? '',
      responseCode: json['ResponseCode'] as String? ?? '',
      responseDescription: json['ResponseDescription'] as String? ?? '',
      customerMessage: json['CustomerMessage'] as String? ?? '',
    );
  }

  bool get isSuccessful => responseCode == '0';
}

class MpesaStkQueryResponse {
  final String responseCode;
  final String responseDescription;
  final String merchantRequestId;
  final String checkoutRequestId;
  final String resultCode;
  final String resultDesc;

  MpesaStkQueryResponse({
    required this.responseCode,
    required this.responseDescription,
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.resultCode,
    required this.resultDesc,
  });

  factory MpesaStkQueryResponse.fromJson(Map<String, dynamic> json) {
    return MpesaStkQueryResponse(
      responseCode: json['ResponseCode'] as String? ?? '',
      responseDescription: json['ResponseDescription'] as String? ?? '',
      merchantRequestId: json['MerchantRequestID'] as String? ?? '',
      checkoutRequestId: json['CheckoutRequestID'] as String? ?? '',
      resultCode: json['ResultCode'] as String? ?? '',
      resultDesc: json['ResultDesc'] as String? ?? '',
    );
  }

  /// 0 = success, 1017 = user cancelled, 1032 = request cancelled, etc.
  bool get isCompleted => resultCode == '0';
  bool get isCancelled => resultCode == '1032' || resultCode == '1017';
  bool get isPending => resultCode.isEmpty || resultCode == '1037';
}
