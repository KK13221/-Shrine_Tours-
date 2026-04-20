import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_response.dart';

abstract class ItineraryDataSource {
  Future<ApiResponse<dynamic>> generateItinerary({
    required String tripId,
    required String city,
    required int days,
  });

  Future<ApiResponse<dynamic>> getItinerary(String id);
  Future<ApiResponse<dynamic>> modifyItinerary({
    required String tripId,
    required String city,
    required int days,
    required String itineraryId,
  });

  Future<ApiResponse<dynamic>> reoptimizeItinerary(String itineraryId);

  Future<ApiResponse<dynamic>> addActivity({
    required String itineraryId,
    required Map<String, dynamic> body,
  });
  Future<ApiResponse<dynamic>> removeActivity(String activityId);
}

class ItineraryDataSourceImpl implements ItineraryDataSource {
  final ApiClient _apiClient;

  ItineraryDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<dynamic>> generateItinerary({
    required String tripId,
    required String city,
    required int days,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.generateItineraryApi,
      body: {
        'trip_id': tripId,
        'city': city,
        'days': days,
      },
    );

    // Convert to ApiResponse
    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception("Unknown response format");
    }
  }

  @override
  Future<ApiResponse<dynamic>> getItinerary(String id) async {
    final response = await _apiClient.get(
      '${ApiConstants.itineraryById}$id',
    );

    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception('Unknown response format');
    }
  }

  @override
  Future<ApiResponse<dynamic>> modifyItinerary({
    required String tripId,
    required String city,
    required int days,
    required String itineraryId,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.modifyItinerary}$itineraryId',
      body: {
        "itineraryId": itineraryId,
        "tripId": tripId,
        "city": city,
        "days": days,
      },
    );

    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception('Unknown response format');
    }
  }

  @override
  Future<ApiResponse<dynamic>> reoptimizeItinerary(String itineraryId) async {
    final response = await _apiClient.post(
      '${ApiConstants.modifyItinerary}$itineraryId/reoptimize',
      body: {'strategy': 'distance'},
    );

    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception('Unknown response format');
    }
  }

  @override
  Future<ApiResponse<dynamic>> addActivity({
    required String itineraryId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.addActivity}$itineraryId/add-activity',
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception('Unknown response format');
    }
  }

  @override
  Future<ApiResponse<dynamic>> removeActivity(String activityId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.removeActivity}$activityId',
    );

    if (response is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        response,
        (data) => data,
      );
    } else {
      throw Exception('Unknown response format');
    }
  }
}
