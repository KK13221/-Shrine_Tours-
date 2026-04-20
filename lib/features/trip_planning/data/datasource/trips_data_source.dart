import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trip_detail_response.dart';

abstract class TripsDataSource {
  /// Fetch trips from API
  Future<List<Trips>> getTrips();

  /// Create a new trip
  Future<Trips> createTrip({required Map<String, dynamic> body});

  /// Add a place to a trip
  Future<void> addPlaceToTrip({required Map<String, dynamic> body});

  /// Update an existing trip
  Future<Trips> updateTrip(String tripId, {required Map<String, dynamic> body});

  /// Delete a trip by id
  Future<void> deleteTrip(String tripId);

  /// Get trip by id
  Future<TripDetailResponse> getTripById(String tripId);
}

class TripsDataSourceImpl implements TripsDataSource {
  final ApiClient _apiClient;

  TripsDataSourceImpl(this._apiClient);

  @override
  Future<List<Trips>> getTrips() async {
    final response = await _apiClient.get(ApiConstants.trips);

    if (response != null && response['success'] == true) {
      final data = response['data'] as List<dynamic>;
      return data
          .map((json) => Trips.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch trips');
    }
  }

  @override
  Future<Trips> createTrip({required Map<String, dynamic> body}) async {
    final response = await _apiClient.post(ApiConstants.trips, body: body);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return Trips.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to create trip');
    }
  }

  @override
  Future<void> addPlaceToTrip({required Map<String, dynamic> body}) async {
    final response =
        await _apiClient.post(ApiConstants.addPlaceToTrip, body: body);

    if (response != null && response['success'] == true) {
      // Success, no data to return
    } else {
      throw Exception(response?['message'] ?? 'Failed to add place to trip');
    }
  }

  @override
  Future<Trips> updateTrip(String tripId, {required Map<String, dynamic> body}) async {
    final response = await _apiClient.put(ApiConstants.tripById + tripId, body: body);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return Trips.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to update trip');
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    final response = await _apiClient.delete(ApiConstants.tripById + tripId);

    if (response != null && response['success'] == true) {
      return;
    } else {
      throw Exception(response?['message'] ?? 'Failed to delete trip');
    }
  }

  @override
  Future<TripDetailResponse> getTripById(String tripId) async {
    final response = await _apiClient.get(ApiConstants.tripById + tripId);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return TripDetailResponse.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch trip details');
    }
  }
}
