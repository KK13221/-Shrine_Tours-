import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../../data/model/place.dart';

abstract class IPlacesRepository {
  Future<Either<Failure, List<Place>>> getPlaces(String city);
  Future<Either<Failure, List<Place>>> getSuggestedPlaces(String city);
  Future<Either<Failure, void>> addPlaceToTrip(String tripId, String placeId);
  Future<Either<Failure, void>> removeFromTrip(String tripId, String placeId);
  Future<Either<Failure, List<Place>>> searchPlaces(String query);
  Future<Either<Failure, List<Place>>> searchPlacesFromGoogle(
      String query);
  Future<Either<Failure, Place>> getPlaceDetails(String placeId);
}
