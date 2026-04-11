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
        return Right(ItineraryModel.fromJson(response.data as Map<String, dynamic>));
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
        return Right(ItineraryModel.fromJson(response.data as Map<String, dynamic>));
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error occurred'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
