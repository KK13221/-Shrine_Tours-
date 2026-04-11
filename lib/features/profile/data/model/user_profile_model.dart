import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String avatarUrl;
  final String level;
  final double levelProgress;
  final int tripsCompleted;
  final bool premium;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.avatarUrl,
    required this.level,
    required this.levelProgress,
    required this.tripsCompleted,
    required this.premium,
  });

  /// Create from JSON response from API
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 'Explorer',
      levelProgress: (json['levelProgress'] ?? 0).toDouble(),
      tripsCompleted: json['tripsCompleted'] ?? 0,
      premium: json['premium'] ?? false,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'avatarUrl': avatarUrl,
      'level': level,
      'levelProgress': levelProgress,
      'tripsCompleted': tripsCompleted,
      'premium': premium,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? avatarUrl,
    String? level,
    double? levelProgress,
    int? tripsCompleted,
    bool? premium,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      levelProgress: levelProgress ?? this.levelProgress,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      premium: premium ?? this.premium,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, dob, avatarUrl, level, levelProgress, tripsCompleted, premium];
}
