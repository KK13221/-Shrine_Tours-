import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import 'payment_order_detail_event.dart';
import 'payment_order_detail_state.dart';

class PaymentOrderDetailBloc extends Bloc<PaymentOrderDetailEvent, PaymentOrderDetailState> {
  final GetOrderByIdUseCase _getOrderByIdUseCase;

  PaymentOrderDetailBloc(this._getOrderByIdUseCase) : super(PaymentOrderDetailInitial()) {
    on<LoadPaymentOrderDetail>(_onLoadPaymentOrderDetail);
  }

  Future<void> _onLoadPaymentOrderDetail(
    LoadPaymentOrderDetail event,
    Emitter<PaymentOrderDetailState> emit,
  ) async {
    emit(PaymentOrderDetailLoading());

    final result = await _getOrderByIdUseCase.call(event.orderId);

    result.fold(
      (failure) => emit(PaymentOrderDetailError(failure.message)),
      (response) {
        if (response.data != null) {
          emit(PaymentOrderDetailLoaded(response.data!));
        } else {
          emit(const PaymentOrderDetailError('Order details not found'));
        }
      },
    );
  }
}
