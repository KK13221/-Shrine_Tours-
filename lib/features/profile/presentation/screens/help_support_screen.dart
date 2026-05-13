import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/plan_restriction_bottom_sheet.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Help & Support',
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPinkSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Need a hand?\nOur support team is ready to help.\nWe typically respond within 5 minutes.\nSupport working hours: Mon – Sat | 10 AM to 7 PM',
                style:
                    GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 24),

            // Email Support
            _supportCard(
              icon: Icons.email_outlined,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1565C0),
              title: 'Email Support',
              subtitle: '',
              isChatCard: true,
              onTap: () {
                final isPremium =
                    context.read<ProfileBloc>().state.profile.premium;
                if (!isPremium) {
                  PlanRestrictionBottomSheet.show(
                    context,
                    title: 'Premium Feature',
                    message:
                        'Email Support is a Premium feature. Upgrade now to get 24/7 priority support from our travel experts!',
                  );
                  return;
                }
                _launchEmail();
              },
            ),
            const SizedBox(height: 12),

            // Live Chat
            _supportCard(
              icon: Icons.chat_bubble_outline,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
              title: 'Live Chat',
              subtitle: '',
              isChatCard: true,
              onTap: () {
                final isPremium =
                    context.read<ProfileBloc>().state.profile.premium;
                if (!isPremium) {
                  PlanRestrictionBottomSheet.show(
                    context,
                    title: 'Premium Feature',
                    message:
                        'Live Chat support is reserved for our Premium members. Upgrade today for instant assistance!',
                  );
                  return;
                }
                openWhatsApp();
              },
            ),
            const SizedBox(height: 12),

            // FAQs
            // _supportCard(
            //   icon: Icons.help_outline,
            //   iconBgColor: const Color(0xFFF3E5F5),
            //   iconColor: const Color(0xFF7B1FA2),
            //   title: 'FAQs',
            //   subtitle: 'Find answers to common questions',
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'shrine.tours1@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Support Inquiry',
        'body': 'Hello, I need help with...',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('Could not launch email client');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> openWhatsApp() async {
    const String phoneNumber = "+919986474527"; // include country code
    const String message = "Hello, I need help with the app";

    final Uri url = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch WhatsApp");
    }
  }

  Widget _supportCard(
      {required IconData icon,
      required Color iconBgColor,
      required Color iconColor,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      required bool isChatCard}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  isChatCard
                      ? const SizedBox.shrink()
                      : Text(
                          subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
