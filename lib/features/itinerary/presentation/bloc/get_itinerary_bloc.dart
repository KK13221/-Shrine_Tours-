import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_itinerary_usecase.dart';
import '../../domain/usecases/add_activity_usecase.dart';
import '../../domain/usecases/remove_activity_usecase.dart';
import '../../domain/usecases/reoptimize_itinerary_usecase.dart';
import '../../data/model/itinerary_model.dart';

// Events
abstract class GetItineraryEvent extends Equatable {
  const GetItineraryEvent();
  @override
  List<Object?> get props => [];
}

class FetchItineraryRequested extends GetItineraryEvent {
  final String id;
  const FetchItineraryRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeItineraryDay extends GetItineraryEvent {
  final int day;
  const ChangeItineraryDay(this.day);
  @override
  List<Object?> get props => [day];
}

class AddActivityRequested extends GetItineraryEvent {
  final String itineraryId;
  final int dayNumber;
  final String time;
  final String title;
  final String duration;
  final double cost;
  final String icon;
  final String placeId;

  const AddActivityRequested({
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

class RemoveActivityRequested extends GetItineraryEvent {
  final String activityId;
  final String itineraryId; // Needed to refresh the itinerary

  const RemoveActivityRequested({
    required this.activityId,
    required this.itineraryId,
  });

  @override
  List<Object?> get props => [activityId, itineraryId];
}

class ReoptimizeItineraryRequested extends GetItineraryEvent {
  final String itineraryId;
  const ReoptimizeItineraryRequested(this.itineraryId);
  @override
  List<Object?> get props => [itineraryId];
}

// States
abstract class GetItineraryState extends Equatable {
  const GetItineraryState();
  @override
  List<Object?> get props => [];
}

class GetItineraryInitial extends GetItineraryState {}

class GetItineraryLoading extends GetItineraryState {}

class GetItinerarySuccess extends GetItineraryState {
  final ItineraryModel itinerary;
  final int selectedDay;
  final bool isReoptimizing;

  const GetItinerarySuccess({
    required this.itinerary,
    this.selectedDay = 1,
    this.isReoptimizing = false,
  });

  GetItinerarySuccess copyWith({
    ItineraryModel? itinerary,
    int? selectedDay,
    bool? isReoptimizing,
  }) {
    return GetItinerarySuccess(
      itinerary: itinerary ?? this.itinerary,
      selectedDay: selectedDay ?? this.selectedDay,
      isReoptimizing: isReoptimizing ?? this.isReoptimizing,
    );
  }

  @override
  List<Object?> get props => [itinerary, selectedDay, isReoptimizing];
}

class GetItineraryFailure extends GetItineraryState {
  final String message;
  const GetItineraryFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class GetItineraryBloc extends Bloc<GetItineraryEvent, GetItineraryState> {
  final GetItineraryUseCase _getItineraryUseCase;
  final AddActivityUseCase _addActivityUseCase;
  final RemoveActivityUseCase _removeActivityUseCase;
  final ReoptimizeItineraryUseCase _reoptimizeItineraryUseCase;

  String _lastRequestedId = '';
  int _selectedDayBeforeFetch = 1;

  /// The last itinerary ID that was requested — used for retry.
  String get lastRequestedId => _lastRequestedId;

  GetItineraryBloc(
    this._getItineraryUseCase,
    this._addActivityUseCase,
    this._removeActivityUseCase,
    this._reoptimizeItineraryUseCase,
  ) : super(GetItineraryInitial()) {
    on<FetchItineraryRequested>(_onFetch);
    on<ChangeItineraryDay>(_onChangeDay);
    on<AddActivityRequested>(_onAddActivity);
    on<RemoveActivityRequested>(_onRemoveActivity);
    on<ReoptimizeItineraryRequested>(_onReoptimize);
  }

  void _onChangeDay(
    ChangeItineraryDay event,
    Emitter<GetItineraryState> emit,
  ) {
    final current = state;
    if (current is GetItinerarySuccess) {
      emit(current.copyWith(selectedDay: event.day));
    }
  }

  Future<void> _onFetch(
    FetchItineraryRequested event,
    Emitter<GetItineraryState> emit,
  ) async {
    _lastRequestedId = event.id;
    emit(GetItineraryLoading());
    final result = await _getItineraryUseCase(event.id);
    result.fold(
      (failure) => emit(GetItineraryFailure(failure.message)),
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
        emit(GetItinerarySuccess(
            itinerary: sorted, selectedDay: _selectedDayBeforeFetch));
      },
    );
  }

  Future<void> _onAddActivity(
    AddActivityRequested event,
    Emitter<GetItineraryState> emit,
  ) async {
    final current = state;
    if (current is GetItinerarySuccess) {
      _selectedDayBeforeFetch = current.selectedDay;
    }

    emit(GetItineraryLoading());
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
      (failure) => emit(GetItineraryFailure(failure.message)),
      (_) => add(FetchItineraryRequested(event.itineraryId)),
    );
  }

  Future<void> _onRemoveActivity(
    RemoveActivityRequested event,
    Emitter<GetItineraryState> emit,
  ) async {
    final current = state;
    if (current is GetItinerarySuccess) {
      _selectedDayBeforeFetch = current.selectedDay;
    }

    emit(GetItineraryLoading());
    final result = await _removeActivityUseCase(event.activityId);

    result.fold(
      (failure) => emit(GetItineraryFailure(failure.message)),
      (_) => add(FetchItineraryRequested(event.itineraryId)),
    );
  }

  Future<void> _onReoptimize(
    ReoptimizeItineraryRequested event,
    Emitter<GetItineraryState> emit,
  ) async {
    final current = state;
    if (current is! GetItinerarySuccess) return;

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
