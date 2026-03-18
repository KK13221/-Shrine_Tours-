import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';

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
                        color: AppColors.primaryPink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'JD',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.profile.name,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.profile.email,
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
                _menuItem(Icons.receipt_long_outlined, 'Subscription & Bills', () {}),
                _menuItem(Icons.trending_up, 'Upgrade Subscription', () => context.push('/upgrade-plan')),
                _menuItem(Icons.emoji_events_outlined, 'User Levels', () => context.push('/user-levels')),
                _menuItem(Icons.help_outline, 'Help & Support', () => context.push('/help-support')),
                _menuItem(Icons.description_outlined, 'Terms & Conditions', () => context.push('/terms')),

                const SizedBox(height: 16),
                // Logout
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: AppColors.errorRed, size: 22),
                        const SizedBox(width: 16),
                        Text(
                          'Logout',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.errorRed),
                        ),
                      ],
                    ),
                  ),
                ),
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
