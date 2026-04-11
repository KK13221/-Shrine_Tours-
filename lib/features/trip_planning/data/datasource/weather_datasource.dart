import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import 'package:shrine_tours/features/trip_planning/data/model/weather.dart';

abstract class WeatherDataSource {
  /// Fetch weather for a city and date
  Future<Weather> getWeather({required String city, required String date});
}

class WeatherDataSourceImpl implements WeatherDataSource {
  final ApiClient _apiClient;

  WeatherDataSourceImpl(this._apiClient);

  @override
  Future<Weather> getWeather({required String city, required String date}) async {
    final response = await _apiClient.get(
      ApiConstants.weather,
      queryParams: {
        'city': city,
        'date': date,
      },
    );

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return Weather.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch weather');
    }
  }
}
