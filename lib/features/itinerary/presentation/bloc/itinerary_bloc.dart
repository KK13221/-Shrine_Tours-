import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/delete_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_trips_usecase.dart';

// Models - moved to data/model/trips.dart
// Keeping Activity model here as it's still used for itinerary details
class Activity {
  final String time;
  final String title;
  final String duration;
  final double cost;
  final String icon;

  const Activity({
    required this.time,
    required this.title,
    required this.duration,
    required this.cost,
    this.icon = 'explore',
  });
}

// Events
abstract class ItineraryEvent extends Equatable {
  const ItineraryEvent();
  @override
  List<Object?> get props => [];
}

class LoadItineraries extends ItineraryEvent {}

class SelectItinerary extends ItineraryEvent {
  final String id;
  const SelectItinerary(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeDay extends ItineraryEvent {
  final int day;
  const ChangeDay(this.day);
  @override
  List<Object?> get props => [day];
}

class AddItinerary extends ItineraryEvent {
  final Trips itinerary;
  const AddItinerary(this.itinerary);
  @override
  List<Object?> get props => [itinerary];
}

class DeleteItinerary extends ItineraryEvent {
  final String id;
  final Completer<bool> completer;

  const DeleteItinerary(this.id, this.completer);

  @override
  List<Object?> get props => [id];
}

// States
class ItineraryState extends Equatable {
  final List<Trips> trips;
  final Trips? selectedTrip;
  final int selectedDay;
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  const ItineraryState({
    this.trips = const [],
    this.selectedTrip,
    this.selectedDay = 1,
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  ItineraryState copyWith({
    List<Trips>? trips,
    Trips? selectedTrip,
    int? selectedDay,
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ItineraryState(
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      selectedDay: selectedDay ?? this.selectedDay,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [trips, selectedTrip, selectedDay, activities, isLoading, error];
}

// BLoC
class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final GetTripsUseCase _getTripsUseCase;
  final DeleteTripUseCase _deleteTripUseCase;

  ItineraryBloc(this._getTripsUseCase, this._deleteTripUseCase)
      : super(const ItineraryState()) {
    on<LoadItineraries>(_onLoad);
    on<SelectItinerary>(_onSelect);
    on<ChangeDay>(_onChangeDay);
    on<AddItinerary>(_onAdd);
    on<DeleteItinerary>(_onDelete);
  }

  Future<void> _onDelete(
      DeleteItinerary event, Emitter<ItineraryState> emit) async {
    emit(state.copyWith(error: null));

    final result = await _deleteTripUseCase.call(event.id);

    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message));
        event.completer.complete(false);
      },
      (_) {
        final updatedTrips =
            List<Trips>.from(state.trips.where((trip) => trip.id != event.id));
        emit(state.copyWith(
          trips: updatedTrips,
          selectedTrip:
              state.selectedTrip?.id == event.id ? null : state.selectedTrip,
          error: null,
        ));
        event.completer.complete(true);
      },
    );
  }

  Future<void> _onLoad(
      LoadItineraries event, Emitter<ItineraryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getTripsUseCase.call();

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
      (trips) {
        emit(state.copyWith(
          isLoading: false,
          trips: trips,
          error: null,
        ));
      },
    );
  }

  void _onSelect(SelectItinerary event, Emitter<ItineraryState> emit) {
    final trip = state.trips.firstWhere((t) => t.id == event.id);
    emit(state.copyWith(
      selectedTrip: trip,
      selectedDay: 1,
      activities: const [
        Activity(
            time: '10:00',
            title: 'Start from Hotel',
            duration: '30 min',
            cost: 2500,
            icon: 'car'),
        Activity(
            time: '10:30',
            title: 'Enjoy the wild at Van Vihar',
            duration: '3 hr',
            cost: 50,
            icon: 'explore'),
        Activity(
            time: '13:30',
            title: 'Lunch at Lake View',
            duration: '1 hr',
            cost: 800,
            icon: 'restaurant'),
        Activity(
            time: '15:00',
            title: 'Visit Sanchi Stupa',
            duration: '2 hr',
            cost: 100,
            icon: 'temple'),
        Activity(
            time: '17:30',
            title: 'Evening at Upper Lake',
            duration: '1.5 hr',
            cost: 0,
            icon: 'water'),
      ],
    ));
  }

  void _onChangeDay(ChangeDay event, Emitter<ItineraryState> emit) {
    emit(state.copyWith(selectedDay: event.day));
  }

  void _onAdd(AddItinerary event, Emitter<ItineraryState> emit) {
    emit(state.copyWith(
      trips: [...state.trips, event.itinerary],
    ));
  }
}
