import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/model/user_profile_model.dart';
import 'package:shrine_tours/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, UserProfileModel>> call() async {
    return await _repository.getProfile();
  }
}
