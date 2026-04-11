class PaymentOrderRequest {
  final String planCode;

  PaymentOrderRequest({required this.planCode});

  Map<String, dynamic> toJson() => {
        'planCode': planCode,
      };
}

class PaymentOrderResponse {
  final bool success;
  final String message;
  final PaymentOrderData? data;

  PaymentOrderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PaymentOrderData.fromJson(json['data']) : null,
    );
  }
}

class PaymentOrderData {
  final String id;
  final String planCode;
  final double amount;
  final String currency;
  final String status;
  final String razorpayKey;
  final String razorpayOrderId;
  final String receipt;
  final String? paidAt;
  final String createdAt;

  PaymentOrderData({
    required this.id,
    required this.planCode,
    required this.amount,
    required this.currency,
    required this.status,
    required this.razorpayKey,
    required this.razorpayOrderId,
    required this.receipt,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentOrderData.fromJson(Map<String, dynamic> json) {
    return PaymentOrderData(
      id: json['id'] ?? '',
      planCode: json['planCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      razorpayKey: json['razorpayKey'] ?? '',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      receipt: json['receipt'] ?? '',
      paidAt: json['paidAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class PaymentVerifyRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  PaymentVerifyRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() => {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      };
}

class PaymentVerifyResponse {
  final bool success;
  final String message;
  final PaymentVerifyData? data;

  PaymentVerifyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentVerifyResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PaymentVerifyData.fromJson(json['data']) : null,
    );
  }
}

class PaymentVerifyData {
  final String orderId;
  final String paymentId;
  final String status;
  final String subscriptionPlan;
  final String? paidAt;

  PaymentVerifyData({
    required this.orderId,
    required this.paymentId,
    required this.status,
    required this.subscriptionPlan,
    this.paidAt,
  });

  factory PaymentVerifyData.fromJson(Map<String, dynamic> json) {
    return PaymentVerifyData(
      orderId: json['orderId'] ?? '',
      paymentId: json['paymentId'] ?? '',
      status: json['status'] ?? '',
      subscriptionPlan: json['subscriptionPlan'] ?? '',
      paidAt: json['paidAt'],
    );
  }
}

class OrderHistoryResponse {
  final bool success;
  final String message;
  final List<PaymentOrderData> data;

  OrderHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => PaymentOrderData.fromJson(item))
              .toList() ??
          [],
    );
  }
}
