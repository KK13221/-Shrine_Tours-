import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../../data/model/place.dart';

abstract class IPlacesRepository {
  Future<Either<Failure, List<Place>>> getPlaces(String city);
  Future<Either<Failure, List<Place>>> getSuggestedPlaces(String city);
}
