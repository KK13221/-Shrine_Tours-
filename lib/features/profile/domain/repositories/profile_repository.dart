import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/api/api_exceptions.dart';
import 'package:shrine_tours/core/failures.dart';
import 'package:shrine_tours/features/profile/data/datasource/profile_data_source.dart';
import 'package:shrine_tours/features/profile/data/model/user_profile_model.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import 'package:shrine_tours/features/profile/data/model/subscription_model.dart';

abstract class IProfileRepository {
  /// Fetch user profile from API
  Future<Either<Failure, UserProfileModel>> getProfile();

  /// Update profile info
  Future<Either<Failure, UserProfileModel>> updateProfile(Map<String, dynamic> profileData);

  /// Upload profile avatar
  Future<Either<Failure, String>> uploadAvatar(String filePath);

  /// Fetch payment methods
  Future<Either<Failure, List<PaymentCardModel>>> getPaymentMethods();

  /// Add payment method
  Future<Either<Failure, PaymentCardModel>> addPaymentMethod(Map<String, dynamic> body);

  /// Fetch subscription details
  Future<Either<Failure, SubscriptionModel>> getSubscription();
}

class ProfileRepository implements IProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepository(this._dataSource);

  @override
  Future<Either<Failure, UserProfileModel>> getProfile() async {
    try {
      final profile = await _dataSource.getProfile();
      return Right(profile);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to fetch profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final profile = await _dataSource.updateProfile(profileData);
      return Right(profile);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final avatarUrl = await _dataSource.uploadAvatar(filePath);
      return Right(avatarUrl);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to upload avatar: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentCardModel>>> getPaymentMethods() async {
    try {
      final cards = await _dataSource.getPaymentMethods();
      return Right(cards);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to fetch payment methods: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentCardModel>> addPaymentMethod(
      Map<String, dynamic> body) async {
    try {
      final card = await _dataSource.addPaymentMethod(body);
      return Right(card);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to add payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionModel>> getSubscription() async {
    try {
      final subscription = await _dataSource.getSubscription();
      return Right(subscription);
    } on ApiException catch (e) {
      return Left(ApiFailure(e.message));
    } catch (e) {
      return Left(ApiFailure('Failed to fetch subscription: $e'));
    }
  }
}
