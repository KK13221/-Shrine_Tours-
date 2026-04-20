import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/itinerary_repository.dart';

class AddActivityUseCase {
  final IItineraryRepository _repository;

  AddActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(AddActivityParams params) async {
    return await _repository.addActivity(
      itineraryId: params.itineraryId,
      dayNumber: params.dayNumber,
      time: params.time,
      title: params.title,
      duration: params.duration,
      cost: params.cost,
      icon: params.icon,
      placeId: params.placeId,
    );
  }
}

class AddActivityParams {
  final String itineraryId;
  final int dayNumber;
  final String time;
  final String title;
  final String duration;
  final double cost;
  final String icon;
  final String placeId;

  const AddActivityParams({
    required this.itineraryId,
    required this.dayNumber,
    required this.time,
    required this.title,
    required this.duration,
    required this.cost,
    required this.icon,
    required this.placeId,
  });
}
