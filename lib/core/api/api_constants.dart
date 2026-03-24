/// REST path segments for the Shrine Tours backend (v1).
///
/// **Backend handoff:** See `docs/API_SPECIFICATION.md` for endpoints + expected responses.
class ApiConstants {
  ApiConstants._();

  // Base URL — change this to your production API
  static const String baseUrl = 'https://api.shrinetours.com/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleSignIn = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Trip endpoints
  static const String trips = '/trips';
  static const String tripById = '/trips/'; // + {id}
  static const String generateItinerary = '/trips/generate';

  // Itinerary endpoints
  static const String itineraries = '/itineraries';
  static const String itineraryById = '/itineraries/'; // + {id}
  static const String itineraryActivities = '/itineraries/activities'; // + /{id}

  // Places endpoints
  static const String places = '/places';
  static const String searchPlaces = '/places/search';
  static const String suggestedPlaces = '/places/suggested';

  // Packing endpoints
  static const String packingLists = '/packing';
  static const String packingCategories = '/packing/categories';

  // Profile endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String paymentMethods = '/profile/payments';
  static const String subscription = '/profile/subscription';

  // Weather
  static const String weather = '/weather'; // ?city={city}&date={date}

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
