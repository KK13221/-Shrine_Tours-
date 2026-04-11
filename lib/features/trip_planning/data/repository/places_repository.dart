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
}
