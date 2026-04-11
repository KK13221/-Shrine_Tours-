import 'package:dartz/dartz.dart';
import 'package:shrine_tours/core/failures.dart';
import '../repositories/payment_repository.dart';

class DownloadInvoiceParams {
  final String id;
  final String savePath;

  DownloadInvoiceParams({
    required this.id,
    required this.savePath,
  });
}

class DownloadInvoiceUseCase {
  final PaymentRepository _repository;

  DownloadInvoiceUseCase(this._repository);

  Future<Either<Failure, void>> call(DownloadInvoiceParams params) async {
    return await _repository.downloadInvoice(params.id, params.savePath);
  }
}
