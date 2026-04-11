import 'package:shared_preferences/shared_preferences.dart';
import 'package:shrine_tours/features/auth/data/model/auth_token.dart';
import 'package:shrine_tours/features/auth/data/model/user.dart';

// ─────────────────────────────────────────────
// TOKEN STORAGE
// Single responsibility: persist & retrieve tokens
// using SharedPreferences. Nothing else lives here.
// ─────────────────────────────────────────────

class TokenStorageRepo {
  // Private key constants — keeps key strings in one place.
  static const _kAccessToken = 'auth_access_token';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kExpiresAt = 'auth_expires_at';
  static const _kUserName = 'auth_user_name';
  static const _kUserEmail = 'auth_user_email';
  static const _kUserId = 'auth_user_id';
  static const _kUserPhone = 'auth_user_phone';
  static const _kUserPremium = 'auth_user_premium';
  static const _kUserProfilePicture = 'auth_user_profile_picture';
  final SharedPreferences _prefs;

  TokenStorageRepo(this._prefs);

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> saveTokens(AuthToken token) async {
    await Future.wait([
      _prefs.setString(_kAccessToken, token.accessToken),
      _prefs.setString(_kRefreshToken, token.refreshToken),
      _prefs.setString(_kExpiresAt, token.expiresAt.toIso8601String()),
    ]);
  }

  Future<void> saveUserInfo({
    required User user,
  }) async {
    await Future.wait([
      if (user.id != null) _prefs.setString(_kUserId, user.id!),
      _prefs.setString(_kUserName, user.name ?? ''),
      _prefs.setString(_kUserEmail, user.email ?? ''),
      if (user.phone != null) _prefs.setString(_kUserPhone, user.phone!),
      if (user.premium != null) _prefs.setBool(_kUserPremium, user.premium!),
      _prefs.setString(_kUserProfilePicture, user.profilePictureUrl ?? ''),
    ]);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns null if any token field is missing (not logged in).
  AuthToken? getTokens() {
    final access = _prefs.getString(_kAccessToken);
    final refresh = _prefs.getString(_kRefreshToken);
    final expiresAt = _prefs.getString(_kExpiresAt);

    if (access == null || refresh == null || expiresAt == null) return null;

    return AuthToken.fromStorage(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt,
    );
  }

  String? get userName => _prefs.getString(_kUserName);
  String? get userEmail => _prefs.getString(_kUserEmail);
  String? get userId => _prefs.getString(_kUserId);
  String? get userPhone => _prefs.getString(_kUserPhone);
  bool? get userPremium => _prefs.getBool(_kUserPremium);
  String? get userProfilePicture => _prefs.getString(_kUserProfilePicture);

  /// Convenience: is there a valid session stored?
  bool get hasSession => getTokens() != null;

  // ── Clear ─────────────────────────────────────────────────────────────────

  Future<void> clearPreferences() async {
    await Future.wait([
      _prefs.remove(_kAccessToken),
      _prefs.remove(_kRefreshToken),
      _prefs.remove(_kExpiresAt),
      _prefs.remove(_kUserName),
      _prefs.remove(_kUserEmail),
      _prefs.remove(_kUserId),
      _prefs.remove(_kUserPhone),
      _prefs.remove(_kUserPremium),
      _prefs.remove(_kUserProfilePicture),
    ]);
  }
}