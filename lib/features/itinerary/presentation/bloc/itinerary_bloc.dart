import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
class Itinerary {
  final String id;
  final String city;
  final String imageUrl;
  final String dateRange;
  final int places;
  final int days;
  final int adults;
  final int kids;

  const Itinerary({
    required this.id,
    required this.city,
    required this.imageUrl,
    required this.dateRange,
    required this.places,
    required this.days,
    this.adults = 2,
    this.kids = 1,
  });
}

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
  final Itinerary itinerary;
  const AddItinerary(this.itinerary);
  @override
  List<Object?> get props => [itinerary];
}

// States
class ItineraryState extends Equatable {
  final List<Itinerary> itineraries;
  final Itinerary? selectedItinerary;
  final int selectedDay;
  final List<Activity> activities;
  final bool isLoading;

  const ItineraryState({
    this.itineraries = const [],
    this.selectedItinerary,
    this.selectedDay = 1,
    this.activities = const [],
    this.isLoading = false,
  });

  ItineraryState copyWith({
    List<Itinerary>? itineraries,
    Itinerary? selectedItinerary,
    int? selectedDay,
    List<Activity>? activities,
    bool? isLoading,
  }) {
    return ItineraryState(
      itineraries: itineraries ?? this.itineraries,
      selectedItinerary: selectedItinerary ?? this.selectedItinerary,
      selectedDay: selectedDay ?? this.selectedDay,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [itineraries, selectedItinerary, selectedDay, activities, isLoading];
}

// BLoC
class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  ItineraryBloc() : super(const ItineraryState()) {
    on<LoadItineraries>(_onLoad);
    on<SelectItinerary>(_onSelect);
    on<ChangeDay>(_onChangeDay);
    on<AddItinerary>(_onAdd);
  }

  Future<void> _onLoad(LoadItineraries event, Emitter<ItineraryState> emit) async {
    if (state.itineraries.isNotEmpty) return;
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(
      isLoading: false,
      itineraries: const [
        Itinerary(
          id: '1',
          city: 'Bhopal',
          imageUrl: 'https://images.unsplash.com/photo-1585135497273-1a86d1e5d4a4?w=400',
          dateRange: '23 Oct 25 - 26 Oct 25',
          places: 5,
          days: 3,
        ),
        Itinerary(
          id: '2',
          city: 'Jaipur',
          imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400',
          dateRange: '10 Nov 25 - 13 Nov 25',
          places: 8,
          days: 3,
        ),
        Itinerary(
          id: '3',
          city: 'Goa',
          imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
          dateRange: '5 Dec 25 - 9 Dec 25',
          places: 6,
          days: 4,
        ),
      ],
    ));
  }

  void _onSelect(SelectItinerary event, Emitter<ItineraryState> emit) {
    final itinerary = state.itineraries.firstWhere((i) => i.id == event.id);
    emit(state.copyWith(
      selectedItinerary: itinerary,
      selectedDay: 1,
      activities: const [
        Activity(time: '10:00', title: 'Start from Hotel', duration: '30 min', cost: 2500, icon: 'car'),
        Activity(time: '10:30', title: 'Enjoy the wild at Van Vihar', duration: '3 hr', cost: 50, icon: 'explore'),
        Activity(time: '13:30', title: 'Lunch at Lake View', duration: '1 hr', cost: 800, icon: 'restaurant'),
        Activity(time: '15:00', title: 'Visit Sanchi Stupa', duration: '2 hr', cost: 100, icon: 'temple'),
        Activity(time: '17:30', title: 'Evening at Upper Lake', duration: '1.5 hr', cost: 0, icon: 'water'),
      ],
    ));
  }

  void _onChangeDay(ChangeDay event, Emitter<ItineraryState> emit) {
    emit(state.copyWith(selectedDay: event.day));
  }

  void _onAdd(AddItinerary event, Emitter<ItineraryState> emit) {
    emit(state.copyWith(
      itineraries: [...state.itineraries, event.itinerary],
    ));
  }
}
