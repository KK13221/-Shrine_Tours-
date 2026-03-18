import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/itinerary/presentation/bloc/itinerary_bloc.dart';
import 'features/packing/presentation/bloc/packing_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/trip_planning/presentation/bloc/trip_planning_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const ShrineTours());
}

class ShrineTours extends StatelessWidget {
  const ShrineTours({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<TripPlanningBloc>()),
        BlocProvider(create: (_) => getIt<ItineraryBloc>()),
        BlocProvider(create: (_) => getIt<PackingBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
      ],
      child: MaterialApp.router(
        title: 'ShrineTours',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
