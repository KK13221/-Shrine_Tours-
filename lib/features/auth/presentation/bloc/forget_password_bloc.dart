import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:shrine_tours/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:shrine_tours/features/auth/domain/usecases/reset_password_usecase.dart';

// EVENTS
abstract class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgetPasswordEmailSubmitted extends ForgetPasswordEvent {
  final String email;
  const ForgetPasswordEmailSubmitted({required this.email});
  @override
  List<Object?> get props => [email];
}

class ForgetPasswordOtpSubmitted extends ForgetPasswordEvent {
  final String email;
  final String otp;
  const ForgetPasswordOtpSubmitted({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class ForgetPasswordResetSubmitted extends ForgetPasswordEvent {
  final String email;
  final String newPassword;
  final String confirmPassword;

  const ForgetPasswordResetSubmitted({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, newPassword, confirmPassword];
}

// STATES
abstract class ForgetPasswordState extends Equatable {
  const ForgetPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {}

class ForgetPasswordEmailSuccess extends ForgetPasswordState {}

class ForgetPasswordOtpSuccess extends ForgetPasswordState {}

class ForgetPasswordResetSuccess extends ForgetPasswordState {}

class ForgetPasswordFailure extends ForgetPasswordState {
  final String message;
  const ForgetPasswordFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLOC
class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgetPasswordBloc(
    this._forgotPasswordUseCase,
    this._verifyOtpUseCase,
    this._resetPasswordUseCase,
  ) : super(ForgetPasswordInitial()) {
    on<ForgetPasswordEmailSubmitted>(_onEmailSubmitted);
    on<ForgetPasswordOtpSubmitted>(_onOtpSubmitted);
    on<ForgetPasswordResetSubmitted>(_onResetSubmitted);
  }

  Future<void> _onEmailSubmitted(
    ForgetPasswordEmailSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    emit(ForgetPasswordLoading());
    
    final result = await _forgotPasswordUseCase.call(event.email);
    result.fold(
      (failure) => emit(ForgetPasswordFailure(message: failure.message)),
      (success) => emit(ForgetPasswordEmailSuccess()),
    );
  }

  Future<void> _onOtpSubmitted(
    ForgetPasswordOtpSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    emit(ForgetPasswordLoading());

    final result = await _verifyOtpUseCase.call(
      email: event.email,
      otp: event.otp,
    );

    result.fold(
      (failure) => emit(ForgetPasswordFailure(message: failure.message)),
      (success) => emit(ForgetPasswordOtpSuccess()),
    );
  }

  Future<void> _onResetSubmitted(
    ForgetPasswordResetSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    emit(ForgetPasswordLoading());
    
    if (event.newPassword != event.confirmPassword) {
      emit(const ForgetPasswordFailure(message: 'Passwords do not match'));
      return;
    }
    
    if (event.newPassword.length < 6) {
      emit(const ForgetPasswordFailure(message: 'Password must be at least 6 characters'));
      return;
    }

    final result = await _resetPasswordUseCase.call(
      email: event.email,
      password: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(ForgetPasswordFailure(message: failure.message)),
      (success) => emit(ForgetPasswordResetSuccess()),
    );
  }
}
