import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/core/di/injection.dart';
import 'package:shrine_tours/features/auth/data/model/user.dart';
import 'package:shrine_tours/features/auth/domain/repositories/auth_repository.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {
  final String email;
  final String name;
  const GoogleSignInRequested({required this.email, required this.name});
  @override
  List<Object?> get props => [email, name];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  const SignUpRequested({required this.name, required this.email, required this.phone, required this.password});
  @override
  List<Object?> get props => [name, email, phone, password];
}

class SignOutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user,});
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}


class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthRepository _repository;
  final _storage = getIt<TokenStorageRepo>();

  AuthBloc({required AuthRepository repository}) :
        _repository = repository,  super(AuthInitial()) {
    on<SignInRequested>(_onSignIn);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repository.signIn(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onGoogleSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repository.googleSignIn(
      email: event.email,
      name: event.name,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repository.signUp(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _storage.clearPreferences();
    emit(AuthUnauthenticated());
  }

  // SPLASH
    Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    final user = await _repository.restoreSession();
 
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
