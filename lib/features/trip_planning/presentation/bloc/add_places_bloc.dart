import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/add_place_to_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_places_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_suggested_places_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/remove_place_from_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/search_places_usecase.dart';
import 'package:rxdart/rxdart.dart';

part 'add_places_event.dart';
part 'add_places_state.dart';

class AddPlacesBloc extends Bloc<AddPlacesEvent, AddPlacesState> {
  final GetPlacesUseCase _getPlacesUseCase;
  final GetSuggestedPlacesUseCase _getSuggestedPlacesUseCase;
  final AddPlaceToTripUseCase _addPlaceToTripUseCase;
  final RemovePlaceFromTripUseCase _removePlaceFromTripUseCase;
  final SearchPlacesUseCase _searchPlacesUseCase;

  AddPlacesBloc(
    this._getPlacesUseCase,
    this._getSuggestedPlacesUseCase,
    this._addPlaceToTripUseCase,
    this._removePlaceFromTripUseCase,
    this._searchPlacesUseCase,
  ) : super(const AddPlacesInitial()) {
    on<LoadPlaces>(_onLoadPlaces);
    on<TogglePlaceSelection>(_onTogglePlaceSelection);
    on<SearchPlacesRequested>(
      _onSearchPlacesRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onLoadPlaces(
    LoadPlaces event,
    Emitter<AddPlacesState> emit,
  ) async {
    emit(const AddPlacesLoading());

    final Either<Failure, List<Place>> placesResult =
        await _getPlacesUseCase.call(event.city);
    final Either<Failure, List<Place>> suggestedResult =
        await _getSuggestedPlacesUseCase.call(event.city);

    if (placesResult.isLeft()) {
      final failure =
          placesResult.fold((l) => l, (_) => throw StateError('unreachable'));
      emit(AddPlacesFailure(message: failure.message));
      return;
    }

    if (suggestedResult.isLeft()) {
      final failure = suggestedResult.fold(
          (l) => l, (_) => throw StateError('unreachable'));
      emit(AddPlacesFailure(message: failure.message));
      return;
    }

    final places = placesResult.getOrElse(() => []);
    final suggestedPlaces = suggestedResult.getOrElse(() => []);

    final initialSelectedIds = event.initialSelectedPlaceIds?.toSet() ?? {};

    emit(AddPlacesLoaded(
      city: event.city,
      tripId: event.tripId,
      places: places,
      suggestedPlaces: suggestedPlaces,
      selectedPlaceIds: initialSelectedIds,
      alreadyAddedPlaceIds: Set.from(initialSelectedIds),
    ));
  }

  void _onTogglePlaceSelection(
    TogglePlaceSelection event,
    Emitter<AddPlacesState> emit,
  ) async {
    if (state is! AddPlacesLoaded) return;

    final current = state as AddPlacesLoaded;
    final selected = Set<String>.from(current.selectedPlaceIds);
    final isCurrentlySelected = selected.contains(event.placeId);

    if (isCurrentlySelected) {
      // Remove from trip via API
      final result = await _removePlaceFromTripUseCase.call(
        RemovePlaceFromTripParams(
          tripId: current.tripId,
          placeId: event.placeId,
        ),
      );

      result.fold(
        (failure) {
          emit(current.copyWith(
              message: 'Failed to remove place: ${failure.message}'));
        },
        (_) {
          selected.remove(event.placeId);
          emit(current.copyWith(
            selectedPlaceIds: selected,
            message: 'Place removed from trip successfully',
          ));
        },
      );
    } else {
      // Add to trip via API
      final result = await _addPlaceToTripUseCase.call(
        AddPlaceToTripParams(
          tripId: current.tripId,
          placeId: event.placeId,
        ),
      );

      result.fold(
        (failure) {
          emit(current.copyWith(
              message: 'Failed to add place: ${failure.message}'));
        },
        (_) {
          selected.add(event.placeId);
          
          // If the place was added from search results, add it to the main places list
          // so it appears when search is cleared (as requested by user)
          final updatedPlaces = List<Place>.from(current.places);
          if (!updatedPlaces.any((p) => p.id == event.placeId)) {
            final addedPlace = current.searchResults.firstWhere((p) => p.id == event.placeId, orElse: () => current.suggestedPlaces.firstWhere((p) => p.id == event.placeId));
            updatedPlaces.add(addedPlace);
          }

          emit(current.copyWith(
            selectedPlaceIds: selected,
            places: updatedPlaces,
            message: 'Place added to trip successfully',
          ));
        },
      );
    }
  }

  Future<void> _onSearchPlacesRequested(
    SearchPlacesRequested event,
    Emitter<AddPlacesState> emit,
  ) async {
    if (state is! AddPlacesLoaded) return;
    final current = state as AddPlacesLoaded;

    if (event.query.isEmpty) {
      emit(current.copyWith(
        searchResults: [],
        isSearching: false,
        searchError: null,
      ));
      return;
    }

    emit(current.copyWith(isSearching: true, searchError: null));

    final result = await _searchPlacesUseCase.call(event.query);

    result.fold(
      (failure) {
        emit(current.copyWith(
          isSearching: false,
          searchError: 'No such location found: ${failure.message}',
        ));
      },
      (places) {
        emit(current.copyWith(
          isSearching: false,
          searchResults: places,
          searchError: places.isEmpty ? 'No such location found' : null,
        ));
      },
    );
  }
}
