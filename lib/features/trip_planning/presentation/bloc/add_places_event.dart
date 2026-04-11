part of 'add_places_bloc.dart';

abstract class AddPlacesEvent extends Equatable {
  const AddPlacesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaces extends AddPlacesEvent {
  final String city;
  final String tripId;
  const LoadPlaces({required this.city, required this.tripId});

  @override
  List<Object?> get props => [city, tripId];
}

class TogglePlaceSelection extends AddPlacesEvent {
  final String placeId;
  const TogglePlaceSelection({required this.placeId});

  @override
  List<Object?> get props => [placeId];
}
