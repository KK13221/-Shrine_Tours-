import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/create_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/update_trip_usecase.dart';

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
      createdTrip: createdTrip ?? this.createdTrip,
      creationErrorMessage: creationErrorMessage ?? this.creationErrorMessage,
      editingTripId: editingTripId ?? this.editingTripId,
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
      ];
}

// BLoC
class TripPlanningBloc extends Bloc<TripPlanningEvent, TripPlanningState> {
  final CreateTripUseCase _createTripUseCase;
  final UpdateTripUseCase _updateTripUseCase;

  TripPlanningBloc(this._createTripUseCase, this._updateTripUseCase)
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
      );

      final result = await _updateTripUseCase(params);

      result.fold(
        (failure) => emit(state.copyWith(
          isGenerating: false,
          creationErrorMessage: failure.message,
        )),
        (trip) => emit(state.copyWith(
          isGenerating: false,
          createdTrip: trip,
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
      );

      final result = await _createTripUseCase(params);

      result.fold(
        (failure) => emit(state.copyWith(
          isGenerating: false,
          creationErrorMessage: failure.message,
        )),
        (trip) => emit(state.copyWith(
          isGenerating: false,
          createdTrip: trip,
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
    // Backend returns strings like "Budget Friendly", but check if it's different
    return style;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }
}
