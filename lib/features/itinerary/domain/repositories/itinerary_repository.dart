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
  Future<Either<Failure, ItineraryModel>> modifyItinerary({
    required String tripId,
    required String city,
    required int days,
    required String itineraryId,
  });

  Future<Either<Failure, void>> addActivity({
    required String itineraryId,
    required int dayNumber,
    required String time,
    required String title,
    required String duration,
    required double cost,
    required String icon,
    required String placeId,
  });

  Future<Either<Failure, void>> removeActivity(String activityId);

  Future<Either<Failure, ItineraryModel>> reoptimizeItinerary(String itineraryId);
}
