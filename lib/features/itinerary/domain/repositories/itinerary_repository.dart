import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../../data/model/itinerary_model.dart';

abstract class IItineraryRepository {
  Future<Either<Failure, ItineraryModel>> generateItinerary({
    required String tripId,
    required String city,
    required int days,
  });

  Future<Either<Failure, ItineraryModel>> getItinerary(String id);
}
