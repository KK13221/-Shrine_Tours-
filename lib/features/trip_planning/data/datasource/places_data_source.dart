import 'package:dio/dio.dart';
import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import '../model/place.dart';

abstract class PlacesDataSource {
  Future<List<Place>> getPlaces(String city);
  Future<List<Place>> getSuggestedPlaces(String city);
  Future<void> addPlaceToTrip({required Map<String, dynamic> body});
  Future<void> removeFromTrip({required Map<String, dynamic> body});
  Future<List<Place>> searchPlaces(String query);
  
  // New Google Places methods
  Future<List<Place>> searchPlacesFromGoogle(String query);
  Future<Place> getPlaceDetails(String placeId);
}

class PlacesDataSourceImpl implements PlacesDataSource {
  final ApiClient _apiClient;
  final Dio _googleDio = Dio();

  PlacesDataSourceImpl(this._apiClient);

  @override
  Future<List<Place>> getPlaces(String city) async {
    final response = await _apiClient.get(ApiConstants.places, queryParams: {
      'city': city,
    });

    if (response != null && response['success'] == true) {
      final data = response['data'] as List<dynamic>;
      return data
          .map((json) => Place.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch places');
    }
  }

  @override
  Future<List<Place>> getSuggestedPlaces(String city) async {
    final response =
        await _apiClient.get(ApiConstants.suggestedPlaces, queryParams: {
      'city': city,
    });

    if (response != null && response['success'] == true) {
      final data = response['data'] as List<dynamic>;
      return data
          .map((json) => Place.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          response?['message'] ?? 'Failed to fetch suggested places');
    }
  }

  @override
  Future<void> addPlaceToTrip({required Map<String, dynamic> body}) async {
    final response =
        await _apiClient.post(ApiConstants.addPlaceToTrip, body: body);

    if (response != null && response['success'] == true) {
      // Success
    } else {
      throw Exception(response?['message'] ?? 'Failed to add place to trip');
    }
  }

  @override
  Future<void> removeFromTrip({required Map<String, dynamic> body}) async {
    final response =
        await _apiClient.delete(ApiConstants.removePlaceFromTrip, body: body);

    if (response != null && response['success'] == true) {
      // Success
    } else {
      throw Exception(
          response?['message'] ?? 'Failed to remove place from trip');
    }
  }

  @override
  Future<List<Place>> searchPlaces(String query) async {
    final response = await _apiClient.get(ApiConstants.searchPlaces, queryParams: {
      'q': query,
    });

    if (response != null && response['success'] == true) {
      final data = response['data'] as List<dynamic>;
      return data
          .map((json) => Place.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response?['message'] ?? 'Failed to search places');
    }
  }

  @override
  Future<List<Place>> searchPlacesFromGoogle(String query) async {
    final response = await _googleDio.get(
      'https://maps.googleapis.com/maps/api/place/textsearch/json',
      queryParameters: {
        'query': query,
        'key': ApiConstants.googleApiKey,
      },
    );

    if (response.statusCode == 200 && response.data['status'] == 'OK') {
      final results = response.data['results'] as List<dynamic>;
      return results.map((result) {
        final location = result['geometry']['location'];
        String imageUrl = '';
        if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
          final photoReference = result['photos'][0]['photo_reference'];
          imageUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${ApiConstants.googleApiKey}';
        }

        return Place(
          id: result['place_id'] ?? '',
          name: result['name'] ?? '',
          category: (result['types'] as List?)?.isNotEmpty == true
              ? result['types'][0].toString().replaceAll('_', ' ')
              : 'Place',
          imageUrl: imageUrl,
          typicalDuration: '1-2 hours',
          rating: (result['rating'] as num?)?.toDouble() ?? 0.0,
          reviewsCount: (result['user_ratings_total'] as num?)?.toInt() ?? 0,
          verified: true,
          latitude: (location['lat'] as num).toDouble(),
          longitude: (location['lng'] as num).toDouble(),
        );
      }).toList();
    } else if (response.data['status'] == 'ZERO_RESULTS') {
      return [];
    } else {
      throw Exception('Google Places search failed: ${response.data['status']}');
    }
  }

  @override
  Future<Place> getPlaceDetails(String placeId) async {
    final response = await _googleDio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'name,geometry,rating,user_ratings_total,photos,place_id',
        'key': ApiConstants.googleApiKey,
      },
    );

    if (response.statusCode == 200 && response.data['status'] == 'OK') {
      final result = response.data['result'] as Map<String, dynamic>;
      final geometry = result['geometry'] as Map<String, dynamic>;
      final location = geometry['location'] as Map<String, dynamic>;

      String imageUrl = '';
      if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
        final photoReference = result['photos'][0]['photo_reference'];
        imageUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${ApiConstants.googleApiKey}';
      }

      return Place(
        id: result['place_id'] ?? '',
        name: result['name'] ?? '',
        category: 'Point of Interest',
        imageUrl: imageUrl,
        typicalDuration: '1-2 hours',
        rating: (result['rating'] as num?)?.toDouble() ?? 0.0,
        reviewsCount: (result['user_ratings_total'] as num?)?.toInt() ?? 0,
        verified: true,
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
      );
    } else {
      throw Exception(
          'Google Places details failed: ${response.data['status']}');
    }
  }
}
