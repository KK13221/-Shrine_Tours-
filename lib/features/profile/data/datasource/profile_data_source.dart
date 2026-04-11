import 'package:shrine_tours/core/api/api_client.dart';
import 'package:shrine_tours/core/api/api_constants.dart';
import 'package:shrine_tours/features/profile/data/model/user_profile_model.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import 'package:shrine_tours/features/profile/data/model/subscription_model.dart';

abstract class ProfileDataSource {
  /// Fetch user profile from API
  Future<UserProfileModel> getProfile();

  /// Update profile info
  Future<UserProfileModel> updateProfile(Map<String, dynamic> profileData);

  /// Upload profile avatar
  Future<String> uploadAvatar(String filePath);

  /// Fetch payment methods
  Future<List<PaymentCardModel>> getPaymentMethods();

  /// Add payment method
  Future<PaymentCardModel> addPaymentMethod(Map<String, dynamic> body);

  /// Fetch subscription details
  Future<SubscriptionModel> getSubscription();
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final ApiClient _apiClient;

  ProfileDataSourceImpl(this._apiClient);

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch profile');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _apiClient.put(ApiConstants.updateProfile, body: profileData);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to update profile');
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final response = await _apiClient.uploadFile(
      ApiConstants.uploadAvatar,
      fieldName: 'file',
      file: filePath,
    );

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return data['avatarUrl'] ?? '';
    } else {
      throw Exception(response?['message'] ?? 'Failed to upload avatar');
    }
  }

  @override
  Future<List<PaymentCardModel>> getPaymentMethods() async {
    final response = await _apiClient.get(ApiConstants.paymentMethods);

    if (response != null && response['success'] == true) {
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((item) => PaymentCardModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch payment methods');
    }
  }

  @override
  Future<PaymentCardModel> addPaymentMethod(Map<String, dynamic> body) async {
    final response = await _apiClient.post(ApiConstants.addPaymentMethod, body: body);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return PaymentCardModel.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to add payment method');
    }
  }

  @override
  Future<SubscriptionModel> getSubscription() async {
    final response = await _apiClient.get(ApiConstants.subscription);

    if (response != null && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return SubscriptionModel.fromJson(data);
    } else {
      throw Exception(response?['message'] ?? 'Failed to fetch subscription');
    }
  }
}
