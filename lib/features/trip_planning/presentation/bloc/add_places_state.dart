part of 'add_places_bloc.dart';

abstract class AddPlacesState extends Equatable {
  const AddPlacesState();

  @override
  List<Object?> get props => [];
}

class AddPlacesInitial extends AddPlacesState {
  const AddPlacesInitial();
}

class AddPlacesLoading extends AddPlacesState {
  const AddPlacesLoading();
}

class AddPlacesLoaded extends AddPlacesState {
  final String city;
  final String tripId;
  final List<Place> places;
  final List<Place> suggestedPlaces;
  final Set<String> selectedPlaceIds;
  final String? message;

  const AddPlacesLoaded({
    required this.city,
    required this.tripId,
    required this.places,
    required this.suggestedPlaces,
    required this.selectedPlaceIds,
    this.message,
  });

  AddPlacesLoaded copyWith({
    String? city,
    String? tripId,
    List<Place>? places,
    List<Place>? suggestedPlaces,
    Set<String>? selectedPlaceIds,
    String? message,
  }) {
    return AddPlacesLoaded(
      city: city ?? this.city,
      tripId: tripId ?? this.tripId,
      places: places ?? this.places,
      suggestedPlaces: suggestedPlaces ?? this.suggestedPlaces,
      selectedPlaceIds: selectedPlaceIds ?? this.selectedPlaceIds,
      message: message,
    );
  }

  @override
  List<Object?> get props => [city, tripId, places, suggestedPlaces, selectedPlaceIds, message];
}

class AddPlacesFailure extends AddPlacesState {
  final String message;
  const AddPlacesFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
