import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import '../repositories/places_repository.dart';

class GetPlacesUseCase {
  final IPlacesRepository _repository;

  GetPlacesUseCase(this._repository);

  Future<Either<Failure, List<Place>>> call(String city) async {
    return await _repository.getPlaces(city);
  }
}
