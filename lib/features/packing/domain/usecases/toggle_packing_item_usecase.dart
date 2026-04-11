import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../repositories/packing_repository.dart';
import '../../data/models/packing_model.dart';

class TogglePackingItemUseCase {
  final IPackingRepository repository;

  TogglePackingItemUseCase(this.repository);

  Future<Either<Failure, PackingListResponseModel>> call({
    required String tripId,
    required String itemId,
    required bool isChecked,
    required int quantity,
  }) async {
    return await repository.togglePackingItem(
      tripId: tripId,
      itemId: itemId,
      isChecked: isChecked,
      quantity: quantity,
    );
  }
}
