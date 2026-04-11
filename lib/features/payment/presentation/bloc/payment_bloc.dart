import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';
import '../../data/models/payment_models.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;

  PaymentBloc({
    required this.createOrderUseCase,
    required this.verifyPaymentUseCase,
  }) : super(PaymentInitial()) {
    on<CreatePaymentOrderEvent>(_onCreatePaymentOrder);
    on<VerifyPaymentEvent>(_onVerifyPayment);
  }

  Future<void> _onCreatePaymentOrder(
      CreatePaymentOrderEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());

    final request = PaymentOrderRequest(planCode: event.planCode);
    final result = await createOrderUseCase(request);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (response) {
        if (response.success) {
          emit(PaymentOrderCreatedSuccess(response));
        } else {
          emit(PaymentError(response.message));
        }
      },
    );
  }

  Future<void> _onVerifyPayment(
      VerifyPaymentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());

    final request = PaymentVerifyRequest(
      razorpayOrderId: event.razorpayOrderId,
      razorpayPaymentId: event.razorpayPaymentId,
      razorpaySignature: event.razorpaySignature,
    );

    final result = await verifyPaymentUseCase(request);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (response) {
        if (response.success) {
          emit(PaymentVerifiedSuccess(response));
        } else {
          emit(PaymentError(response.message));
        }
      },
    );
  }
}
