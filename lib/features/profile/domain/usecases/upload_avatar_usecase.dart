import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final IProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<Either<Failure, String>> call(String filePath) async {
    return await _repository.uploadAvatar(filePath);
  }
}