import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class DeleteTripUseCase {
  final ITripsRepository _repository;

  DeleteTripUseCase(this._repository);

  Future<Either<Failure, void>> call(String tripId) async {
    return await _repository.deleteTrip(tripId);
  }
}
