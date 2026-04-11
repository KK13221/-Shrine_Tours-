import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';

import '../../data/models/packing_model.dart';

abstract class IPackingRepository {
  Future<Either<Failure, bool>> updateTransports({
    required String tripId,
    required List<String> transports,
  });

  Future<Either<Failure, PackingListResponseModel>> getPackingList({
    required String tripId,
  });

  Future<Either<Failure, PackingListResponseModel>> togglePackingItem({
    required String tripId,
    required String itemId,
    required bool isChecked,
    required int quantity,
  });

  Future<Either<Failure, PackingListResponseModel>> addCategory({
    required String tripId,
    required String name,
    required String icon,
  });

  Future<Either<Failure, PackingListResponseModel>> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    required int quantity,
  });
}
