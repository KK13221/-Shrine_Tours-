import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_itinerary_usecase.dart';
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

  const GetItinerarySuccess({required this.itinerary, this.selectedDay = 1});

  GetItinerarySuccess copyWith({int? selectedDay}) {
    return GetItinerarySuccess(
      itinerary: itinerary,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  List<Object?> get props => [itinerary, selectedDay];
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
  String _lastRequestedId = '';

  /// The last itinerary ID that was requested — used for retry.
  String get lastRequestedId => _lastRequestedId;

  GetItineraryBloc(this._getItineraryUseCase) : super(GetItineraryInitial()) {
    on<FetchItineraryRequested>(_onFetch);
    on<ChangeItineraryDay>(_onChangeDay);
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
        emit(GetItinerarySuccess(itinerary: sorted, selectedDay: 1));
      },
    );
  }
}
