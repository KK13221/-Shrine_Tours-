import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 24),
            _section(
              '1. Acceptance of Terms',
              'By accessing and using this mobile travel itinerary application, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _section(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the materials on Travel App for personal, non-commercial transitory viewing only.',
            ),
            _section(
              '3. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _section(
              '4. Subscription & Billing',
              'Subscriptions are billed in advance on a recurring basis. You can cancel your subscription at any time through your account settings.',
            ),
            _section(
              '5. Privacy Policy',
              'Your use of our app is also governed by our Privacy Policy. We collect and use information in accordance with applicable data protection laws.',
            ),
            _section(
              '6. Modifications',
              'We reserve the right to modify these terms at any time. We will notify you of any material changes through the app or by email.',
            ),
            _section(
              '7. Limitation of Liability',
              'In no event shall ShrineTours be liable for any damages arising from the use of our application or services. The app is provided as-is without warranties of any kind.',
            ),
            _section(
              '8. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the company is established.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark, height: 1.6),
          ),
        ],
      ),
    );
  }
}
