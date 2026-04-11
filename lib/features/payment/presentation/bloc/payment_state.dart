import 'package:equatable/equatable.dart';
import '../../data/models/payment_models.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentOrderCreatedSuccess extends PaymentState {
  final PaymentOrderResponse response;

  const PaymentOrderCreatedSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PaymentVerifiedSuccess extends PaymentState {
  final PaymentVerifyResponse response;

  const PaymentVerifiedSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
