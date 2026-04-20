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
  final Set<String> alreadyAddedPlaceIds;
  final List<Place> searchResults;
  final bool isSearching;
  final String? searchError;
  final String? message;

  const AddPlacesLoaded({
    required this.city,
    required this.tripId,
    required this.places,
    required this.suggestedPlaces,
    required this.selectedPlaceIds,
    this.alreadyAddedPlaceIds = const {},
    this.searchResults = const [],
    this.isSearching = false,
    this.searchError,
    this.message,
  });

  AddPlacesLoaded copyWith({
    String? city,
    String? tripId,
    List<Place>? places,
    List<Place>? suggestedPlaces,
    Set<String>? selectedPlaceIds,
    Set<String>? alreadyAddedPlaceIds,
    List<Place>? searchResults,
    bool? isSearching,
    String? searchError,
    String? message,
  }) {
    return AddPlacesLoaded(
      city: city ?? this.city,
      tripId: tripId ?? this.tripId,
      places: places ?? this.places,
      suggestedPlaces: suggestedPlaces ?? this.suggestedPlaces,
      selectedPlaceIds: selectedPlaceIds ?? this.selectedPlaceIds,
      alreadyAddedPlaceIds: alreadyAddedPlaceIds ?? this.alreadyAddedPlaceIds,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        city,
        tripId,
        places,
        suggestedPlaces,
        selectedPlaceIds,
        alreadyAddedPlaceIds,
        searchResults,
        isSearching,
        searchError,
        message
      ];
}

class AddPlacesFailure extends AddPlacesState {
  final String message;
  const AddPlacesFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
