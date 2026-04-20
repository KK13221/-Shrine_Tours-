import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/places_data_source.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import 'package:shrine_tours/features/trip_planning/domain/repositories/places_repository.dart';

class PlacesRepository implements IPlacesRepository {
  final PlacesDataSource _dataSource;

  PlacesRepository(this._dataSource);

  @override
  Future<Either<Failure, List<Place>>> getPlaces(String city) async {
    try {
      final places = await _dataSource.getPlaces(city);
      return Right(places);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to load places: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getSuggestedPlaces(String city) async {
    try {
      final places = await _dataSource.getSuggestedPlaces(city);
      return Right(places);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to load suggested places: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPlaceToTrip(
      String tripId, String placeId) async {
    try {
      await _dataSource.addPlaceToTrip(body: {
        'trip_id': tripId,
        'place_id': placeId,
      });
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to add place to trip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromTrip(
      String tripId, String placeId) async {
    try {
      await _dataSource.removeFromTrip(body: {
        'trip_id': tripId,
        'place_id': placeId,
      });
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to remove place from trip: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> searchPlaces(String query) async {
    try {
      final places = await _dataSource.searchPlaces(query);
      return Right(places);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to search places: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> searchPlacesFromGoogle(
      String query) async {
    try {
      final predictions = await _dataSource.searchPlacesFromGoogle(query);
      return Right(predictions);
    } catch (e) {
      return Left(ApiFailure('Failed to search places from Google: $e'));
    }
  }

  @override
  Future<Either<Failure, Place>> getPlaceDetails(String placeId) async {
    try {
      final place = await _dataSource.getPlaceDetails(placeId);
      return Right(place);
    } catch (e) {
      return Left(ApiFailure('Failed to get place details from Google: $e'));
    }
  }
}
