import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/payment_repository.dart';
import '../../data/models/payment_models.dart';

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Either<Failure, PaymentVerifyResponse>> call(PaymentVerifyRequest request) {
    return repository.verifyPayment(request);
  }
}
