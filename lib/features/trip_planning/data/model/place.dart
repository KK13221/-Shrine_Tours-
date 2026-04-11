import 'package:equatable/equatable.dart';

class Place extends Equatable {
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

  const Place({
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

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      typicalDuration: json['typicalDuration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as bool? ?? false,
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
      ];
}
