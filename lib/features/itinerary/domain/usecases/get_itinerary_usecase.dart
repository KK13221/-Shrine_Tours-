import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';
import '../../data/model/itinerary_model.dart';

class GetItineraryUseCase {
  final IItineraryRepository repository;

  GetItineraryUseCase(this.repository);

  Future<Either<Failure, ItineraryModel>> call(String id) {
    return repository.getItinerary(id);
  }
}
