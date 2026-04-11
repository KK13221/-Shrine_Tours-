import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/trips_data_source.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/add_place_to_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/create_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/update_trip_usecase.dart';

abstract class ITripsRepository {
  /// Fetch trips from API
  Future<Either<Failure, List<Trips>>> getTrips();

  /// Create a new trip
  Future<Either<Failure, Trips>> createTrip(CreateTripParams params);

  /// Add a place to a trip
  Future<Either<Failure, void>> addPlaceToTrip(AddPlaceToTripParams params);

  /// Update an existing trip
  Future<Either<Failure, Trips>> updateTrip(UpdateTripParams params);

  /// Delete a trip by id
  Future<Either<Failure, void>> deleteTrip(String tripId);
}

class TripsRepository implements ITripsRepository {
  final TripsDataSource _dataSource;

  TripsRepository(this._dataSource);

  @override
  Future<Either<Failure, List<Trips>>> getTrips() async {
    try {
      final trips = await _dataSource.getTrips();
      return Right(trips);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to fetch trips: $e'));
    }
  }

  @override
  Future<Either<Failure, Trips>> createTrip(CreateTripParams params) async {
    try {
      final trip = await _dataSource.createTrip(
        body: {
          'city': params.city,
          'start_date': params.startDate,
          'end_date': params.endDate,
          'adults': params.adults,
          'kids': params.kids,
          'trip_style': params.tripStyle,
          'purpose_of_travel': params.purposeOfTravel,
        },
      );
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to create trip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPlaceToTrip(
      AddPlaceToTripParams params) async {
    try {
      await _dataSource.addPlaceToTrip(
        body: {
          'trip_id': params.tripId,
          'place_id': params.placeId,
        },
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to add place to trip: $e'));
    }
  }

  @override
  Future<Either<Failure, Trips>> updateTrip(UpdateTripParams params) async {
    try {
      final trip = await _dataSource.updateTrip(
        params.id,
        body: {
          'city': params.city,
          'start_date': params.startDate,
          'end_date': params.endDate,
          'adults': params.adults,
          'kids': params.kids,
          'trip_style': params.tripStyle,
          'purpose_of_travel': params.purposeOfTravel,
        },
      );
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to update trip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    try {
      await _dataSource.deleteTrip(tripId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to delete trip: $e'));
    }
  }
}
