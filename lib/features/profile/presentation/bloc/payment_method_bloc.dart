import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_payment_methods_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/add_payment_method_usecase.dart';

// ─────────────────────────────────────────────
// PAYMENT METHOD EVENTS
// ─────────────────────────────────────────────

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all saved cards on screen load.
class LoadPaymentMethods extends PaymentMethodEvent {}

/// Add a new card from the bottom sheet form.
class AddPaymentMethod extends PaymentMethodEvent {
  final String type;
  final String cardNumber; // full number; bloc extracts lastFour
  final String holderName;
  final String expiry;
  final bool setAsPrimary;

  const AddPaymentMethod({
    required this.type,
    required this.cardNumber,
    required this.holderName,
    required this.expiry,
    this.setAsPrimary = false,
  });

  @override
  List<Object?> get props => [type, cardNumber, holderName, expiry, setAsPrimary];
}

/// Remove a card by id.
class RemovePaymentMethod extends PaymentMethodEvent {
  final String cardId;

  const RemovePaymentMethod({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

/// Promote a card to primary and demote all others.
class SetPrimaryPaymentMethod extends PaymentMethodEvent {
  final String cardId;

  const SetPrimaryPaymentMethod({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

/// Clear specific operation state
class ClearPaymentStatus extends PaymentMethodEvent {}


// ─────────────────────────────────────────────
// PAYMENT METHOD STATE
// ─────────────────────────────────────────────

class PaymentMethodState extends Equatable {
  final List<PaymentCardModel> cards;
  final bool isLoading;    // true while fetching cards on init
  final bool isAdding;     // true while add-card API call is in flight
  final bool addSuccess;   // true when a card is successfully added
  final String? error;     // non-null when something went wrong

  const PaymentMethodState({
    this.cards = const [],
    this.isLoading = false,
    this.isAdding = false,
    this.addSuccess = false,
    this.error,
  });

  PaymentMethodState copyWith({
    List<PaymentCardModel>? cards,
    bool? isLoading,
    bool? isAdding,
    bool? addSuccess,
    String? error,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PaymentMethodState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      addSuccess: clearSuccess ? false : addSuccess ?? this.addSuccess,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [cards, isLoading, isAdding, addSuccess, error];
}


// ─────────────────────────────────────────────
// PAYMENT METHOD BLOC
// ─────────────────────────────────────────────

class PaymentMethodBloc
    extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final AddPaymentMethodUseCase _addPaymentMethodUseCase;

  PaymentMethodBloc(
    this._getPaymentMethodsUseCase,
    this._addPaymentMethodUseCase,
  ) : super(const PaymentMethodState()) {
    on<LoadPaymentMethods>(_onLoad);
    on<AddPaymentMethod>(_onAdd);
    on<RemovePaymentMethod>(_onRemove);
    on<SetPrimaryPaymentMethod>(_onSetPrimary);
    on<ClearPaymentStatus>(_onClearStatus);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Primary cards always appear first.
  List<PaymentCardModel> _sorted(List<PaymentCardModel> cards) {
    final list = List<PaymentCardModel>.from(cards);
    list.sort((a, b) => b.isPrimary ? 1 : -1);
    return list;
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getPaymentMethodsUseCase.call();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (cards) => emit(state.copyWith(
        isLoading: false,
        cards: _sorted(cards),
      )),
    );
  }

  Future<void> _onAdd(
    AddPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, clearError: true, clearSuccess: true));

    final result = await _addPaymentMethodUseCase.call({
      'type': event.type,
      'card_number': event.cardNumber.replaceAll(' ', ''),
      'holder_name': event.holderName,
      'expiry': event.expiry,
      'is_primary': event.setAsPrimary,
    });

    result.fold(
      (failure) => emit(state.copyWith(isAdding: false, error: failure.message)),
      (newCard) {
        // If new card is primary, demote all existing primary cards first.
        List<PaymentCardModel> updated = event.setAsPrimary
            ? state.cards
                .map((c) => c.copyWith(isPrimary: false))
                .toList()
            : List<PaymentCardModel>.from(state.cards);

        updated.add(newCard);

        emit(state.copyWith(
          isAdding: false,
          addSuccess: true,
          cards: _sorted(updated),
        ));
      },
    );
  }

  Future<void> _onRemove(
    RemovePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    final updated = state.cards
        .where((c) => c.id != event.cardId)
        .toList();

    emit(state.copyWith(cards: _sorted(updated)));
  }

  Future<void> _onSetPrimary(
    SetPrimaryPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    final updated = state.cards
        .map((c) => c.copyWith(isPrimary: c.id == event.cardId))
        .toList();

    emit(state.copyWith(cards: _sorted(updated)));
  }

  void _onClearStatus(
    ClearPaymentStatus event,
    Emitter<PaymentMethodState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}