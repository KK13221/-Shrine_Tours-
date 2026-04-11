import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import '../repositories/profile_repository.dart';

class GetPaymentMethodsUseCase {
  final IProfileRepository _repository;

  GetPaymentMethodsUseCase(this._repository);

  Future<Either<Failure, List<PaymentCardModel>>> call() async {
    return await _repository.getPaymentMethods();
  }
}
