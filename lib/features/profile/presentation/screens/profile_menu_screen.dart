import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/core/di/injection.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';
import 'package:shrine_tours/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';
import 'subscription_bill_sheet.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Profile',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textDark),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // User info
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pinkAccent, // Placeholder background color
                      ),
                      child: CachedNetworkImage(
                        imageUrl: getIt<TokenStorageRepo>().userProfilePicture ?? "",
                        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        errorWidget: (context, url, error) => const Icon(Icons.person_outline, color: Colors.white, size: 28),
                        fit: BoxFit.fill,
                        height: 56,
                        width: 56,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getIt<TokenStorageRepo>().userName ?? "",
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          getIt<TokenStorageRepo>().userEmail ?? "",
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Premium Member',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryPink),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),

                // Menu items
                _menuItem(Icons.person_outline, 'Profile Settings', () => context.push('/profile-settings')),
                _menuItem(Icons.credit_card, 'Payment Methods', () => context.push('/payment-methods')),
                _menuItem(Icons.receipt_long_outlined, 'Subscription & Bills', () => SubscriptionBillsSheet.show(context)),
                _menuItem(Icons.trending_up, 'Upgrade Subscription', () => context.push('/upgrade-plan')),
                _menuItem(Icons.emoji_events_outlined, 'User Levels', () => context.push('/user-levels')),
                _menuItem(Icons.help_outline, 'Help & Support', () => context.push('/help-support')),
                _menuItem(Icons.description_outlined, 'Terms & Conditions', () => context.push('/terms')),

                const SizedBox(height: 8),
                // LogoutR
                InkWell(
                  onTap: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                    context.go('/welcome');
                  },
                  child: Container(
                    width: double.infinity, // 👈 FULL WIDTH CLICKABLE
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: AppColors.errorRed, size: 22),
                        const SizedBox(width: 16),
                        Text(
                        'Logout',
                        style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.errorRed,
                        ),
                      ),
                    ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
