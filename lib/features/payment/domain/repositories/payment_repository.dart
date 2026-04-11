import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../../data/models/payment_models.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentOrderResponse>> createOrder(PaymentOrderRequest request);
  Future<Either<Failure, PaymentVerifyResponse>> verifyPayment(PaymentVerifyRequest request);
  Future<Either<Failure, OrderHistoryResponse>> getOrderHistory();
  Future<Either<Failure, void>> downloadInvoice(String id, String savePath);
}
