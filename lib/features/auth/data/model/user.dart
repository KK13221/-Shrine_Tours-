class User {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final bool? premium;
  final String? profilePictureUrl; // Optional: if your API provides this

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.premium,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      premium: json['premium'] as bool?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }
}