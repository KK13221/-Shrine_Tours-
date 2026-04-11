import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/model/subscription_model.dart';
import '../repositories/profile_repository.dart';

class GetSubscriptionUseCase {
  final IProfileRepository _repository;

  GetSubscriptionUseCase(this._repository);

  Future<Either<Failure, SubscriptionModel>> call() async {
    return await _repository.getSubscription();
  }
}
