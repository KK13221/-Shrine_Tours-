import 'package:equatable/equatable.dart';

abstract class PaymentOrderDetailEvent extends Equatable {
  const PaymentOrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentOrderDetail extends PaymentOrderDetailEvent {
  final String orderId;

  const LoadPaymentOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
