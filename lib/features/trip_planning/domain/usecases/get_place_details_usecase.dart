import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../../data/model/place.dart';
import '../repositories/places_repository.dart';

class GetPlaceDetailsUseCase {
  final IPlacesRepository _repository;

  GetPlaceDetailsUseCase(this._repository);

  Future<Either<Failure, Place>> call(String placeId) async {
    return await _repository.getPlaceDetails(placeId);
  }
}
