import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import '../repositories/places_repository.dart';

class SearchPlacesUseCase {
  final IPlacesRepository _repository;

  SearchPlacesUseCase(this._repository);

  Future<Either<Failure, List<Place>>> call(String query) async {
    return await _repository.searchPlaces(query);
  }
}
