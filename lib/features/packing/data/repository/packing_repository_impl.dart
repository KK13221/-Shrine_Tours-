import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../datasource/packing_datasource.dart';
import '../../domain/repositories/packing_repository.dart';
import '../models/packing_model.dart';

class PackingRepositoryImpl implements IPackingRepository {
  final PackingDataSource dataSource;

  PackingRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, bool>> updateTransports({
    required String tripId,
    required List<String> transports,
  }) async {
    try {
      final response = await dataSource.updateTransports(
        tripId: tripId,
        transports: transports,
      );

      if (response.success) {
        return const Right(true);
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PackingListResponseModel>> getPackingList({
    required String tripId,
  }) async {
    try {
      final response = await dataSource.getPackingList(tripId: tripId);

      if (response.success) {
        return Right(response.data!);
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PackingListResponseModel>> togglePackingItem({
    required String tripId,
    required String itemId,
    required bool isChecked,
    required int quantity,
  }) async {
    try {
      final response = await dataSource.togglePackingItem(
        tripId: tripId,
        itemId: itemId,
        isChecked: isChecked,
        quantity: quantity,
      );

      if (response.success) {
        return Right(response.data!);
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PackingListResponseModel>> addCategory({
    required String tripId,
    required String name,
    required String icon,
  }) async {
    try {
      final response = await dataSource.addCategory(
        tripId: tripId,
        name: name,
        icon: icon,
      );

      if (response.success) {
        return Right(response.data!);
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PackingListResponseModel>> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    required int quantity,
  }) async {
    try {
      final response = await dataSource.addItem(
        tripId: tripId,
        categoryId: categoryId,
        name: name,
        quantity: quantity,
      );

      if (response.success) {
        return Right(response.data!);
      } else {
        return Left(ApiFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
