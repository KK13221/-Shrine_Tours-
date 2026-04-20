import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_itinerary_usecase.dart';
import '../../domain/usecases/modify_itinerary_usecase.dart';
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
  final String? itineraryId;

  const GenerateItineraryRequested({
    required this.tripId,
    required this.city,
    required this.days,
    this.itineraryId,
  });

  @override
  List<Object?> get props => [tripId, city, days, itineraryId];
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
  final ModifyItineraryUseCase _modifyItineraryUseCase;

  GenerateItineraryBloc(
    this._generateItineraryUseCase,
    this._modifyItineraryUseCase,
  ) : super(GenerateItineraryInitial()) {
    on<GenerateItineraryRequested>(_onGenerateItineraryRequested);
  }

  Future<void> _onGenerateItineraryRequested(
    GenerateItineraryRequested event,
    Emitter<GenerateItineraryState> emit,
  ) async {
    emit(GenerateItineraryLoading());

    if (event.itineraryId != null && event.itineraryId!.isNotEmpty) {
      // Modify Flow
      final result = await _modifyItineraryUseCase(
        ModifyItineraryParams(
          tripId: event.tripId,
          city: event.city,
          days: event.days,
          itineraryId: event.itineraryId!,
        ),
      );

      result.fold(
        (failure) => emit(GenerateItineraryFailure(failure.message)),
        (itinerary) => emit(GenerateItinerarySuccess(
            itinerary, 'Itinerary updated successfully')),
      );
    } else {
      // Creation Flow
      final result = await _generateItineraryUseCase(
        GenerateItineraryParams(
          tripId: event.tripId,
          city: event.city,
          days: event.days,
        ),
      );

      result.fold(
        (failure) => emit(GenerateItineraryFailure(failure.message)),
        (itinerary) => emit(GenerateItinerarySuccess(
            itinerary, 'Itinerary generated successfully')),
      );
    }
  }
}
