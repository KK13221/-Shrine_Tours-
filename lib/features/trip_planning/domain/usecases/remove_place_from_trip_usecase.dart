import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../repositories/places_repository.dart';

class RemovePlaceFromTripUseCase {
  final IPlacesRepository _repository;

  RemovePlaceFromTripUseCase(this._repository);

  Future<Either<Failure, void>> call(RemovePlaceFromTripParams params) async {
    return await _repository.removeFromTrip(params.tripId, params.placeId);
  }
}

class RemovePlaceFromTripParams {
  final String tripId;
  final String placeId;

  RemovePlaceFromTripParams({
    required this.tripId,
    required this.placeId,
  });
}
