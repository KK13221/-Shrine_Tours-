import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../../data/models/packing_model.dart';
import '../repositories/packing_repository.dart';

class GetPackingListUseCase {
  final IPackingRepository repository;

  GetPackingListUseCase(this.repository);

  Future<Either<Failure, PackingListResponseModel>> call(String tripId) async {
    return await repository.getPackingList(tripId: tripId);
  }
}
