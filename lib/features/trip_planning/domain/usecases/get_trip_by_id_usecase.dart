import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trip_detail_response.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class GetTripByIdUseCase {
  final ITripsRepository _repository;

  GetTripByIdUseCase(this._repository);

  Future<Either<Failure, TripDetailResponse>> call(String tripId) {
    return _repository.getTripById(tripId);
  }
}
