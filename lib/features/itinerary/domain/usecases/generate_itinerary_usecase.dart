import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';
import '../../data/model/itinerary_model.dart';

class GenerateItineraryParams {
  final String tripId;
  final String city;
  final int days;

  const GenerateItineraryParams({
    required this.tripId,
    required this.city,
    required this.days,
  });
}

class GenerateItineraryUseCase {
  final IItineraryRepository repository;

  GenerateItineraryUseCase(this.repository);

  Future<Either<Failure, ItineraryModel>> call(GenerateItineraryParams params) {
    return repository.generateItinerary(
      tripId: params.tripId,
      city: params.city,
      days: params.days,
    );
  }
}
