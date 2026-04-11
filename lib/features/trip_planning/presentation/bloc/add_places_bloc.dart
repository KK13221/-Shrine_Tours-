import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/add_place_to_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/data/model/place.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_places_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_suggested_places_usecase.dart';

part 'add_places_event.dart';
part 'add_places_state.dart';

class AddPlacesBloc extends Bloc<AddPlacesEvent, AddPlacesState> {
  final GetPlacesUseCase _getPlacesUseCase;
  final GetSuggestedPlacesUseCase _getSuggestedPlacesUseCase;
  final AddPlaceToTripUseCase _addPlaceToTripUseCase;

  AddPlacesBloc(
    this._getPlacesUseCase,
    this._getSuggestedPlacesUseCase,
    this._addPlaceToTripUseCase,
  ) : super(const AddPlacesInitial()) {
    on<LoadPlaces>(_onLoadPlaces);
    on<TogglePlaceSelection>(_onTogglePlaceSelection);
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

    emit(AddPlacesLoaded(
      city: event.city,
      tripId: event.tripId,
      places: places,
      suggestedPlaces: suggestedPlaces,
      selectedPlaceIds: const {},
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
      // Remove locally (API integration later)
      selected.remove(event.placeId);
      emit(current.copyWith(
        selectedPlaceIds: selected,
        message: 'Place removed from trip',
      ));
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
          // On failure, don't add and set error message
          emit(current.copyWith(
              message: 'Failed to add place: ${failure.message}'));
        },
        (_) {
          // Success, add to selected
          selected.add(event.placeId);
          emit(current.copyWith(
            selectedPlaceIds: selected,
            message: 'Place added to trip successfully',
          ));
        },
      );
    }
  }
}
