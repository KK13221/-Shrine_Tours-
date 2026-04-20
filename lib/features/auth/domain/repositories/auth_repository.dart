import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/auth/data/model/auth_token.dart';
import 'package:shrine_tours/features/auth/data/model/user.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final TokenStorageRepo _storage;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._storage, this._apiClient, this._googleSignIn);

  /// Sign in user with email and password
  Future<Either<Failure, User>> signIn(
      {required String email, required String password}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final authToken = AuthToken.fromJson(data);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.saveTokens(authToken);
        await _storage.saveUserInfo(user: user);

        return Right(user);
      } else {
        return Left(ApiFailure(response?['message'] ?? 'Login failed'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to sign in: $e'));
    }
  }

  Future<Either<Failure, bool>> logOut() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.logout,
      );

      if (response != null && response['success'] == true) {
        return const Right(true);
      } else {
        return Left(ApiFailure(response?['message'] ?? 'Logout failed'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to Logout: $e'));
    }
  }

  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out failed: $e');
    }
  }

  Future<void> googleSignInSilently() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      print('Google sign in silently failed: $e');
    }
  }

  /// Sign up user
  Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final authToken = AuthToken.fromJson(data);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.saveTokens(authToken);
        await _storage.saveUserInfo(user: user);

        return Right(user);
      } else {
        return Left(ApiFailure(response?['message'] ?? 'Registration failed'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to register: $e'));
    }
  }

  // refresh token
  Future<bool> refreshToken() async {
    try {
      final stored = _storage.getTokens();
      if (stored == null) return false;

      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        body: {
          'refreshToken': stored.refreshToken,
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        // Retain the old refresh token if the server doesn't return a new one
        final newExpiresIn = data['expiresIn'] as int? ?? 3600;
        final newToken = AuthToken(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] ?? stored.refreshToken,
          expiresAt: DateTime.now().add(Duration(seconds: newExpiresIn)),
        );

        await _storage.saveTokens(newToken);
        return true;
      }

      // If we fall through, the refresh response was not successful
      await _storage.clearPreferences();
      return false;
    } catch (e) {
      // Refresh failed — force logout.
      await _storage.clearPreferences();
      return false;
    }
  }

  // ── Session check ─────────────────────────────────────────────────────────

  /// Called from splash screen to decide where to navigate.
  /// Returns restored AuthUser if session is valid, null if not.
  Future<User?> restoreSession() async {
    final token = _storage.getTokens();
    if (token == null) return null;

    print(token.toString());

    // Token exists — check if it needs refreshing.
    if (token.isExpired) {
      final refreshed = await refreshToken();
      print('Token expired. Refresh attempted: $refreshed');
      if (!refreshed) return null; // refresh failed → logged out
    }

    final id = _storage.userId;
    final name = _storage.userName;
    final email = _storage.userEmail;
    final phone = _storage.userPhone;
    final premium = _storage.userPremium;
    final profilePictureUrl = _storage.userProfilePicture;
    if (name == null || email == null) return null;

    print('------------ USER INFO -------------------');
    print('name: $name, email: $email , profilePictureUrl: $profilePictureUrl');

    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      premium: premium,
      profilePictureUrl: profilePictureUrl,
    );
  }

  // ── Token accessor for API client ─────────────────────────────────────────

  /// Used by Dio interceptor to attach Bearer token to requests.
  /// Returns a fresh token, refreshing if needed.
  Future<String?> getValidAccessToken() async {
    final token = _storage.getTokens();
    if (token == null) return null;

    if (token.isExpired) {
      final refreshed = await refreshToken();
      if (!refreshed) return null;
    }

    return _storage.getTokens()?.accessToken;
  }

  /// Send OTP to email for password reset
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        body: {'email': email},
      );

      if (response != null && response['success'] == true) {
        return const Right(true);
      } else {
        return Left(
            ApiFailure(response?['message'] ?? 'Failed to send reset code'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to send reset code: $e'));
    }
  }

  /// Verify OTP for reset password flow
  Future<Either<Failure, bool>> verifyOtp(
      {required String email, required String otp}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      if (response != null && response['success'] == true) {
        return const Right(true);
      } else {
        return Left(ApiFailure(response?['message'] ?? 'Invalid OTP'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to verify OTP: $e'));
    }
  }

  /// Reset password with email, new password, and confirm password
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        body: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response != null && response['success'] == true) {
        return const Right(true);
      } else {
        return Left(
            ApiFailure(response?['message'] ?? 'Failed to reset password'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to reset password: $e'));
    }
  }

  /// Google Sign-In
  Future<Either<Failure, User>> googleSignIn({
    required String email,
    required String name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.googleSignIn,
        body: {
          'email': email,
          'name': name,
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final authToken = AuthToken.fromJson(data);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.saveTokens(authToken);
        await _storage.saveUserInfo(user: user);

        return Right(user);
      } else {
        return Left(
            ApiFailure(response?['message'] ?? 'Google sign-in failed'));
      }
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to sign in with Google: $e'));
    }
  }
}
