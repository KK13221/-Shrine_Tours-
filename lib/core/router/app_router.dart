import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/trip_planning/presentation/screens/plan_trip_screen.dart';
import '../../features/trip_planning/presentation/screens/trip_preferences_screen.dart';
import '../../features/trip_planning/presentation/screens/add_places_screen.dart';
import '../../features/itinerary/presentation/screens/my_itineraries_screen.dart';
import '../../features/itinerary/presentation/screens/trip_details_screen.dart';
import '../../features/itinerary/presentation/screens/itinerary_view_screen.dart';
import '../../features/packing/presentation/screens/packing_list_screen.dart';
import '../../features/packing/presentation/screens/checking_packing_screen.dart';
import '../../features/profile/presentation/screens/profile_menu_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/upgrade_plan_screen.dart';
import '../../features/profile/presentation/screens/user_levels_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/terms_screen.dart';

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
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
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
        path: '/add-places',
        name: 'addPlaces',
        builder: (context, state) => const AddPlacesScreen(),
      ),
      GoRoute(
        path: '/trip-details',
        name: 'tripDetails',
        builder: (context, state) => const TripDetailsScreen(),
      ),
      GoRoute(
        path: '/itinerary-view',
        name: 'itineraryView',
        builder: (context, state) => const ItineraryViewScreen(),
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
        builder: (context, state) => const UpgradePlanScreen(),
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
