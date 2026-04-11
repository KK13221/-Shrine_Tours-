import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/weather_datasource.dart';
import 'package:shrine_tours/features/trip_planning/data/model/weather.dart';

abstract class IWeatherRepository {
  /// Fetch weather from API
  Future<Either<Failure, Weather>> getWeather(String city, String date);
}

class WeatherRepository implements IWeatherRepository {
  final WeatherDataSource _dataSource;

  WeatherRepository(this._dataSource);

  @override
  Future<Either<Failure, Weather>> getWeather(String city, String date) async {
    try {
      final weather = await _dataSource.getWeather(city: city, date: date);
      return Right(weather);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to fetch weather: $e'));
    }
  }
}
