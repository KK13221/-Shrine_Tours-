import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../../data/models/packing_model.dart';
import '../repositories/packing_repository.dart';

class AddPackingItemUseCase {
  final IPackingRepository repository;

  AddPackingItemUseCase(this.repository);

  Future<Either<Failure, PackingListResponseModel>> call({
    required String tripId,
    required String categoryId,
    required String name,
    required int quantity,
  }) {
    return repository.addItem(
      tripId: tripId,
      categoryId: categoryId,
      name: name,
      quantity: quantity,
    );
  }
}
