import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/payment_repository.dart';
import '../../data/models/payment_models.dart';

class CreateOrderUseCase {
  final PaymentRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, PaymentOrderResponse>> call(PaymentOrderRequest request) {
    return repository.createOrder(request);
  }
}
