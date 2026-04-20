import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_data_source.dart';
import '../models/payment_models.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDataSource _dataSource;

  PaymentRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, PaymentOrderResponse>> createOrder(PaymentOrderRequest request) async {
    try {
      final response = await _dataSource.createOrder(request);
      return Right(response);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to create order: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentVerifyResponse>> verifyPayment(PaymentVerifyRequest request) async {
    try {
      final response = await _dataSource.verifyPayment(request);
      return Right(response);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to verify payment: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderHistoryResponse>> getOrderHistory() async {
    try {
      final response = await _dataSource.getOrderHistory();
      return Right(response);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to get order history: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentOrderResponse>> getOrderById(String id) async {
    try {
      final response = await _dataSource.getOrderById(id);
      return Right(response);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to get order details: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> downloadInvoice(String id, String savePath) async {
    try {
      await _dataSource.downloadInvoice(id, savePath);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to download invoice: $e'));
    }
  }
}
