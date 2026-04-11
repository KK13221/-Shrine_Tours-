import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String city;
  final String date;
  final String condition;
  final double minTemp;
  final double maxTemp;
  final String summary;
  final int precipitationChance;
  final String wind;
  final int humidity;

  const Weather({
    required this.city,
    required this.date,
    required this.condition,
    required this.minTemp,
    required this.maxTemp,
    required this.summary,
    required this.precipitationChance,
    required this.wind,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city'] ?? '',
      date: json['date'] ?? '',
      condition: json['condition'] ?? '',
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 0.0,
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] ?? '',
      precipitationChance: json['precipitationChance'] ?? 0,
      wind: json['wind'] ?? '',
      humidity: json['humidity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'date': date,
      'condition': condition,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'summary': summary,
      'precipitationChance': precipitationChance,
      'wind': wind,
      'humidity': humidity,
    };
  }

  @override
  List<Object?> get props => [
        city,
        date,
        condition,
        minTemp,
        maxTemp,
        summary,
        precipitationChance,
        wind,
        humidity,
      ];
}
