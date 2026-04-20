import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class CreateTripParams {
  final String city;
  final String startDate;
  final String endDate;
  final int adults;
  final int kids;
  final int tripStyle;
  final String purposeOfTravel;
  final Place? startingPoint;

  CreateTripParams({
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.kids,
    required this.tripStyle,
    required this.purposeOfTravel,
    this.startingPoint,
  });
}

class CreateTripUseCase {
  final ITripsRepository _repository;

  CreateTripUseCase(this._repository);

  Future<Either<Failure, Trips>> call(CreateTripParams params) async {
    return await _repository.createTrip(params);
  }
}
