import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../../data/models/payment_models.dart';
import '../repositories/payment_repository.dart';

class GetOrderHistoryUseCase {
  final PaymentRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  Future<Either<Failure, OrderHistoryResponse>> call() async {
    return await _repository.getOrderHistory();
  }
}
