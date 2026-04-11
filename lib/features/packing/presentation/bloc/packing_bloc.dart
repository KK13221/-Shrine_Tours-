// New BLOC with add item/category features

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/packing_model.dart';
import '../../domain/usecases/get_packing_list_usecase.dart';
import '../../domain/usecases/update_transports_usecase.dart';
import '../../domain/usecases/toggle_packing_item_usecase.dart';
import '../../domain/usecases/add_packing_category_usecase.dart';
import '../../domain/usecases/add_packing_item_usecase.dart';

// ─────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────

abstract class PackingEvent extends Equatable {
  const PackingEvent();
  @override
  List<Object?> get props => [];
}

class LoadPackingList extends PackingEvent {
  final String tripId;
  const LoadPackingList(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

class SubmitTransportsRequested extends PackingEvent {
  final String tripId;
  final List<String> transports;

  const SubmitTransportsRequested({
    required this.tripId,
    required this.transports,
  });

  @override
  List<Object?> get props => [tripId, transports];
}

class ToggleTransportMode extends PackingEvent {
  final String mode;
  const ToggleTransportMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ToggleCategory extends PackingEvent {
  final int index;
  const ToggleCategory(this.index);
  @override
  List<Object?> get props => [index];
}

class ToggleItem extends PackingEvent {
  final String tripId;
  final String itemId;
  final int categoryIndex;
  final int itemIndex;
  const ToggleItem({
    required this.tripId,
    required this.itemId,
    required this.categoryIndex,
    required this.itemIndex,
  });
  @override
  List<Object?> get props => [tripId, itemId, categoryIndex, itemIndex];
}

class UpdateItemQuantity extends PackingEvent {
  final int categoryIndex;
  final int itemIndex;
  final int quantity;
  const UpdateItemQuantity({
    required this.categoryIndex,
    required this.itemIndex,
    required this.quantity,
  });
  @override
  List<Object?> get props => [categoryIndex, itemIndex, quantity];
}

// ── NEW: Add a single item to an existing category ───────────────────────────
class AddItemToCategory extends PackingEvent {
  final String tripId;
  final String categoryId;
  final int categoryIndex;
  final String itemName;
  const AddItemToCategory({
    required this.tripId,
    required this.categoryId,
    required this.categoryIndex,
    required this.itemName,
  });
  @override
  List<Object?> get props => [tripId, categoryId, categoryIndex, itemName];
}

// ── NEW: Add a brand-new category ────────────────────────────────────────────
class AddCategory extends PackingEvent {
  final String tripId;
  final String categoryName;
  const AddCategory({required this.tripId, required this.categoryName});
  @override
  List<Object?> get props => [tripId, categoryName];
}

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

const _sentinel = Object();

class PackingState extends Equatable {
  final List<String> selectedTransports;
  final List<PackingCategoryModel> categories;
  final bool isLoading;
  final bool isSubmitting;
  final bool? submitSuccess;
  final String? errorMessage;
  final int totalItems;
  final int checkedItems;

  const PackingState({
    this.selectedTransports = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.submitSuccess,
    this.errorMessage,
    this.totalItems = 0,
    this.checkedItems = 0,
  });

  double get progress => totalItems > 0 ? checkedItems / totalItems : 0;

  PackingState copyWith({
    List<String>? selectedTransports,
    List<PackingCategoryModel>? categories,
    bool? isLoading,
    bool? isSubmitting,
    Object? submitSuccess = _sentinel,
    Object? errorMessage = _sentinel,
    int? totalItems,
    int? checkedItems,
  }) {
    return PackingState(
      selectedTransports: selectedTransports ?? this.selectedTransports,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess == _sentinel
          ? this.submitSuccess
          : (submitSuccess as bool?),
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : (errorMessage as String?),
      totalItems: totalItems ?? this.totalItems,
      checkedItems: checkedItems ?? this.checkedItems,
    );
  }

  @override
  List<Object?> get props => [
        selectedTransports,
        categories,
        isLoading,
        isSubmitting,
        submitSuccess,
        errorMessage,
        totalItems,
        checkedItems
      ];
}

// ─────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────

class PackingBloc extends Bloc<PackingEvent, PackingState> {
  final UpdateTransportsUseCase _updateTransportsUseCase;
  final GetPackingListUseCase _getPackingListUseCase;
  final TogglePackingItemUseCase _togglePackingItemUseCase;
  final AddPackingCategoryUseCase _addPackingCategoryUseCase;
  final AddPackingItemUseCase _addPackingItemUseCase;

  PackingBloc(
    this._updateTransportsUseCase,
    this._getPackingListUseCase,
    this._togglePackingItemUseCase,
    this._addPackingCategoryUseCase,
    this._addPackingItemUseCase,
  ) : super(const PackingState()) {
    on<LoadPackingList>(_onLoad);
    on<SubmitTransportsRequested>(_onSubmitTransports);
    on<ToggleTransportMode>(_onToggleTransport);
    on<ToggleCategory>(_onToggleCategory);
    on<ToggleItem>(_onToggleItem);
    on<UpdateItemQuantity>(_onUpdateQuantity);
    on<AddItemToCategory>(_onAddItem);
    on<AddCategory>(_onAddCategory);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Recounts total and checked across all categories.
  ({int total, int checked}) _recount(List<PackingCategoryModel> categories) {
    int total = 0;
    int checked = 0;
    for (final cat in categories) {
      total += cat.items.length;
      checked += cat.checkedCount;
    }
    return (total: total, checked: checked);
  }

  String _uniqueId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onSubmitTransports(
    SubmitTransportsRequested event,
    Emitter<PackingState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      submitSuccess: null,
      errorMessage: null,
    ));

    final result = await _updateTransportsUseCase(
      tripId: event.tripId,
      transports: event.transports,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      )),
    );
  }

  Future<void> _onLoad(
      LoadPackingList event, Emitter<PackingState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      submitSuccess: null,
    ));

    final result = await _getPackingListUseCase(event.tripId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (packingModel) {
        final categories = packingModel.categories;
        final count = _recount(categories);
        emit(state.copyWith(
          isLoading: false,
          selectedTransports: packingModel.selectedTransports,
          categories: categories,
          totalItems: count.total,
          checkedItems: count.checked,
          errorMessage: null,
        ));
      },
    );
  }

  void _onToggleTransport(
      ToggleTransportMode event, Emitter<PackingState> emit) {
    final transports = List<String>.from(state.selectedTransports);
    transports.contains(event.mode)
        ? transports.remove(event.mode)
        : transports.add(event.mode);
    emit(state.copyWith(selectedTransports: transports));
  }

  void _onToggleCategory(ToggleCategory event, Emitter<PackingState> emit) {
    final categories = List<PackingCategoryModel>.from(state.categories);
    categories[event.index] = categories[event.index].copyWith(
      isExpanded: !categories[event.index].isExpanded,
    );
    emit(state.copyWith(categories: categories));
  }

  Future<void> _onToggleItem(ToggleItem event, Emitter<PackingState> emit) async {
    // Optimistic UI update
    final originalCategories = state.categories;
    final categories = List<PackingCategoryModel>.from(state.categories);
    final items =
        List<PackingItemModel>.from(categories[event.categoryIndex].items);
    items[event.itemIndex] = items[event.itemIndex]
        .copyWith(isChecked: !items[event.itemIndex].isChecked);
    categories[event.categoryIndex] =
        categories[event.categoryIndex].copyWith(items: items);

    final count = _recount(categories);
    emit(state.copyWith(
      categories: categories,
      checkedItems: count.checked,
    ));

    // API call
    final updatedItem = items[event.itemIndex];
    final result = await _togglePackingItemUseCase(
      tripId: event.tripId,
      itemId: event.itemId,
      isChecked: updatedItem.isChecked,
      quantity: updatedItem.quantity,
    );

    result.fold(
      (failure) {
        // Rollback on failure
        final count = _recount(originalCategories);
        emit(state.copyWith(
          categories: originalCategories,
          checkedItems: count.checked,
          errorMessage: failure.message,
        ));
      },
      (packingModel) {
        // Update with fresh data from API
        final newCategories = packingModel.categories;
        final count = _recount(newCategories);
        emit(state.copyWith(
          categories: newCategories,
          checkedItems: count.checked,
          // Clear any previous error
          errorMessage: null,
          // We can use a special flag or just the fact that it succeeded
          submitSuccess: true, 
        ));
      },
    );
  }

  void _onUpdateQuantity(UpdateItemQuantity event, Emitter<PackingState> emit) {
    final categories = List<PackingCategoryModel>.from(state.categories);
    final items =
        List<PackingItemModel>.from(categories[event.categoryIndex].items);
    items[event.itemIndex] =
        items[event.itemIndex].copyWith(quantity: event.quantity);
    categories[event.categoryIndex] =
        categories[event.categoryIndex].copyWith(items: items);
    emit(state.copyWith(categories: categories));
  }

  Future<void> _onAddItem(
      AddItemToCategory event, Emitter<PackingState> emit) async {
    final name = event.itemName.trim();
    if (name.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _addPackingItemUseCase(
      tripId: event.tripId,
      categoryId: event.categoryId,
      name: name,
      quantity: 1, // Default quantity
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (packingModel) {
        final categories = packingModel.categories;
        final count = _recount(categories);
        emit(state.copyWith(
          isLoading: false,
          categories: categories,
          totalItems: count.total,
          checkedItems: count.checked,
          errorMessage: null,
          submitSuccess: true,
        ));
      },
    );
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<PackingState> emit) async {
    final name = event.categoryName.trim();
    if (name.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _addPackingCategoryUseCase(
      tripId: event.tripId,
      name: name,
      icon: 'inventory', // Default icon
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (packingModel) {
        final categories = packingModel.categories;
        final count = _recount(categories);
        emit(state.copyWith(
          isLoading: false,
          categories: categories,
          totalItems: count.total,
          checkedItems: count.checked,
          errorMessage: null,
          submitSuccess: true,
        ));
      },
    );
  }
}
