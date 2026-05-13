import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../../../payment/service/razorpay_service.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/repositories/token_storage_repo.dart';
import '../bloc/profile_bloc.dart';

class UpgradePlanScreen extends StatefulWidget {
  const UpgradePlanScreen({super.key});

  @override
  State<UpgradePlanScreen> createState() => _UpgradePlanScreenState();
}

class _UpgradePlanScreenState extends State<UpgradePlanScreen> {
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadSubscription());
    context.read<ProfileBloc>().add(LoadProfile());

    _razorpayService.init(
      onSuccess: (response) {
        if (response.orderId != null &&
            response.paymentId != null &&
            response.signature != null) {
          context.read<PaymentBloc>().add(VerifyPaymentEvent(
                razorpayOrderId: response.orderId!,
                razorpayPaymentId: response.paymentId!,
                razorpaySignature: response.signature!,
              ));
        }
      },
      onError: (response) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Failed: ${response.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      onWallet: (response) {
        // Handle external wallet if required
      },
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  static const _features = [
    'Unlimited trips & itineraries',
    'AI-powered optimization',
    'Priority customer support',
    'Offline access',
    'Advanced analytics',
    'Team collaboration (up to 5 users)',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isPremium = state.profile.premium;
        final sub = state.subscription;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left,
                  size: 28, color: AppColors.textDark),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Upgrade Plan',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textDark),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          body: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, paymentState) {
              if (paymentState is PaymentOrderCreatedSuccess) {
                final orderData = paymentState.response.data;
                if (orderData != null) {
                  debugPrint(
                      'Razorpay Amount (Paise): ${(orderData.amount * 100).toInt()}');
                  _razorpayService.openCheckout(
                    key: ApiConstants.razorpayKeyId,
                    amount: (orderData.amount * 100).toInt(),
                    orderId: orderData.razorpayOrderId,
                    name: 'Shrine Tours',
                    email: state.profile.email,
                    contact: getIt<TokenStorageRepo>().userPhone ?? '',
                  );
                }
              } else if (paymentState is PaymentVerifiedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment Successful! Plan Upgraded.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                );
                context.read<ProfileBloc>().add(LoadSubscription());
              } else if (paymentState is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${paymentState.message}')),
                );
              }
            },
            child: Stack(
              children: [
                if (state.isLoading && sub == null)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPink))
                else
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Plan Status Summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Plan',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub != null && sub.plan.isNotEmpty
                                    ? '${sub.displayName} - ${sub.priceLabel}${sub.billingCycle}'
                                    : 'Free Plan - INR 0.00',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark),
                              ),
                              if (sub != null && sub.renewsAt.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${sub.status.toUpperCase()} • Renews on ${sub.renewsAt}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.primaryPink),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Free Plan Card
                        _PlanCard(
                          title: 'Free',
                          subtitle: 'Basic access',
                          price: 'INR 0.00',
                          cycle: '/month',
                          isPopular: false,
                          isActive: !isPremium,
                          features: const [
                            // 'Create up to 2 Trips',
                            // 'Unlimited manual modifications',
                            // 'AI Optimization (1 time limit)',
                            // 'Basic map routes',
                            "Create up to 2 Trips",
                            "You can freely edit your itinerary yourself",
                            "Manual suggests: no AI involved\njust user-driven changes",
                            "Slight hidden message: you're doing the work.",
                            'AI Optimization (1 time limit)',
                          ],
                          onPressed: () {}, // No action needed for free
                        ),
                        const SizedBox(height: 24),

                        // Premium Plan Card
                        _PlanCard(
                          title: 'Premium',
                          subtitle: 'For enthusiasts',
                          price: 'INR 149',
                          cycle: '/month',
                          isPopular: true,
                          isActive: isPremium,
                          features: const [
                            'Unlimited edits on all itineraries',
                            'You can edit as much as you want\napplies to all trips',
                            "Combinedh with AI feature above\nimplies AI + Manual Both",
                            'Help & Chat support.'
                          ],
                          onPressed: () {
                            context.read<PaymentBloc>().add(
                                const CreatePaymentOrderEvent('Premium_plan'));
                          },
                        ),
                        const SizedBox(height: 24),

                        // // Enterprise Plan Card
                        // _PlanCard(
                        //   title: 'Enterprise',
                        //   subtitle: 'For power users',
                        //   price: '\$19.99',
                        //   cycle: '/month',
                        //   isPopular: true,
                        //   isActive: currentPlanLower == 'enterprise',
                        //   renewDate: sub?.renewsAt,
                        //   features: _features,
                        //   onPressed: () {
                        //     context.read<PaymentBloc>().add(
                        //         const CreatePaymentOrderEvent(
                        //             'Enterprise_plan'));
                        //   },
                        // ),
                        // const SizedBox(height: 24),

                        // // Lifetime Plan Card
                        // _PlanCard(
                        //   title: 'Lifetime',
                        //   subtitle: 'One-time payment',
                        //   price: '\$99.99',
                        //   cycle: 'forever',
                        //   isPopular: false,
                        //   isActive: currentPlanLower == 'lifetime',
                        //   features: const [
                        //     'Everything in Enterprise',
                        //     'No recurring fees',
                        //     'Early access to new features',
                        //   ],
                        //   onPressed: () {
                        //     context.read<PaymentBloc>().add(
                        //         const CreatePaymentOrderEvent('Lifetime_plan'));
                        //   },
                        // ),
                      ],
                    ),
                  ),
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, paymentState) {
                    if (paymentState is PaymentLoading) {
                      return Container(
                        color: Colors.black26,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryPink),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String cycle;
  final bool isPopular;
  final bool isActive;
  final String? renewDate;
  final List<String> features;
  final VoidCallback onPressed;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.cycle,
    this.isPopular = false,
    this.isActive = false,
    this.renewDate,
    required this.features,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryPink : AppColors.cardBorder,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        const _ActiveBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (isPopular && !isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'POPULAR',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  cycle,
                  style: GoogleFonts.inter(
                      fontSize: 16, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          if (isActive && renewDate != null && renewDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Active until $renewDate',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPink),
            ),
          ],
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check,
                        color: AppColors.primaryPink, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textDark),
                    ),
                  ],
                ),
              )),
          if (!isActive) ...[
            const SizedBox(height: 16),
            title.toLowerCase() == 'lifetime'
                ? SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryPink),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(
                        'Get Lifetime Access',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPink),
                      ),
                    ),
                  )
                : (title.toLowerCase() == 'free' || isActive)
                    ? const SizedBox.shrink()
                    : PrimaryButton(
                        text: 'Upgrade to $title', onPressed: onPressed),
          ],
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primaryPink.withOpacity(0.5)),
      ),
      child: Text(
        'ACTIVE',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryPink,
        ),
      ),
    );
  }
}
