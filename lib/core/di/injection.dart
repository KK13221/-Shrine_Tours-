import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/itinerary/presentation/bloc/itinerary_bloc.dart';
import '../../features/packing/presentation/bloc/packing_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/trip_planning/presentation/bloc/trip_planning_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // BLoCs
  getIt.registerFactory(() => AuthBloc());
  getIt.registerFactory(() => TripPlanningBloc());
  getIt.registerFactory(() => ItineraryBloc());
  getIt.registerFactory(() => PackingBloc());
  getIt.registerFactory(() => ProfileBloc());
}
