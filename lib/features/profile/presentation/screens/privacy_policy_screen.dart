import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: October 2025\n\n'
              'At Shrine Tours, we take your privacy seriously. This Privacy '
              'Policy explains how we collect, use, and protect your personal '
              'information when you use our mobile application and services.\n\n'
              '1. Information We Collect\n'
              'We collect information you provide directly to us, such as when you '
              'create an account, plan an itinerary, or contact our support team. '
              'This may include your name, email address, password, and travel '
              'preferences.\n\n'
              '2. How We Use Your Information\n'
              'We use your information to provide, maintain, and improve our '
              'services. This includes generating personalized itineraries, '
              'processing payments (if applicable), sending technical notices, '
              'and personalizing your overall travel experience.\n\n'
              '3. Data Security\n'
              'We implement appropriate security measures to protect your '
              'personal information from unauthorized access, alteration, '
              'disclosure, or destruction. We use industry-standard encryption for '
              'sensitive data.\n\n'
              '4. Changes to This Policy\n'
              'We may update our Privacy Policy from time to time. We will notify '
              'you of any significant changes by posting the new policy in the app.\n\n'
              '5. Contact Us\n'
              'If you have any questions or concerns regarding our privacy '
              'practices, please contact us at support@shrinetours.com.',
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
