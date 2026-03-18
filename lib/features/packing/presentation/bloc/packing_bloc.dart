import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
class PackingCategory {
  final String name;
  final String icon;
  final List<PackingItem> items;
  final bool isExpanded;

  const PackingCategory({
    required this.name,
    required this.icon,
    required this.items,
    this.isExpanded = false,
  });

  int get checkedCount => items.where((i) => i.isChecked).length;
  PackingCategory copyWith({bool? isExpanded, List<PackingItem>? items}) {
    return PackingCategory(
      name: name,
      icon: icon,
      items: items ?? this.items,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class PackingItem {
  final String id;
  final String name;
  final bool isChecked;
  final int quantity;

  const PackingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
    this.quantity = 1,
  });

  PackingItem copyWith({bool? isChecked, int? quantity}) {
    return PackingItem(id: id, name: name, isChecked: isChecked ?? this.isChecked, quantity: quantity ?? this.quantity);
  }
}

// Events
abstract class PackingEvent extends Equatable {
  const PackingEvent();
  @override
  List<Object?> get props => [];
}

class LoadPackingList extends PackingEvent {}

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
  final int categoryIndex;
  final int itemIndex;
  const ToggleItem({required this.categoryIndex, required this.itemIndex});
  @override
  List<Object?> get props => [categoryIndex, itemIndex];
}

class UpdateItemQuantity extends PackingEvent {
  final int categoryIndex;
  final int itemIndex;
  final int quantity;
  const UpdateItemQuantity({required this.categoryIndex, required this.itemIndex, required this.quantity});
  @override
  List<Object?> get props => [categoryIndex, itemIndex, quantity];
}

// States
class PackingState extends Equatable {
  final List<String> selectedTransports;
  final List<PackingCategory> categories;
  final bool isLoading;
  final int totalItems;
  final int checkedItems;

  const PackingState({
    this.selectedTransports = const [],
    this.categories = const [],
    this.isLoading = false,
    this.totalItems = 0,
    this.checkedItems = 0,
  });

  double get progress => totalItems > 0 ? checkedItems / totalItems : 0;

  PackingState copyWith({
    List<String>? selectedTransports,
    List<PackingCategory>? categories,
    bool? isLoading,
    int? totalItems,
    int? checkedItems,
  }) {
    return PackingState(
      selectedTransports: selectedTransports ?? this.selectedTransports,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      totalItems: totalItems ?? this.totalItems,
      checkedItems: checkedItems ?? this.checkedItems,
    );
  }

  @override
  List<Object?> get props => [selectedTransports, categories, isLoading, totalItems, checkedItems];
}

// BLoC
class PackingBloc extends Bloc<PackingEvent, PackingState> {
  PackingBloc() : super(const PackingState()) {
    on<LoadPackingList>(_onLoad);
    on<ToggleTransportMode>(_onToggleTransport);
    on<ToggleCategory>(_onToggleCategory);
    on<ToggleItem>(_onToggleItem);
    on<UpdateItemQuantity>(_onUpdateQuantity);
  }

  Future<void> _onLoad(LoadPackingList event, Emitter<PackingState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 300));
    final categories = [
      const PackingCategory(name: 'Essentials', icon: 'luggage', items: [
        PackingItem(id: 'e1', name: 'Passport', isChecked: true),
        PackingItem(id: 'e2', name: 'Wallet', isChecked: true),
      ]),
      const PackingCategory(name: 'Airplane', icon: 'flight', items: [
        PackingItem(id: 'a1', name: 'Boarding Pass', isChecked: true),
        PackingItem(id: 'a2', name: 'Neck Pillow', isChecked: true),
        PackingItem(id: 'a3', name: 'Earbuds', isChecked: true),
        PackingItem(id: 'a4', name: 'Eye Mask', isChecked: true),
        PackingItem(id: 'a5', name: 'Snacks', isChecked: true),
      ]),
      const PackingCategory(name: 'Bus', icon: 'directions_bus', items: [
        PackingItem(id: 'b1', name: 'Bus Ticket', isChecked: true),
        PackingItem(id: 'b2', name: 'Neck Pillow', isChecked: true),
        PackingItem(id: 'b3', name: 'Headphone', quantity: 2),
      ]),
      const PackingCategory(name: 'Hotel', icon: 'hotel', items: [
        PackingItem(id: 'h1', name: 'Toiletries'),
        PackingItem(id: 'h2', name: 'Charger'),
      ]),
      const PackingCategory(name: 'International', icon: 'public', items: [
        PackingItem(id: 'i1', name: 'Visa Documents'),
        PackingItem(id: 'i2', name: 'Travel Insurance'),
      ]),
      const PackingCategory(name: 'Personal', icon: 'person', items: [
        PackingItem(id: 'p1', name: 'Medication'),
        PackingItem(id: 'p2', name: 'Sunscreen'),
      ]),
    ];

    int total = 0;
    int checked = 0;
    for (final cat in categories) {
      total += cat.items.length;
      checked += cat.checkedCount;
    }

    emit(state.copyWith(
      isLoading: false,
      categories: categories,
      totalItems: total,
      checkedItems: checked,
    ));
  }

  void _onToggleTransport(ToggleTransportMode event, Emitter<PackingState> emit) {
    final transports = List<String>.from(state.selectedTransports);
    if (transports.contains(event.mode)) {
      transports.remove(event.mode);
    } else {
      transports.add(event.mode);
    }
    emit(state.copyWith(selectedTransports: transports));
  }

  void _onToggleCategory(ToggleCategory event, Emitter<PackingState> emit) {
    final categories = List<PackingCategory>.from(state.categories);
    categories[event.index] = categories[event.index].copyWith(
      isExpanded: !categories[event.index].isExpanded,
    );
    emit(state.copyWith(categories: categories));
  }

  void _onToggleItem(ToggleItem event, Emitter<PackingState> emit) {
    final categories = List<PackingCategory>.from(state.categories);
    final items = List<PackingItem>.from(categories[event.categoryIndex].items);
    items[event.itemIndex] = items[event.itemIndex].copyWith(
      isChecked: !items[event.itemIndex].isChecked,
    );
    categories[event.categoryIndex] = categories[event.categoryIndex].copyWith(items: items);

    int checked = 0;
    for (final cat in categories) {
      checked += cat.checkedCount;
    }
    emit(state.copyWith(categories: categories, checkedItems: checked));
  }

  void _onUpdateQuantity(UpdateItemQuantity event, Emitter<PackingState> emit) {
    final categories = List<PackingCategory>.from(state.categories);
    final items = List<PackingItem>.from(categories[event.categoryIndex].items);
    items[event.itemIndex] = items[event.itemIndex].copyWith(quantity: event.quantity);
    categories[event.categoryIndex] = categories[event.categoryIndex].copyWith(items: items);
    emit(state.copyWith(categories: categories));
  }
}
