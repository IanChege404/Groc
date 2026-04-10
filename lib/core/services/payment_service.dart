import '../config/api_endpoints.dart';
import '../config/env_config.dart';
import '../network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  /// Initiate payment
  Future<ApiResponse<PaymentInitiation>> initiatePayment({
    required String orderId,
    required double amount,
    required String currency,
    String? description,
  }) {
    return _apiClient.post<PaymentInitiation>(
      ApiEndpoints.initiatePayment,
      body: {
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'description': description,
      },
      fromJson: (json) => PaymentInitiation.fromJson(json),
    );
  }

  /// Initiate M-Pesa payment
  Future<ApiResponse<MpesaPaymentResponse>> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    required String orderId,
  }) {
    // Ensure phone number is in correct format (254XXXXXXXXX)
    String formattedPhone = _formatPhoneNumber(phoneNumber);

    return _apiClient.post<MpesaPaymentResponse>(
      ApiEndpoints.mpesaPayment,
      body: {
        'phone_number': formattedPhone,
        'amount': amount,
        'order_id': orderId,
        'merchant_key': EnvConfig.mpesaConsumerKey(),
        'shortcode': EnvConfig.mpesaBusinessShortcode(),
      },
      fromJson: (json) => MpesaPaymentResponse.fromJson(json),
    );
  }

  /// Confirm payment after transaction
  Future<ApiResponse<PaymentConfirmation>> confirmPayment({
    required String paymentId,
    required String transactionId,
  }) {
    return _apiClient.post<PaymentConfirmation>(
      ApiEndpoints.confirmPayment(paymentId),
      body: {'transaction_id': transactionId},
      fromJson: (json) => PaymentConfirmation.fromJson(json),
    );
  }

  /// Get payment status
  Future<ApiResponse<PaymentStatus>> getPaymentStatus(String paymentId) {
    return _apiClient.get<PaymentStatus>(
      ApiEndpoints.getPaymentStatus(paymentId),
      fromJson: (json) => PaymentStatus.fromJson(json),
    );
  }

  /// Format phone number to M-Pesa format (254XXXXXXXXX)
  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // Handle different formats
    if (digits.startsWith('254')) {
      return digits;
    } else if (digits.startsWith('0')) {
      return '254${digits.substring(1)}';
    } else if (digits.length == 9) {
      return '254$digits';
    }

    return digits.length >= 12 ? digits : '254$digits';
  }
}

class PaymentInitiation {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  PaymentInitiation({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory PaymentInitiation.fromJson(Map<String, dynamic> json) {
    return PaymentInitiation(
      paymentId: json['payment_id'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MpesaPaymentResponse {
  final String checkoutRequestId;
  final String responseCode;
  final String responseDescription;
  final String merchantRequestId;
  final String customerMessage;

  MpesaPaymentResponse({
    required this.checkoutRequestId,
    required this.responseCode,
    required this.responseDescription,
    required this.merchantRequestId,
    required this.customerMessage,
  });

  factory MpesaPaymentResponse.fromJson(Map<String, dynamic> json) {
    return MpesaPaymentResponse(
      checkoutRequestId: json['CheckoutRequestID'] as String? ?? '',
      responseCode: json['ResponseCode'] as String? ?? '',
      responseDescription: json['ResponseDescription'] as String? ?? '',
      merchantRequestId: json['MerchantRequestID'] as String? ?? '',
      customerMessage: json['CustomerMessage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CheckoutRequestID': checkoutRequestId,
      'ResponseCode': responseCode,
      'ResponseDescription': responseDescription,
      'MerchantRequestID': merchantRequestId,
      'CustomerMessage': customerMessage,
    };
  }

  bool get isSuccessful => responseCode == '0';
}

class PaymentConfirmation {
  final String paymentId;
  final String orderId;
  final String status;
  final String transactionId;
  final DateTime confirmedAt;

  PaymentConfirmation({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.transactionId,
    required this.confirmedAt,
  });

  factory PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmation(
      paymentId: json['payment_id'] as String,
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'status': status,
      'transaction_id': transactionId,
      'confirmed_at': confirmedAt.toIso8601String(),
    };
  }
}

class PaymentStatus {
  final String paymentId;
  final String status;
  final String? transactionId;
  final double amount;
  final String currency;
  final DateTime? paidAt;
  final String? failureReason;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    this.transactionId,
    required this.amount,
    this.currency = 'KES',
    this.paidAt,
    this.failureReason,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      paymentId: json['payment_id'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'status': status,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'paid_at': paidAt?.toIso8601String(),
      'failure_reason': failureReason,
    };
  }

  bool get isCompleted => status == 'completed' || status == 'success';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed' || status == 'error';
}
