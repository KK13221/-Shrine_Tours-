import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/packing_repository.dart';

class UpdateTransportsUseCase {
  final IPackingRepository repository;

  UpdateTransportsUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String tripId,
    required List<String> transports,
  }) async {
    return await repository.updateTransports(
      tripId: tripId,
      transports: transports,
    );
  }
}
