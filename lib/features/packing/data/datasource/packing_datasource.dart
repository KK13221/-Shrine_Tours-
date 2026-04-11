import '../models/packing_model.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_response.dart';

abstract class PackingDataSource {
  Future<ApiResponse<dynamic>> updateTransports({
    required String tripId,
    required List<String> transports,
  });

  Future<ApiResponse<PackingListResponseModel>> getPackingList({
    required String tripId,
  });

  Future<ApiResponse<PackingListResponseModel>> togglePackingItem({
    required String tripId,
    required String itemId,
    required bool isChecked,
    required int quantity,
  });

  Future<ApiResponse<PackingListResponseModel>> addCategory({
    required String tripId,
    required String name,
    required String icon,
  });

  Future<ApiResponse<PackingListResponseModel>> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    required int quantity,
  });
}

class PackingDataSourceImpl implements PackingDataSource {
  final ApiClient apiClient;

  PackingDataSourceImpl(this.apiClient);

  @override
  Future<ApiResponse<dynamic>> updateTransports({
    required String tripId,
    required List<String> transports,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.updateTransports}$tripId/transports',
      body: {
        'selected_transports': transports,
      },
    );

    return ApiResponse.fromJson(
      response,
      (data) => data,
    );
  }

  @override
  Future<ApiResponse<PackingListResponseModel>> getPackingList({
    required String tripId,
  }) async {
    final response = await apiClient.get(
      ApiConstants.packingLists,
      queryParams: {
        'trip_id': tripId,
      },
    );

    return ApiResponse.fromJson(
      response,
      (data) => PackingListResponseModel.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<PackingListResponseModel>> togglePackingItem({
    required String tripId,
    required String itemId,
    required bool isChecked,
    required int quantity,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.packingLists}/$tripId/toggle-item/$itemId',
      body: {
        'is_checked': isChecked,
        'quantity': quantity,
      },
    );

    return ApiResponse.fromJson(
      response,
      (data) => PackingListResponseModel.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<PackingListResponseModel>> addCategory({
    required String tripId,
    required String name,
    required String icon,
  }) async {
    final response = await apiClient.post(
      '${ApiConstants.addPackingCategory}$tripId/Addcategories',
      body: {
        'name': name,
        'icon': icon,
      },
    );

    return ApiResponse.fromJson(
      response,
      (data) => PackingListResponseModel.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<PackingListResponseModel>> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    required int quantity,
  }) async {
    final response = await apiClient.post(
      '${ApiConstants.addPackingItem}$tripId/add-item',
      body: {
        'category_id': categoryId,
        'name': name,
        'quantity': quantity,
      },
    );

    return ApiResponse.fromJson(
      response,
      (data) => PackingListResponseModel.fromJson(data),
    );
  }
}
