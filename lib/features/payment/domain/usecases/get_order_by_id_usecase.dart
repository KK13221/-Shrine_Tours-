import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/payment_repository.dart';
import '../../data/models/payment_models.dart';

class GetOrderByIdUseCase {
  final PaymentRepository _repository;

  GetOrderByIdUseCase(this._repository);

  Future<Either<Failure, PaymentOrderResponse>> call(String id) async {
    return await _repository.getOrderById(id);
  }
}
