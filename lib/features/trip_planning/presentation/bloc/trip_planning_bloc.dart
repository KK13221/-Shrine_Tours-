import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trip_detail_response.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/create_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_trip_by_id_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/update_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/search_places_from_google_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_place_details_usecase.dart';
import '../../data/model/place.dart';

// Events
abstract class TripPlanningEvent extends Equatable {
  const TripPlanningEvent();
  @override
  List<Object?> get props => [];
}

class UpdateDestination extends TripPlanningEvent {
  final String city;
  const UpdateDestination(this.city);
  @override
  List<Object?> get props => [city];
}

class UpdateTravellerType extends TripPlanningEvent {
  final String type;
  const UpdateTravellerType(this.type);
  @override
  List<Object?> get props => [type];
}

class UpdatePurpose extends TripPlanningEvent {
  final String purpose;
  const UpdatePurpose(this.purpose);
  @override
  List<Object?> get props => [purpose];
}

class UpdateDates extends TripPlanningEvent {
  final DateTime startDate;
  final DateTime endDate;
  const UpdateDates({required this.startDate, required this.endDate});
  @override
  List<Object?> get props => [startDate, endDate];
}

class UpdateAdults extends TripPlanningEvent {
  final int count;
  const UpdateAdults(this.count);
  @override
  List<Object?> get props => [count];
}

class UpdateKids extends TripPlanningEvent {
  final int count;
  const UpdateKids(this.count);
  @override
  List<Object?> get props => [count];
}

class UpdateTripStyle extends TripPlanningEvent {
  final String style;
  const UpdateTripStyle(this.style);
  @override
  List<Object?> get props => [style];
}

class TogglePlaceSelection extends TripPlanningEvent {
  final String placeId;
  const TogglePlaceSelection(this.placeId);
  @override
  List<Object?> get props => [placeId];
}

class GenerateItinerary extends TripPlanningEvent {}

class InitializeModification extends TripPlanningEvent {
  final Trips trip;
  const InitializeModification(this.trip);
  @override
  List<Object?> get props => [trip];
}

class ClearTripModification extends TripPlanningEvent {}

class FetchTripById extends TripPlanningEvent {
  final String tripId;
  const FetchTripById(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

class SearchStartingPoint extends TripPlanningEvent {
  final String query;
  const SearchStartingPoint(this.query);
  @override
  List<Object?> get props => [query];
}

class SelectStartingPoint extends TripPlanningEvent {
  final String placeId;
  const SelectStartingPoint(this.placeId);
  @override
  List<Object?> get props => [placeId];
}

class ClearStartingPointSearch extends TripPlanningEvent {}

// States
class TripPlanningState extends Equatable {
  final String destination;
  final String travellerType;
  final String purpose;
  final DateTime? startDate;
  final DateTime? endDate;
  final int adults;
  final int kids;
  final String tripStyle;
  final List<String> selectedPlaces;
  final bool isGenerating;
  final Trips? createdTrip;
  final String? creationErrorMessage;
  final String? editingTripId;
  final TripDetailResponse? selectedTripDetails;
  final bool isLoadingDetails;
  final List<Place> startingPointPredictions;
  final Place? selectedStartingPoint;
  final bool isSearchingStartingPoint;

  const TripPlanningState({
    this.destination = '',
    this.travellerType = '',
    this.purpose = '',
    this.startDate,
    this.endDate,
    this.adults = 2,
    this.kids = 0,
    this.tripStyle = 'Budget Friendly',
    this.selectedPlaces = const [],
    this.isGenerating = false,
    this.createdTrip,
    this.creationErrorMessage,
    this.editingTripId,
    this.selectedTripDetails,
    this.isLoadingDetails = false,
    this.startingPointPredictions = const [],
    this.selectedStartingPoint,
    this.isSearchingStartingPoint = false,
  });

  TripPlanningState copyWith({
    String? destination,
    String? travellerType,
    String? purpose,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? kids,
    String? tripStyle,
    List<String>? selectedPlaces,
    bool? isGenerating,
    Trips? createdTrip,
    String? creationErrorMessage,
    String? editingTripId,
    TripDetailResponse? selectedTripDetails,
    bool? isLoadingDetails,
    List<Place>? startingPointPredictions,
    Place? selectedStartingPoint,
    bool clearSelectedStartingPoint = false,
    bool clearCreatedTrip = false,
    bool? isSearchingStartingPoint,
  }) {
    return TripPlanningState(
      destination: destination ?? this.destination,
      travellerType: travellerType ?? this.travellerType,
      purpose: purpose ?? this.purpose,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      tripStyle: tripStyle ?? this.tripStyle,
      selectedPlaces: selectedPlaces ?? this.selectedPlaces,
      isGenerating: isGenerating ?? this.isGenerating,
      createdTrip: clearCreatedTrip ? null : createdTrip ?? this.createdTrip,
      creationErrorMessage: creationErrorMessage ?? this.creationErrorMessage,
      editingTripId: editingTripId ?? this.editingTripId,
      selectedTripDetails: selectedTripDetails ?? this.selectedTripDetails,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      startingPointPredictions:
          startingPointPredictions ?? this.startingPointPredictions,
      selectedStartingPoint: clearSelectedStartingPoint
          ? null
          : selectedStartingPoint ?? this.selectedStartingPoint,
      isSearchingStartingPoint:
          isSearchingStartingPoint ?? this.isSearchingStartingPoint,
    );
  }

  @override
  List<Object?> get props => [
        destination,
        travellerType,
        purpose,
        startDate,
        endDate,
        adults,
        kids,
        tripStyle,
        selectedPlaces,
        isGenerating,
        createdTrip,
        creationErrorMessage,
        editingTripId,
        selectedTripDetails,
        isLoadingDetails,
        startingPointPredictions,
        selectedStartingPoint,
        isSearchingStartingPoint,
      ];
}

// BLoC
class TripPlanningBloc extends Bloc<TripPlanningEvent, TripPlanningState> {
  final CreateTripUseCase _createTripUseCase;
  final UpdateTripUseCase _updateTripUseCase;
  final GetTripByIdUseCase _getTripByIdUseCase;
  final SearchPlacesFromGoogleUseCase _searchPlacesFromGoogleUseCase;
  final GetPlaceDetailsUseCase _getPlaceDetailsUseCase;

  TripPlanningBloc(
      this._createTripUseCase,
      this._updateTripUseCase,
      this._getTripByIdUseCase,
      this._searchPlacesFromGoogleUseCase,
      this._getPlaceDetailsUseCase)
      : super(const TripPlanningState()) {
    on<UpdateDestination>(
        (event, emit) => emit(state.copyWith(destination: event.city)));
    on<UpdateTravellerType>(
        (event, emit) => emit(state.copyWith(travellerType: event.type)));
    on<UpdatePurpose>(
        (event, emit) => emit(state.copyWith(purpose: event.purpose)));
    on<UpdateDates>((event, emit) => emit(
        state.copyWith(startDate: event.startDate, endDate: event.endDate)));
    on<UpdateAdults>(
        (event, emit) => emit(state.copyWith(adults: event.count)));
    on<UpdateKids>((event, emit) => emit(state.copyWith(kids: event.count)));
    on<UpdateTripStyle>(
        (event, emit) => emit(state.copyWith(tripStyle: event.style)));
    on<InitializeModification>(_onInitializeModification);
    on<ClearTripModification>(_onClearTripModification);
    on<TogglePlaceSelection>(_onTogglePlace);
    on<GenerateItinerary>(_onGenerate);
    on<FetchTripById>(_onFetchTripById);
    on<SearchStartingPoint>(_onSearchStartingPoint);
    on<SelectStartingPoint>(_onSelectStartingPoint);
    on<ClearStartingPointSearch>(_onClearStartingPointSearch);
  }

  void _onInitializeModification(
      InitializeModification event, Emitter<TripPlanningState> emit) {
    final trip = event.trip;

    // Parse traveller type from adults/kids or other data if possible
    // For now we'll defaults or use some logic if we had it
    String travellerType = 'family';
    if (trip.adults == 1 && trip.kids == 0) travellerType = 'solo';
    if (trip.adults == 2 && trip.kids == 0) travellerType = 'couple';

    emit(TripPlanningState(
      destination: trip.city,
      travellerType: travellerType,
      purpose: trip.purposeOfTravel,
      startDate: DateTime.parse(trip.startDate),
      endDate: DateTime.parse(trip.endDate),
      adults: trip.adults,
      kids: trip.kids,
      tripStyle: _reverseMapTripStyle(trip.tripStyle),
      editingTripId: trip.id,
    ));
  }

  void _onClearTripModification(
      ClearTripModification event, Emitter<TripPlanningState> emit) {
    emit(const TripPlanningState());
  }

  void _onTogglePlace(
      TogglePlaceSelection event, Emitter<TripPlanningState> emit) {
    final places = List<String>.from(state.selectedPlaces);
    if (places.contains(event.placeId)) {
      places.remove(event.placeId);
    } else {
      places.add(event.placeId);
    }
    emit(state.copyWith(selectedPlaces: places));
  }

  Future<void> _onGenerate(
      GenerateItinerary event, Emitter<TripPlanningState> emit) async {
    if (state.destination.isEmpty ||
        state.startDate == null ||
        state.endDate == null) {
      emit(state.copyWith(
        isGenerating: false,
        creationErrorMessage:
            'Please complete your trip details before generating.',
      ));
      return;
    }

    emit(state.copyWith(
        isGenerating: true, creationErrorMessage: null, createdTrip: null));

    emit(state.copyWith(
        isGenerating: true, creationErrorMessage: null, createdTrip: null));

    if (state.editingTripId != null) {
      final params = UpdateTripParams(
        id: state.editingTripId!,
        city: state.destination,
        startDate: _formatDate(state.startDate!),
        endDate: _formatDate(state.endDate!),
        adults: state.adults,
        kids: state.kids,
        tripStyle: _mapTripStyleToValue(state.tripStyle),
        purposeOfTravel: state.purpose,
        startingPoint: state.selectedStartingPoint,
      );

      print("update trip params");
      print(params);

      final result = await _updateTripUseCase(params);

      result.fold(
        (failure) => emit(state.copyWith(
          isGenerating: false,
          creationErrorMessage: failure.message,
        )),
        (trip) => emit(state.copyWith(
          isGenerating: false,
          createdTrip: trip,
          destination: trip.city, // Sync with backend-normalized city
          creationErrorMessage: null,
          editingTripId: null, // Clear after success
        )),
      );
    } else {
      final params = CreateTripParams(
        city: state.destination,
        startDate: _formatDate(state.startDate!),
        endDate: _formatDate(state.endDate!),
        adults: state.adults,
        kids: state.kids,
        tripStyle: _mapTripStyleToValue(state.tripStyle),
        purposeOfTravel: state.purpose,
        startingPoint: state.selectedStartingPoint,
      );

      print("create trip params");
      print(params);

      final result = await _createTripUseCase(params);

      result.fold(
        (failure) => emit(state.copyWith(
          isGenerating: false,
          creationErrorMessage: failure.message,
        )),
        (trip) => emit(state.copyWith(
          isGenerating: false,
          createdTrip: trip,
          destination: trip.city, // Sync with backend-normalized city
          creationErrorMessage: null,
        )),
      );
    }
  }

  int _mapTripStyleToValue(String style) {
    switch (style) {
      case 'Fast Travel':
        return 2;
      case 'Relaxed Vacation':
        return 3;
      case 'Explore Everything':
        return 4;
      case 'Food Lover':
        return 5;
      default:
        return 1;
    }
  }

  String _reverseMapTripStyle(String style) {
    switch (style) {
      case '2':
      case 'Fast Travel':
        return 'Fast Travel';
      case '3':
      case 'Relaxed Vacation':
        return 'Relaxed Vacation';
      case '4':
      case 'Explore Everything':
        return 'Explore Everything';
      case '5':
      case 'Food Lover':
        return 'Food Lover';
      case '1':
      case 'Budget Friendly':
      default:
        return 'Budget Friendly';
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }

  Future<void> _onFetchTripById(
      FetchTripById event, Emitter<TripPlanningState> emit) async {
    emit(state.copyWith(
      isLoadingDetails: true,
      creationErrorMessage: null,
      clearCreatedTrip: true, // Clear stale createdTrip when switching to a specific trip
    ));

    final result = await _getTripByIdUseCase(event.tripId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingDetails: false,
        creationErrorMessage: failure.message,
      )),
      (tripDetails) {
        // Parse traveller type from adults/kids
        String travellerType = 'family';
        if (tripDetails.adults == 1 && tripDetails.kids == 0)
          travellerType = 'solo';
        if (tripDetails.adults == 2 && tripDetails.kids == 0)
          travellerType = 'couple';

        // Debug: print the starting_point coming from get-trip-by-id API
        debugPrint('=== FetchTripById Response ===');
        debugPrint('Trip ID     : ${tripDetails.id}');
        debugPrint('City        : ${tripDetails.city}');
        debugPrint('Starting Pt : ${tripDetails.startingPoint?.name ?? "NULL"}');
        debugPrint('SP ID       : ${tripDetails.startingPoint?.id ?? "NULL"}');
        debugPrint('==============================');

        // Build Place from starting_point if present
        Place? sp;
        if (tripDetails.startingPoint != null) {
          sp = Place(
            id: tripDetails.startingPoint!.id,
            name: tripDetails.startingPoint!.name,
            category: tripDetails.startingPoint!.category,
            imageUrl: tripDetails.startingPoint!.imageUrl,
            typicalDuration: tripDetails.startingPoint!.typicalDuration,
            rating: tripDetails.startingPoint!.rating,
            reviewsCount: tripDetails.startingPoint!.reviewsCount,
            verified: tripDetails.startingPoint!.verified,
            latitude: tripDetails.startingPoint!.latitude,
            longitude: tripDetails.startingPoint!.longitude,
          );
        }

        emit(state.copyWith(
          isLoadingDetails: false,
          selectedTripDetails: tripDetails,
          destination: tripDetails.city,
          travellerType: travellerType,
          purpose: tripDetails.purposeOfTravel,
          startDate: DateTime.tryParse(tripDetails.startDate),
          endDate: DateTime.tryParse(tripDetails.endDate),
          adults: tripDetails.adults,
          kids: tripDetails.kids,
          tripStyle: _reverseMapTripStyle(tripDetails.tripStyle),
          editingTripId: tripDetails.id,
          // CRITICAL: always explicitly clear previoustrip's selectedStartingPoint.
          // If this trip has a starting_point, set it; otherwise force-clear
          // using clearSelectedStartingPoint so the old value isn't preserved.
          clearSelectedStartingPoint: sp == null,
          selectedStartingPoint: sp,
        ));
      },
    );
  }

  Future<void> _onSearchStartingPoint(
      SearchStartingPoint event, Emitter<TripPlanningState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(startingPointPredictions: []));
      return;
    }

    emit(state.copyWith(isSearchingStartingPoint: true));

    final result = await _searchPlacesFromGoogleUseCase(event.query);

    result.fold(
      (failure) => emit(state.copyWith(
          isSearchingStartingPoint: false,
          creationErrorMessage: failure.message)),
      (predictions) => emit(state.copyWith(
          isSearchingStartingPoint: false,
          startingPointPredictions: predictions)),
    );
  }

  Future<void> _onSelectStartingPoint(
      SelectStartingPoint event, Emitter<TripPlanningState> emit) async {
    if (event.placeId.isEmpty) {
      emit(state.copyWith(
        clearSelectedStartingPoint: true,
        startingPointPredictions: [],
        isSearchingStartingPoint: false,
      ));
      return;
    }

    emit(state.copyWith(isSearchingStartingPoint: true));

    final result = await _getPlaceDetailsUseCase(event.placeId);

    result.fold(
      (failure) => emit(state.copyWith(
          isSearchingStartingPoint: false,
          creationErrorMessage: failure.message)),
      (place) => emit(state.copyWith(
        isSearchingStartingPoint: false,
        selectedStartingPoint: place,
        startingPointPredictions: [], // Clear after selection
      )),
    );
  }

  void _onClearStartingPointSearch(
      ClearStartingPointSearch event, Emitter<TripPlanningState> emit) {
    emit(state.copyWith(startingPointPredictions: []));
  }
}
