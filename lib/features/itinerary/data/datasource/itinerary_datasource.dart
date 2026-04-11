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
}
