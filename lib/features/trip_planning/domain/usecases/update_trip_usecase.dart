import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';

class UpdateTripParams {
  final String id;
  final String city;
  final String startDate;
  final String endDate;
  final int adults;
  final int kids;
  final int tripStyle;
  final String purposeOfTravel;

  UpdateTripParams({
    required this.id,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.kids,
    required this.tripStyle,
    required this.purposeOfTravel,
  });
}

class UpdateTripUseCase {
  final ITripsRepository _repository;

  UpdateTripUseCase(this._repository);

  Future<Either<Failure, Trips>> call(UpdateTripParams params) async {
    return await _repository.updateTrip(params);
  }
}
