// ─────────────────────────────────────────────
// AUTH TOKEN MODEL
// Mirrors the shape your backend will return.
// TODO: Adjust field names to match actual API response keys.
// ─────────────────────────────────────────────

class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt; // computed from expiresIn seconds

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Build from API JSON response.
  /// TODO: Adjust keys to match your backend (e.g. 'access_token', 'expires_in').
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expiresIn'] as int? ?? 3600;
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  /// Reconstruct from SharedPreferences persisted values.
  factory AuthToken.fromStorage({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
  }) {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  /// True when the access token has expired (with a 60-second buffer).
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));

  @override
  String toString() =>
      'AuthToken(accessToken: ${accessToken.substring(0, 6)}..., expiresAt: $expiresAt)';
}