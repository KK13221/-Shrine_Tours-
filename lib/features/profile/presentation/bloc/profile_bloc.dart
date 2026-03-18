import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String level;
  final double levelProgress;
  final int tripsCompleted;
  final bool isPremium;

  const UserProfile({
    this.name = 'John Doe',
    this.email = 'john.doe@example.com',
    this.phone = '+1 234 567 8900',
    this.dob = '01/01/1990',
    this.level = 'Explorer',
    this.levelProgress = 0.75,
    this.tripsCompleted = 5,
    this.isPremium = true,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      level: level,
      levelProgress: levelProgress,
      tripsCompleted: tripsCompleted,
      isPremium: isPremium,
    );
  }
}

class PaymentCard {
  final String type;
  final String lastFour;
  final String holderName;
  final String expiry;
  final bool isPrimary;

  const PaymentCard({
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expiry,
    this.isPrimary = false,
  });
}

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  const UpdateProfile({this.name, this.email, this.phone, this.dob});
  @override
  List<Object?> get props => [name, email, phone, dob];
}

class LoadPaymentCards extends ProfileEvent {}

// States
class ProfileState extends Equatable {
  final UserProfile profile;
  final List<PaymentCard> cards;
  final bool isLoading;
  final bool isSaving;

  const ProfileState({
    this.profile = const UserProfile(),
    this.cards = const [],
    this.isLoading = false,
    this.isSaving = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    List<PaymentCard>? cards,
    bool? isLoading,
    bool? isSaving,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [profile, cards, isLoading, isSaving];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadPaymentCards>(_onLoadCards);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(
      isLoading: false,
      profile: const UserProfile(),
    ));
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(
      isSaving: false,
      profile: state.profile.copyWith(
        name: event.name,
        email: event.email,
        phone: event.phone,
        dob: event.dob,
      ),
    ));
  }

  Future<void> _onLoadCards(LoadPaymentCards event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(
      cards: const [
        PaymentCard(type: 'VISA', lastFour: '4532', holderName: 'JOHN DOE', expiry: '12/25', isPrimary: true),
        PaymentCard(type: 'MC', lastFour: '8976', holderName: 'JOHN DOE', expiry: '08/26'),
      ],
    ));
  }
}
