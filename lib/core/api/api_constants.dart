/// REST path segments for the Shrine Tours backend (v1).
///
/// **Backend handoff:** See `docs/API_SPECIFICATION.md` for endpoints + expected responses.
class ApiConstants {
  ApiConstants._();

  // Base URL — change this to your production API
  //static const String baseUrl = 'https://api.shrinetours.com/v1';
  static const String baseUrl = 'http://32.193.3.150:8080/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleSignIn = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Trip endpoints
  static const String trips = '/trips';
  static const String tripById = '/trips/'; // + {id}
  static const String generateItinerary = '/trips/generate';

  // Places endpoints
  static const String addPlaceToTrip = '/places/trip/add';
  static const String removePlaceFromTrip = '/places/trip/remove';

  // Itinerary endpoints
  static const String itineraries = '/itineraries';
  static const String generateItineraryApi = '/itineraries/generate';
  static const String itineraryById = '/itineraries/'; // + {id}
  static const String modifyItinerary = '/itineraries/'; // + {id}
  static const String itineraryActivities =
      '/itineraries/activities'; // + /{id}
  static const String addActivity = '/itineraries/'; // + {id}/add-activity
  static const String removeActivity =
      '/itineraries/remove-activity/'; // + {activityId}

  // Places endpoints
  static const String places = '/places';
  static const String searchPlaces = '/places/search';
  static const String suggestedPlaces = '/places/suggested';

  // Packing endpoints
  static const String packingLists = '/packing';
  static const String updateTransports = '/packing/'; // + {tripId}/transports
  static const String packingCategories = '/packing/categories';
  static const String addPackingCategory =
      '/packing/'; // + {tripId}/Addcategories
  static const String addPackingItem = '/packing/'; // + {tripId}/add-item

  // Profile endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String uploadAvatar = '/profile/upload-avatar';
  static const String paymentMethods = '/profile/payments';
  static const String addPaymentMethod = '/profile/Addpayments';
  static const String subscription = '/profile/subscription';

  // Weather
  static const String weather = '/weather'; // ?city={city}&date={date}

  // Payments
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String getOrders = '/payments/orders';
  static const String getInvoice = '/payments/orders/'; // + {id}/invoice

  // Razorpay Keys (User will fill these)
  static const String razorpayKeyId = 'rzp_test_SXQRoyl0PBkiDH';
  static const String razorpayKeySecret = 'TXRf4e8Xyyes7Cj7m65hSIyA';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String googleApiKey = 'AIzaSyAjEqTpg277Jx1q9-_HbrwWSt_qb--u3eY';
}
