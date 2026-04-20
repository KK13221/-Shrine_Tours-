import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';
import '../../data/model/itinerary_model.dart';

class ReoptimizeItineraryUseCase {
  final IItineraryRepository repository;

  ReoptimizeItineraryUseCase(this.repository);

  Future<Either<Failure, ItineraryModel>> call(String itineraryId) {
    return repository.reoptimizeItinerary(itineraryId);
  }
}
