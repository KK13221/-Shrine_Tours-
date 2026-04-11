import 'package:equatable/equatable.dart';

class PackingListResponseModel extends Equatable {
  final String tripId;
  final List<String> selectedTransports;
  final List<PackingCategoryModel> categories;

  const PackingListResponseModel({
    required this.tripId,
    required this.selectedTransports,
    required this.categories,
  });

  factory PackingListResponseModel.fromJson(Map<String, dynamic> json) {
    return PackingListResponseModel(
      tripId: json['tripId'] ?? '',
      selectedTransports: List<String>.from(json['selectedTransports'] ?? []),
      categories: (json['categories'] as List? ?? [])
          .map((c) => PackingCategoryModel.fromJson(c))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tripId, selectedTransports, categories];
}

class PackingCategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final bool isChecked;
  final List<PackingItemModel> items;
  final bool isExpanded;

  const PackingCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isChecked,
    required this.items,
    this.isExpanded = false,
  });

  int get checkedCount => items.where((i) => i.isChecked).length;

  PackingCategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isChecked,
    List<PackingItemModel>? items,
    bool? isExpanded,
  }) {
    return PackingCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isChecked: isChecked ?? this.isChecked,
      items: items ?? this.items,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  factory PackingCategoryModel.fromJson(Map<String, dynamic> json) {
    return PackingCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      isChecked: json['checked'] ?? false,
      items: (json['items'] as List? ?? [])
          .map((i) => PackingItemModel.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, icon, isChecked, items, isExpanded];
}

class PackingItemModel extends Equatable {
  final String id;
  final String name;
  final bool isChecked;
  final int quantity;

  const PackingItemModel({
    required this.id,
    required this.name,
    required this.isChecked,
    required this.quantity,
  });

  PackingItemModel copyWith({
    String? id,
    String? name,
    bool? isChecked,
    int? quantity,
  }) {
    return PackingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      quantity: quantity ?? this.quantity,
    );
  }

  factory PackingItemModel.fromJson(Map<String, dynamic> json) {
    return PackingItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isChecked: json['checked'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, name, isChecked, quantity];
}
