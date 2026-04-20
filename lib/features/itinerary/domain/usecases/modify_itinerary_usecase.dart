import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';
import '../../data/model/itinerary_model.dart';

class ModifyItineraryUseCase {
  final IItineraryRepository _repository;

  ModifyItineraryUseCase(this._repository);

  Future<Either<Failure, ItineraryModel>> call(ModifyItineraryParams params) async {
    return await _repository.modifyItinerary(
      tripId: params.tripId,
      city: params.city,
      days: params.days,
      itineraryId: params.itineraryId,
    );
  }
}

class ModifyItineraryParams {
  final String tripId;
  final String city;
  final int days;
  final String itineraryId;

  const ModifyItineraryParams({
    required this.tripId,
    required this.city,
    required this.days,
    required this.itineraryId,
  });
}
