import 'package:dio/dio.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import '../model/place.dart';

abstract class PlacesDataSource {
  Future<List<Place>> getPlaces(String city);
  Future<List<Place>> getSuggestedPlaces(String city);
}

class PlacesDataSourceImpl implements PlacesDataSource {
  final Dio _dio;

  PlacesDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<Place>> getPlaces(String city) async {
    return _fetchFromGoogle(city, "tourist attractions in $city");
  }

  @override
  Future<List<Place>> getSuggestedPlaces(String city) async {
    // For suggestions, we use a more curated query
    return _fetchFromGoogle(city, "top sights in $city", limit: 10);
  }

  Future<List<Place>> _fetchFromGoogle(String city, String query,
      {int? limit}) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/textsearch/json',
        queryParameters: {
          'query': query,
          'key': ApiConstants.googleApiKey,
        },
      );

      final results = response.data['results'] as List<dynamic>?;
      if (results == null) return [];

      var places = results
          .map((json) => _mapGoogleToPlace(json as Map<String, dynamic>))
          .toList();

      if (limit != null && places.length > limit) {
        places = places.sublist(0, limit);
      }

      return places;
    } catch (e) {
      // Re-throw or handle as needed for your failure logic
      throw Exception('Failed to fetch places from Google: $e');
    }
  }

  Place _mapGoogleToPlace(Map<String, dynamic> json) {
    final photoReference = (json['photos'] as List?)?.first?['photo_reference'];
    final imageUrl = photoReference != null
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=${ApiConstants.googleApiKey}'
        : 'https://via.placeholder.com/400x300?text=No+Image';

    final location = json['geometry']?['location'];

    return Place(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      category:
          (json['types'] as List?)?.first?.toString().replaceAll('_', ' ') ??
              'Point of Interest',
      imageUrl: imageUrl,
      typicalDuration:
          '2-3 hours', // Google doesn't provide this, using default
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['user_ratings_total'] as num?)?.toInt() ?? 0,
      verified: true, // Google results are generally reliable

      latitude: location?['lat'] ?? 0.0,
      longitude: location?['lng'] ?? 0.0,
    );
  }
}
