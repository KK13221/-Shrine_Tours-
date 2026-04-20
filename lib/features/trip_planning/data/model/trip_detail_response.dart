import 'package:equatable/equatable.dart';

class TripDetailResponse extends Equatable {
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
  final List<PlaceDetail> places;
  final PlaceDetail? startingPoint;

  const TripDetailResponse({
    required this.id,
    required this.city,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.placesCount,
    required this.days,
    required this.adults,
    required this.kids,
    required this.tripStyle,
    required this.purposeOfTravel,
    required this.itineraryId,
    required this.places,
    this.startingPoint,
  });

  factory TripDetailResponse.fromJson(Map<String, dynamic> json) {
    return TripDetailResponse(
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
      places: (json['places'] as List<dynamic>?)
              ?.map((e) => PlaceDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      startingPoint: json['starting_point'] != null
          ? PlaceDetail.fromJson(json['starting_point'] as Map<String, dynamic>)
          : null,
    );
  }

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
      'places': places.map((e) => e.toJson()).toList(),
      'starting_point': startingPoint?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        city,
        imageUrl,
        startDate,
        endDate,
        placesCount,
        days,
        adults,
        kids,
        tripStyle,
        purposeOfTravel,
        itineraryId,
        places,
        startingPoint,
      ];
}

class PlaceDetail extends Equatable {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String typicalDuration;
  final double rating;
  final int reviewsCount;
  final bool verified;
  final double latitude;
  final double longitude;
  // description field removed as per user request

  const PlaceDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.typicalDuration,
    required this.rating,
    required this.reviewsCount,
    required this.verified,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      typicalDuration: json['typicalDuration'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      verified: json['verified'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'typicalDuration': typicalDuration,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'verified': verified,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        imageUrl,
        typicalDuration,
        rating,
        reviewsCount,
        verified,
        latitude,
        longitude,
      ];
}
