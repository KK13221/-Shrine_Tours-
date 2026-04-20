import 'package:dartz/dartz.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/failures.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../datasource/itinerary_datasource.dart';
import '../model/itinerary_model.dart';

class ItineraryRepositoryImpl implements IItineraryRepository {
  final ItineraryDataSource _dataSource;

  ItineraryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ItineraryModel>> generateItinerary({
    required String tripId,
    required String city,
    required int days,
  }) async {
    try {
      final response = await _dataSource.generateItinerary(
        tripId: tripId,
        city: city,
        days: days,
      );

      if (response.success && response.data != null) {
        return Right(
            ItineraryModel.fromJson(response.data as Map<String, dynamic>));
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error occurred'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItineraryModel>> getItinerary(String id) async {
    try {
      final response = await _dataSource.getItinerary(id);

      if (response.success && response.data != null) {
        return Right(
            ItineraryModel.fromJson(response.data as Map<String, dynamic>));
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error occurred'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItineraryModel>> modifyItinerary({
    required String tripId,
    required String city,
    required int days,
    required String itineraryId,
  }) async {
    try {
      final response = await _dataSource.modifyItinerary(
        tripId: tripId,
        city: city,
        days: days,
        itineraryId: itineraryId,
      );

      if (response.success && response.data != null) {
        return Right(
            ItineraryModel.fromJson(response.data as Map<String, dynamic>));
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error occurred'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addActivity({
    required String itineraryId,
    required int dayNumber,
    required String time,
    required String title,
    required String duration,
    required double cost,
    required String icon,
    required String placeId,
  }) async {
    try {
      final response = await _dataSource.addActivity(
        itineraryId: itineraryId,
        body: {
          'day_number': dayNumber,
          'activity_time': time,
          'title': title,
          'duration': duration,
          'cost': cost,
          'icon': icon,
          'placeId': placeId,
        },
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ApiFailure(response.message ?? 'Failed to add activity'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeActivity(String activityId) async {
    try {
      final response = await _dataSource.removeActivity(activityId);

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ApiFailure(response.message ?? 'Failed to remove activity'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItineraryModel>> reoptimizeItinerary(
      String itineraryId) async {
    try {
      final response = await _dataSource.reoptimizeItinerary(itineraryId);

      if (response.success && response.data != null) {
        return Right(
            ItineraryModel.fromJson(response.data as Map<String, dynamic>));
      } else {
        return Left(
            ApiFailure(response.message ?? 'Failed to reoptimize itinerary'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
