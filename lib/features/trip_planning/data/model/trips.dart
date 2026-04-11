import 'package:equatable/equatable.dart';

class Trips extends Equatable {
  final String id;
  final String city;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final int placesCount;
  final int days;
  final int adults;
  final int kids;
  final String tripStyle;
  final String purposeOfTravel;
  final String itineraryId;

  const Trips({
    required this.id,
    required this.city,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.placesCount,
    required this.days,
    required this.adults,
    required this.kids,
    this.tripStyle = '',
    this.purposeOfTravel = '',
    this.itineraryId = '',
  });

  /// Create from JSON response from API
  factory Trips.fromJson(Map<String, dynamic> json) {
    return Trips(
      id: json['id'] ?? '',
      city: json['city'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      placesCount: json['placesCount'] ?? 0,
      days: json['days'] ?? 0,
      adults: json['adults'] ?? 0,
      kids: json['kids'] ?? 0,
      tripStyle: json['tripStyle'] ?? '',
      purposeOfTravel: json['purposeOfTravel'] ?? '',
      itineraryId: json['itineraryId'] ?? '',
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'placesCount': placesCount,
      'days': days,
      'adults': adults,
      'kids': kids,
      'tripStyle': tripStyle,
      'purposeOfTravel': purposeOfTravel,
      'itineraryId': itineraryId,
    };
  }

  @override
  List<Object?> get props => [id, city, imageUrl, startDate, endDate, placesCount, days, adults, kids];
}