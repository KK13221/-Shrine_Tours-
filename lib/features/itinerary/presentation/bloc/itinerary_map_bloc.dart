import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_itinerary_usecase.dart';
import '../../domain/usecases/add_activity_usecase.dart';
import '../../domain/usecases/remove_activity_usecase.dart';
import '../../domain/usecases/reoptimize_itinerary_usecase.dart';
import '../../data/model/itinerary_model.dart';

// Events
abstract class ItineraryMapEvent extends Equatable {
  const ItineraryMapEvent();
  @override
  List<Object?> get props => [];
}

class FetchMapItineraryRequested extends ItineraryMapEvent {
  final String id;
  const FetchMapItineraryRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeMapItineraryDay extends ItineraryMapEvent {
  final int day;
  const ChangeMapItineraryDay(this.day);
  @override
  List<Object?> get props => [day];
}

class AddMapActivityRequested extends ItineraryMapEvent {
  final String itineraryId;
  final int dayNumber;
  final String time;
  final String title;
  final String duration;
  final double cost;
  final String icon;
  final String placeId;

  const AddMapActivityRequested({
    required this.itineraryId,
    required this.dayNumber,
    required this.time,
    required this.title,
    required this.duration,
    required this.cost,
    required this.icon,
    required this.placeId,
  });

  @override
  List<Object?> get props =>
      [itineraryId, dayNumber, time, title, duration, cost, icon, placeId];
}

class RemoveMapActivityRequested extends ItineraryMapEvent {
  final String activityId;
  final String itineraryId; // Needed to refresh the itinerary

  const RemoveMapActivityRequested({
    required this.activityId,
    required this.itineraryId,
  });

  @override
  List<Object?> get props => [activityId, itineraryId];
}

class ReoptimizeMapItineraryRequested extends ItineraryMapEvent {
  final String itineraryId;
  const ReoptimizeMapItineraryRequested(this.itineraryId);
  @override
  List<Object?> get props => [itineraryId];
}

// States
abstract class ItineraryMapState extends Equatable {
  const ItineraryMapState();
  @override
  List<Object?> get props => [];
}

class ItineraryMapInitial extends ItineraryMapState {}

class ItineraryMapLoading extends ItineraryMapState {}

class ItineraryMapSuccess extends ItineraryMapState {
  final ItineraryModel itinerary;
  final int selectedDay;
  final bool isReoptimizing;

  const ItineraryMapSuccess({
    required this.itinerary,
    this.selectedDay = 1,
    this.isReoptimizing = false,
  });

  ItineraryMapSuccess copyWith({
    ItineraryModel? itinerary,
    int? selectedDay,
    bool? isReoptimizing,
  }) {
    return ItineraryMapSuccess(
      itinerary: itinerary ?? this.itinerary,
      selectedDay: selectedDay ?? this.selectedDay,
      isReoptimizing: isReoptimizing ?? this.isReoptimizing,
    );
  }

  @override
  List<Object?> get props => [itinerary, selectedDay, isReoptimizing];
}

class ItineraryMapFailure extends ItineraryMapState {
  final String message;
  const ItineraryMapFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ItineraryMapBloc extends Bloc<ItineraryMapEvent, ItineraryMapState> {
  final GetItineraryUseCase _getItineraryUseCase;
  final AddActivityUseCase _addActivityUseCase;
  final RemoveActivityUseCase _removeActivityUseCase;
  final ReoptimizeItineraryUseCase _reoptimizeItineraryUseCase;

  String _lastRequestedId = '';
  int _selectedDayBeforeFetch = 1;

  /// The last itinerary ID that was requested — used for retry.
  String get lastRequestedId => _lastRequestedId;

  ItineraryMapBloc(
    this._getItineraryUseCase,
    this._addActivityUseCase,
    this._removeActivityUseCase,
    this._reoptimizeItineraryUseCase,
  ) : super(ItineraryMapInitial()) {
    on<FetchMapItineraryRequested>(_onFetch);
    on<ChangeMapItineraryDay>(_onChangeDay);
    on<AddMapActivityRequested>(_onAddActivity);
    on<RemoveMapActivityRequested>(_onRemoveActivity);
    on<ReoptimizeMapItineraryRequested>(_onReoptimize);
  }

  void _onChangeDay(
    ChangeMapItineraryDay event,
    Emitter<ItineraryMapState> emit,
  ) {
    final current = state;
    if (current is ItineraryMapSuccess) {
      emit(current.copyWith(selectedDay: event.day));
    }
  }

  Future<void> _onFetch(
    FetchMapItineraryRequested event,
    Emitter<ItineraryMapState> emit,
  ) async {
    _lastRequestedId = event.id;
    emit(ItineraryMapLoading());
    final result = await _getItineraryUseCase(event.id);
    result.fold(
      (failure) => emit(ItineraryMapFailure(failure.message)),
      (itinerary) {
        // Sort days by dayNumber ascending
        final sortedDays = List<ItineraryDayModel>.from(itinerary.days)
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
        final sorted = ItineraryModel(
          id: itinerary.id,
          tripId: itinerary.tripId,
          city: itinerary.city,
          title: itinerary.title,
          days: sortedDays,
        );
        // Persist the selected day if we were already on one
        emit(ItineraryMapSuccess(
            itinerary: sorted, selectedDay: _selectedDayBeforeFetch));
      },
    );
  }

  Future<void> _onAddActivity(
    AddMapActivityRequested event,
    Emitter<ItineraryMapState> emit,
  ) async {
    final current = state;
    if (current is ItineraryMapSuccess) {
      _selectedDayBeforeFetch = current.selectedDay;
    }

    emit(ItineraryMapLoading());
    final result = await _addActivityUseCase(AddActivityParams(
      itineraryId: event.itineraryId,
      dayNumber: event.dayNumber,
      time: event.time,
      title: event.title,
      duration: event.duration,
      cost: event.cost,
      icon: event.icon,
      placeId: event.placeId,
    ));

    result.fold(
      (failure) => emit(ItineraryMapFailure(failure.message)),
      (_) => add(FetchMapItineraryRequested(event.itineraryId)),
    );
  }

  Future<void> _onRemoveActivity(
    RemoveMapActivityRequested event,
    Emitter<ItineraryMapState> emit,
  ) async {
    final current = state;
    if (current is ItineraryMapSuccess) {
      _selectedDayBeforeFetch = current.selectedDay;
    }

    emit(ItineraryMapLoading());
    final result = await _removeActivityUseCase(event.activityId);

    result.fold(
      (failure) => emit(ItineraryMapFailure(failure.message)),
      (_) => add(FetchMapItineraryRequested(event.itineraryId)),
    );
  }

  Future<void> _onReoptimize(
    ReoptimizeMapItineraryRequested event,
    Emitter<ItineraryMapState> emit,
  ) async {
    final current = state;
    if (current is! ItineraryMapSuccess) return;

    // Show spinner on the button without blanking the whole screen
    emit(current.copyWith(isReoptimizing: true));

    final result = await _reoptimizeItineraryUseCase(event.itineraryId);

    result.fold(
      (failure) {
        // Restore previous state with error cleared
        emit(current.copyWith(isReoptimizing: false));
      },
      (itinerary) {
        // Sort days ascending and replace itinerary in state
        final sortedDays = List<ItineraryDayModel>.from(itinerary.days)
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
        final sorted = ItineraryModel(
          id: itinerary.id,
          tripId: itinerary.tripId,
          city: itinerary.city,
          title: itinerary.title,
          days: sortedDays,
        );
        emit(current.copyWith(
          itinerary: sorted,
          isReoptimizing: false,
        ));
      },
    );
  }
}
