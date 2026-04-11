import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class AddPlaceToTripParams {
  final String tripId;
  final String placeId;

  AddPlaceToTripParams({
    required this.tripId,
    required this.placeId,
  });
}

class AddPlaceToTripUseCase {
  final ITripsRepository _repository;

  AddPlaceToTripUseCase(this._repository);

  Future<Either<Failure, void>> call(AddPlaceToTripParams params) async {
    return await _repository.addPlaceToTrip(params);
  }
}
