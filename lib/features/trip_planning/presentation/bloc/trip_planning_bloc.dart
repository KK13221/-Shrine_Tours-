import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    );
  }

  @override
  List<Object?> get props => [
        destination, travellerType, purpose, startDate,
        endDate, adults, kids, tripStyle, selectedPlaces, isGenerating,
      ];
}

// BLoC
class TripPlanningBloc extends Bloc<TripPlanningEvent, TripPlanningState> {
  TripPlanningBloc() : super(const TripPlanningState()) {
    on<UpdateDestination>((event, emit) => emit(state.copyWith(destination: event.city)));
    on<UpdateTravellerType>((event, emit) => emit(state.copyWith(travellerType: event.type)));
    on<UpdatePurpose>((event, emit) => emit(state.copyWith(purpose: event.purpose)));
    on<UpdateDates>((event, emit) => emit(state.copyWith(startDate: event.startDate, endDate: event.endDate)));
    on<UpdateAdults>((event, emit) => emit(state.copyWith(adults: event.count)));
    on<UpdateKids>((event, emit) => emit(state.copyWith(kids: event.count)));
    on<UpdateTripStyle>((event, emit) => emit(state.copyWith(tripStyle: event.style)));
    on<TogglePlaceSelection>(_onTogglePlace);
    on<GenerateItinerary>(_onGenerate);
  }

  void _onTogglePlace(TogglePlaceSelection event, Emitter<TripPlanningState> emit) {
    final places = List<String>.from(state.selectedPlaces);
    if (places.contains(event.placeId)) {
      places.remove(event.placeId);
    } else {
      places.add(event.placeId);
    }
    emit(state.copyWith(selectedPlaces: places));
  }

  Future<void> _onGenerate(GenerateItinerary event, Emitter<TripPlanningState> emit) async {
    emit(state.copyWith(isGenerating: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isGenerating: false));
  }
}
