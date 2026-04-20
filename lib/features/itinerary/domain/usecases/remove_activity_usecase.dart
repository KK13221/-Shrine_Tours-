import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';

class RemoveActivityUseCase {
  final IItineraryRepository _repository;

  RemoveActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(String activityId) async {
    return await _repository.removeActivity(activityId);
  }
}
