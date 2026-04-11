import 'package:equatable/equatable.dart';

class ItineraryModel extends Equatable {
  final String id;
  final String tripId;
  final String city;
  final String title;
  final List<ItineraryDayModel> days;

  const ItineraryModel({
    required this.id,
    required this.tripId,
    required this.city,
    required this.title,
    required this.days,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      city: json['city'] as String? ?? '',
      title: json['title'] as String? ?? '',
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => ItineraryDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'city': city,
      'title': title,
      'days': days.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, tripId, city, title, days];
}

class ItineraryDayModel extends Equatable {
  final int dayNumber;
  final List<ItineraryActivityModel> activities;

  const ItineraryDayModel({
    required this.dayNumber,
    required this.activities,
  });

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    return ItineraryDayModel(
      dayNumber: json['dayNumber'] as int? ?? 1,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => ItineraryActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [dayNumber, activities];
}

class ItineraryActivityModel extends Equatable {
  final String id;
  final String activityTime;
  final String title;
  final String duration;
  final double cost;
  final String icon;

  const ItineraryActivityModel({
    required this.id,
    required this.activityTime,
    required this.title,
    required this.duration,
    required this.cost,
    required this.icon,
  });

  factory ItineraryActivityModel.fromJson(Map<String, dynamic> json) {
    return ItineraryActivityModel(
      id: json['id'] as String? ?? '',
      activityTime: json['activityTime'] as String? ?? '',
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] as String? ?? 'explore',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityTime': activityTime,
      'title': title,
      'duration': duration,
      'cost': cost,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, activityTime, title, duration, cost, icon];
}
