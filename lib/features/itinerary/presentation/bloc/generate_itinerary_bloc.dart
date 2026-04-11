import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_itinerary_usecase.dart';
import '../../data/model/itinerary_model.dart';

// Events
abstract class GenerateItineraryEvent extends Equatable {
  const GenerateItineraryEvent();
  @override
  List<Object?> get props => [];
}

class GenerateItineraryRequested extends GenerateItineraryEvent {
  final String tripId;
  final String city;
  final int days;

  const GenerateItineraryRequested({
    required this.tripId,
    required this.city,
    required this.days,
  });

  @override
  List<Object?> get props => [tripId, city, days];
}

// States
abstract class GenerateItineraryState extends Equatable {
  const GenerateItineraryState();
  @override
  List<Object?> get props => [];
}

class GenerateItineraryInitial extends GenerateItineraryState {}

class GenerateItineraryLoading extends GenerateItineraryState {}

class GenerateItinerarySuccess extends GenerateItineraryState {
  final ItineraryModel itinerary;
  final String message;

  const GenerateItinerarySuccess(this.itinerary, this.message);

  @override
  List<Object?> get props => [itinerary, message];
}

class GenerateItineraryFailure extends GenerateItineraryState {
  final String message;

  const GenerateItineraryFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GenerateItineraryBloc extends Bloc<GenerateItineraryEvent, GenerateItineraryState> {
  final GenerateItineraryUseCase _generateItineraryUseCase;

  GenerateItineraryBloc(this._generateItineraryUseCase) : super(GenerateItineraryInitial()) {
    on<GenerateItineraryRequested>(_onGenerateItineraryRequested);
  }

  Future<void> _onGenerateItineraryRequested(
    GenerateItineraryRequested event,
    Emitter<GenerateItineraryState> emit,
  ) async {
    emit(GenerateItineraryLoading());

    final result = await _generateItineraryUseCase(
      GenerateItineraryParams(
        tripId: event.tripId,
        city: event.city,
        days: event.days,
      ),
    );

    result.fold(
      (failure) => emit(GenerateItineraryFailure(failure.message)),
      (itinerary) => emit(GenerateItinerarySuccess(itinerary, 'Itinerary generated successfully')),
    );
  }
}
