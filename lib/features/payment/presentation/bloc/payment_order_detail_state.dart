import 'package:equatable/equatable.dart';
import '../../data/models/payment_models.dart';

abstract class PaymentOrderDetailState extends Equatable {
  const PaymentOrderDetailState();

  @override
  List<Object?> get props => [];
}

class PaymentOrderDetailInitial extends PaymentOrderDetailState {}

class PaymentOrderDetailLoading extends PaymentOrderDetailState {}

class PaymentOrderDetailLoaded extends PaymentOrderDetailState {
  final PaymentOrderData orderDetail;

  const PaymentOrderDetailLoaded(this.orderDetail);

  @override
  List<Object?> get props => [orderDetail];
}

class PaymentOrderDetailError extends PaymentOrderDetailState {
  final String message;

  const PaymentOrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
