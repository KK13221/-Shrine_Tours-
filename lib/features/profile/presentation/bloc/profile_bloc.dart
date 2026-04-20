import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/core/di/injection.dart';
import 'package:shrine_tours/features/auth/data/model/user.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';
import 'package:shrine_tours/features/profile/data/model/user_profile_model.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_subscription_usecase.dart';
import 'package:shrine_tours/features/payment/domain/usecases/get_order_history_usecase.dart';
import 'package:shrine_tours/features/payment/domain/usecases/download_invoice_usecase.dart';
import 'package:shrine_tours/features/payment/data/models/payment_models.dart';
import 'package:shrine_tours/features/profile/data/model/subscription_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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

class LoadSubscription extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  const UpdateProfile({this.name, this.email, this.phone, this.dob});
  @override
  List<Object?> get props => [name, email, phone, dob];
}

class UploadAvatar extends ProfileEvent {
  final String filePath;
  const UploadAvatar({required this.filePath});
  @override
  List<Object?> get props => [filePath];
}

class LoadPaymentCards extends ProfileEvent {}

class LoadBillingHistory extends ProfileEvent {}

class DownloadInvoiceEvent extends ProfileEvent {
  final String invoiceId;
  const DownloadInvoiceEvent(this.invoiceId);
  @override
  List<Object?> get props => [invoiceId];
}

// States
class ProfileState extends Equatable {
  final UserProfileModel profile;
  final SubscriptionModel? subscription;
  final List<PaymentCard> cards;
  final List<PaymentOrderData> billingRecords;
  final bool isLoading;
  final bool isBillingLoading;
  final bool isSaving;
  final bool isUploadingAvatar;
  final String? downloadingInvoiceId;
  final String? error;
  final bool hasError;

  const ProfileState({
    UserProfileModel? profile,
    this.subscription,
    this.cards = const [],
    this.billingRecords = const [],
    this.isLoading = false,
    this.isBillingLoading = false,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.downloadingInvoiceId,
    this.error,
    this.hasError = false,
  }) : profile = profile ??
            const UserProfileModel(
              id: '',
              name: 'John Doe',
              email: 'john.doe@example.com',
              phone: '+1 234 567 8900',
              dob: '01/01/1990',
              avatarUrl: 'https://picsum.photos/250?image=9',
              level: 'Explorer',
              levelProgress: 0.0,
              tripsCompleted: 0,
              premium: false,
            );

  ProfileState copyWith({
    UserProfileModel? profile,
    SubscriptionModel? subscription,
    List<PaymentCard>? cards,
    List<PaymentOrderData>? billingRecords,
    bool? isLoading,
    bool? isBillingLoading,
    bool? isSaving,
    bool? isUploadingAvatar,
    String? downloadingInvoiceId,
    String? error,
    bool? hasError,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      subscription: subscription ?? this.subscription,
      cards: cards ?? this.cards,
      billingRecords: billingRecords ?? this.billingRecords,
      isLoading: isLoading ?? this.isLoading,
      isBillingLoading: isBillingLoading ?? this.isBillingLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      downloadingInvoiceId: downloadingInvoiceId ?? this.downloadingInvoiceId,
      error: error ?? this.error,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        subscription,
        cards,
        billingRecords,
        isLoading,
        isBillingLoading,
        isSaving,
        isUploadingAvatar,
        downloadingInvoiceId,
        error,
        hasError
      ];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final GetSubscriptionUseCase _getSubscriptionUseCase;
  final GetOrderHistoryUseCase _getOrderHistoryUseCase;
  final DownloadInvoiceUseCase _downloadInvoiceUseCase;

  ProfileBloc(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._uploadAvatarUseCase,
    this._getSubscriptionUseCase,
    this._getOrderHistoryUseCase,
    this._downloadInvoiceUseCase,
  ) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadSubscription>(_onLoadSubscription);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<LoadPaymentCards>(_onLoadCards);
    on<LoadBillingHistory>(_onLoadBillingHistory);
    on<DownloadInvoiceEvent>(_onDownloadInvoice);
  }

  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false, error: null));

    final result = await _getSubscriptionUseCase.call();

    result.fold(
      (failure) {
        // If subscription is not found or fails, treat as free plan
        emit(state.copyWith(
          isLoading: false,
          subscription: SubscriptionModel.free,
          hasError: false, // Don't show technical error for "Subscription not found"
        ));
      },
      (subscription) => emit(state.copyWith(
        isLoading: false,
        subscription: subscription,
      )),
    );
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false, error: null));

    final result = await _getProfileUseCase.call();

    result.fold(
      (failure) {
        // Error case
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          error: failure.message,
        ));
      },
      (profileModel) {
        // Success case
        // Save to SharedPreferences via TokenStorageRepo
        getIt<TokenStorageRepo>().saveUserInfo(
          user: User(
            id: profileModel.id,
            name: profileModel.name,
            email: profileModel.email,
            premium: profileModel.premium,
            profilePictureUrl: profileModel.avatarUrl,
          ),
        );

        emit(state.copyWith(
          isLoading: false,
          profile: profileModel,
          hasError: false,
          error: null,
        ));
      },
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true, hasError: false, error: null));

    final profileData = {
      if (event.name != null) 'name': event.name,
      if (event.email != null) 'email': event.email,
      if (event.phone != null) 'phone': event.phone,
      if (event.dob != null) 'dob': event.dob,
    };

    final result = await _updateProfileUseCase.call(profileData);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSaving: false,
          hasError: true,
          error: failure.message,
        ));
      },
      (updatedProfile) {
        emit(state.copyWith(
          isSaving: false,
          profile: updatedProfile,
          hasError: false,
          error: null,
        ));

        // Update token storage with new profile info
        getIt<TokenStorageRepo>().saveUserInfo(
          user: User(
            name: updatedProfile.name,
            email: updatedProfile.email,
            profilePictureUrl: updatedProfile.avatarUrl,
          ),
        );
      },
    );
  }

  Future<void> _onUploadAvatar(
      UploadAvatar event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isUploadingAvatar: true, hasError: false, error: null));

    final result = await _uploadAvatarUseCase.call(event.filePath);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUploadingAvatar: false,
          hasError: true,
          error: failure.message,
        ));
      },
      (avatarUrl) {
        final updatedProfile = state.profile.copyWith(avatarUrl: avatarUrl);
        emit(state.copyWith(
          isUploadingAvatar: false,
          profile: updatedProfile,
          hasError: false,
          error: null,
        ));

        // Update token storage with new avatar URL
        getIt<TokenStorageRepo>().saveUserInfo(
          user: User(
            name: state.profile.name,
            email: state.profile.email,
            profilePictureUrl: avatarUrl,
          ),
        );
      },
    );
  }

  Future<void> _onLoadCards(
      LoadPaymentCards event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(
      cards: const [
        PaymentCard(
            type: 'VISA',
            lastFour: '4532',
            holderName: 'JOHN DOE',
            expiry: '12/25',
            isPrimary: true),
        PaymentCard(
            type: 'MC',
            lastFour: '8976',
            holderName: 'JOHN DOE',
            expiry: '08/26'),
      ],
    ));
  }

  Future<void> _onLoadBillingHistory(
      LoadBillingHistory event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isBillingLoading: true, hasError: false, error: null));

    final result = await _getOrderHistoryUseCase.call();

    result.fold(
      (failure) => emit(state.copyWith(
        isBillingLoading: false,
        hasError: true,
        error: failure.message,
      )),
      (response) => emit(state.copyWith(
        isBillingLoading: false,
        billingRecords: response.data,
      )),
    );
  }

  Future<void> _onDownloadInvoice(
      DownloadInvoiceEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(
        downloadingInvoiceId: event.invoiceId, hasError: false, error: null));

    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/invoice_${event.invoiceId}.pdf';

      final result = await _downloadInvoiceUseCase
          .call(
        DownloadInvoiceParams(id: event.invoiceId, savePath: savePath),
      )
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Download timed out. Please try again.');
      });

      result.fold(
        (failure) => emit(state.copyWith(
          downloadingInvoiceId: null,
          hasError: true,
          error: failure.message,
        )),
        (_) {
          emit(state.copyWith(
            downloadingInvoiceId: null,
          ));
          // Open the file after successful download
          OpenFilex.open(savePath);
        },
      );
    } catch (e) {
      emit(state.copyWith(
        downloadingInvoiceId: null,
        hasError: true,
        error: e.toString(),
      ));
    }
  }
}
