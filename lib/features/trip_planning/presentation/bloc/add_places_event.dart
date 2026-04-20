part of 'add_places_bloc.dart';

abstract class AddPlacesEvent extends Equatable {
  const AddPlacesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaces extends AddPlacesEvent {
  final String city;
  final String tripId;
  final List<String>? initialSelectedPlaceIds;

  const LoadPlaces({
    required this.city,
    required this.tripId,
    this.initialSelectedPlaceIds,
  });

  @override
  List<Object?> get props => [city, tripId, initialSelectedPlaceIds];
}

class TogglePlaceSelection extends AddPlacesEvent {
  final String placeId;
  const TogglePlaceSelection({required this.placeId});

  @override
  List<Object?> get props => [placeId];
}

class SearchPlacesRequested extends AddPlacesEvent {
  final String query;
  const SearchPlacesRequested({required this.query});

  @override
  List<Object?> get props => [query];
}
