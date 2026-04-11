import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/auth/presentation/screens/splash_screen.dart';
import 'package:shrine_tours/features/auth/presentation/bloc/forget_password_bloc.dart';
import 'package:shrine_tours/core/di/injection.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/trip_planning/presentation/screens/plan_trip_screen.dart';
import '../../features/trip_planning/presentation/screens/trip_preferences_screen.dart';
import '../../features/trip_planning/presentation/screens/add_places_screen.dart';
import '../../features/trip_planning/presentation/bloc/add_places_bloc.dart';
import '../../features/trip_planning/presentation/screens/place_details_screen.dart';
import '../../features/trip_planning/presentation/screens/my_itineraries_screen.dart';
import '../../features/trip_planning/presentation/screens/trip_details_screen.dart';
import '../../features/itinerary/presentation/screens/itinerary_view_screen.dart';
import '../../features/itinerary/presentation/bloc/generate_itinerary_bloc.dart';
import '../../features/itinerary/presentation/bloc/get_itinerary_bloc.dart';
import '../../features/trip_planning/presentation/screens/trip_summary_screen.dart';
import '../../features/packing/presentation/screens/packing_list_screen.dart';
import '../../features/packing/presentation/screens/checking_packing_screen.dart';
import '../../features/profile/presentation/screens/profile_menu_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/upgrade_plan_screen.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/profile/presentation/screens/user_levels_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/trip_planning/data/model/trips.dart';
import '../../features/profile/presentation/screens/terms_screen.dart';

class OtpRouteExtra {
  final String email;
  final ForgetPasswordBloc bloc;
  const OtpRouteExtra({required this.email, required this.bloc});
}

class ResetRouteExtra {
  final String email;
  final ForgetPasswordBloc bloc;
  const ResetRouteExtra({required this.email, required this.bloc});
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),

      // ── Forgot password flow ─────────────────────────────────────────────
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) {
          // Fresh bloc every time user enters the forgot password flow.
          final bloc = getIt<ForgetPasswordBloc>();
          return BlocProvider<ForgetPasswordBloc>(
            create: (_) => bloc,
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) {
          final extra = state.extra as OtpRouteExtra;
          return BlocProvider<ForgetPasswordBloc>.value(
            // Reuse the same bloc instance from /forgot-password.
            value: extra.bloc,
            child: OtpVerificationScreen(email: extra.email),
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) {
          final extra = state.extra as ResetRouteExtra;
          return BlocProvider<ForgetPasswordBloc>.value(
            // Reuse the same bloc instance from /otp-verification.
            value: extra.bloc,
            child: ResetPasswordScreen(email: extra.email),
          );
        },
      ),
      // ── End forgot password flow ────────────────────────────────

      GoRoute(
        path: '/privacy-policy',
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/itineraries',
        name: 'itineraries',
        builder: (context, state) => const MyItinerariesScreen(),
      ),
      GoRoute(
        path: '/plan-trip',
        name: 'planTrip',
        builder: (context, state) => const PlanTripScreen(),
      ),
      GoRoute(
        path: '/trip-preferences',
        name: 'tripPreferences',
        builder: (context, state) => const TripPreferencesScreen(),
      ),
      GoRoute(
        path: '/trip-summary',
        name: 'tripSummary',
        builder: (context, state) => const TripSummaryScreen(),
      ),
      GoRoute(
        path: '/add-places',
        name: 'addPlaces',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AddPlacesBloc>(create: (_) => getIt<AddPlacesBloc>()),
            BlocProvider<GenerateItineraryBloc>(create: (_) => getIt<GenerateItineraryBloc>()),
          ],
          child: const AddPlacesScreen(),
        ),
      ),
      GoRoute(
        path: '/place-details',
        name: 'placeDetails',
        builder: (context, state) => const PlaceDetailsScreen(),
      ),
      GoRoute(
        path: '/trip-details',
        name: 'tripDetails',
        builder: (context, state) {
          final trip = state.extra as Trips?;
          return TripDetailsScreen(trip: trip);
        },
      ),
      GoRoute(
        path: '/itinerary-view',
        name: 'itineraryView',
        builder: (context, state) {
          final itineraryId = state.extra as String? ?? '';
          return BlocProvider<GetItineraryBloc>(
            create: (_) => getIt<GetItineraryBloc>()
              ..add(FetchItineraryRequested(itineraryId)),
            child: const ItineraryViewScreen(),
          );
        },
      ),
      GoRoute(
        path: '/packing-list',
        name: 'packingList',
        builder: (context, state) => const PackingListScreen(),
      ),
      GoRoute(
        path: '/checking-packing',
        name: 'checkingPacking',
        builder: (context, state) => const CheckingPackingScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileMenuScreen(),
      ),
      GoRoute(
        path: '/profile-settings',
        name: 'profileSettings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        name: 'paymentMethods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/upgrade-plan',
        name: 'upgradePlan',
        builder: (context, state) => BlocProvider<PaymentBloc>(
          create: (_) => getIt<PaymentBloc>(),
          child: const UpgradePlanScreen(),
        ),
      ),
      GoRoute(
        path: '/user-levels',
        name: 'userLevels',
        builder: (context, state) => const UserLevelsScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
    ],
  );
}
