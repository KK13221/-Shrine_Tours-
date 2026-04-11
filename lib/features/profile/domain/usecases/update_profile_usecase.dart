import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/model/user_profile_model.dart';
import 'package:shrine_tours/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserProfileModel>> call(Map<String, dynamic> profileData) async {
    return await _repository.updateProfile(profileData);
  }
}