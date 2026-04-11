import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class CreatePaymentOrderEvent extends PaymentEvent {
  final String planCode;

  const CreatePaymentOrderEvent(this.planCode);

  @override
  List<Object> get props => [planCode];
}

class VerifyPaymentEvent extends PaymentEvent {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyPaymentEvent({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object> get props => [razorpayOrderId, razorpayPaymentId, razorpaySignature];
}
