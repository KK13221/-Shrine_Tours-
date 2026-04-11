import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await _repository.resetPassword(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
