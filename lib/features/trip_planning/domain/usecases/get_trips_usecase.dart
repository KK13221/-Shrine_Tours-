import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class GetTripsUseCase {
  final ITripsRepository _repository;

  GetTripsUseCase(this._repository);

  Future<Either<Failure, List<Trips>>> call() async {
    return await _repository.getTrips();
  }
}
