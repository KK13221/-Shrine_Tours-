import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../../data/models/packing_model.dart';
import '../repositories/packing_repository.dart';

class AddPackingCategoryUseCase {
  final IPackingRepository repository;

  AddPackingCategoryUseCase(this.repository);

  Future<Either<Failure, PackingListResponseModel>> call({
    required String tripId,
    required String name,
    required String icon,
  }) {
    return repository.addCategory(
      tripId: tripId,
      name: name,
      icon: icon,
    );
  }
}
