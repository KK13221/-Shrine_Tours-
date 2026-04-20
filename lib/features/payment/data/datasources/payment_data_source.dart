import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import '../models/payment_models.dart';

abstract class PaymentDataSource {
  Future<PaymentOrderResponse> createOrder(PaymentOrderRequest request);
  Future<PaymentVerifyResponse> verifyPayment(PaymentVerifyRequest request);
  Future<OrderHistoryResponse> getOrderHistory();
  Future<PaymentOrderResponse> getOrderById(String id);
  Future<void> downloadInvoice(String id, String savePath);
}

class PaymentDataSourceImpl implements PaymentDataSource {
  final ApiClient _apiClient;

  PaymentDataSourceImpl(this._apiClient);

  @override
  Future<PaymentOrderResponse> createOrder(PaymentOrderRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.createOrder,
      body: request.toJson(),
    );

    if (response != null && response['success'] == true) {
      return PaymentOrderResponse.fromJson(response);
    } else {
      throw Exception(response?['message'] ?? 'Failed to create order');
    }
  }

  @override
  Future<PaymentVerifyResponse> verifyPayment(
      PaymentVerifyRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.verifyPayment,
      body: request.toJson(),
    );

    if (response != null && response['success'] == true) {
      return PaymentVerifyResponse.fromJson(response);
    } else {
      throw Exception(response?['message'] ?? 'Failed to verify payment');
    }
  }

  @override
  Future<OrderHistoryResponse> getOrderHistory() async {
    final response = await _apiClient.get(ApiConstants.getOrders);

    if (response != null && response['success'] == true) {
      return OrderHistoryResponse.fromJson(response);
    } else {
      throw Exception(response?['message'] ?? 'Failed to get order history');
    }
  }

  @override
  Future<PaymentOrderResponse> getOrderById(String id) async {
    final response = await _apiClient.get('${ApiConstants.getOrders}/$id');

    if (response != null && response['success'] == true) {
      return PaymentOrderResponse.fromJson(response);
    } else {
      throw Exception(response?['message'] ?? 'Failed to get order details');
    }
  }

  @override
  Future<void> downloadInvoice(String id, String savePath) async {
    await _apiClient.downloadFile(
      '${ApiConstants.getInvoice}$id/invoice',
      savePath,
    );
  }
}
