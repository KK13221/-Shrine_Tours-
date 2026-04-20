import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String plan;
  final String status;
  final String renewsAt;
  final List<String> features;

  const SubscriptionModel({
    required this.plan,
    required this.status,
    required this.renewsAt,
    required this.features,
  });

  static const SubscriptionModel free = SubscriptionModel(
    plan: 'free',
    status: 'inactive',
    renewsAt: '',
    features: [],
  );

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] as String? ?? 'free',
      status: json['status'] as String? ?? 'inactive',
      renewsAt: json['renewsAt'] as String? ?? '',
      features: List<String>.from(json['features'] ?? []),
    );
  }

  /// Returns the formatted price based on the plan name.
  String get priceLabel {
    final cleanPlan = plan.toLowerCase();
    if (cleanPlan.contains('premium')) return '\$9.99';
    if (cleanPlan.contains('enterprise')) return '\$19.99';
    if (cleanPlan.contains('lifetime')) return '\$99.99';
    return '\$0.00';
  }

  /// Returns the billing cycle label.
  String get billingCycle {
    if (plan.toLowerCase().contains('lifetime')) return 'forever';
    return '/month';
  }

  /// Returns a display name for the plan (capitalized).
  String get displayName => plan.substring(0, 1).toUpperCase() + plan.substring(1);

  @override
  List<Object?> get props => [plan, status, renewsAt, features];
}
