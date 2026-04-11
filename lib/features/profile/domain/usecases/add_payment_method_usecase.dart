import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import '../repositories/profile_repository.dart';

class AddPaymentMethodUseCase {
  final IProfileRepository _repository;

  AddPaymentMethodUseCase(this._repository);

  Future<Either<Failure, PaymentCardModel>> call(Map<String, dynamic> body) async {
    return await _repository.addPaymentMethod(body);
  }
}
