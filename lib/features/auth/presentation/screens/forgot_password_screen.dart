// ═══════════════════════════════════════════════════════════════════
// FORGOT PASSWORD SCREEN
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/forget_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // Safe — widget is still mounted when user taps button
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    context.read<ForgetPasswordBloc>().add(
          ForgetPasswordEmailSubmitted(email: email),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<ForgetPasswordBloc, ForgetPasswordState>(
          listenWhen: (_, current) =>
              current is ForgetPasswordEmailSuccess ||
              current is ForgetPasswordFailure,
          listener: (_, state) {
            // ── RULE: zero context calls here. ─────────────────────────
            // The listener fires as a microtask — by then this screen
            // may already be deactivated. Use the router singleton and
            // avoid ScaffoldMessenger entirely in async listeners.
            if (state is ForgetPasswordEmailSuccess) {
              // Navigate only — no snackbar here.
              // The OTP screen itself makes clear the code was sent.

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Otp Sent Succesfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                );

              GoRouter.of(context).pushNamed(
                'otpVerification',
                extra: OtpRouteExtra(
                  email: _emailController.text.trim(),
                  bloc: context.read<ForgetPasswordBloc>(),
                ),
              );
            } else if (state is ForgetPasswordFailure) {
              // Error means we stay on this screen — widget IS still
              // mounted and active, so context is safe here.
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.chevron_left, size: 28,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 24),
                  Text('Forgot Password',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address to receive a password reset link.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Email',
                    hint: 'your@email.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Send Reset Link',
                    isLoading: state is ForgetPasswordLoading,
                    onPressed: _handleReset,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}