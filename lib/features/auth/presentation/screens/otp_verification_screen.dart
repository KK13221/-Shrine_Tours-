import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/forget_password_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _pinController.text.trim();
    if (otp.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a 6-digit OTP')),
        );
      }
      return;
    }
    context.read<ForgetPasswordBloc>().add(
          ForgetPasswordOtpSubmitted(email: widget.email, otp: otp),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<ForgetPasswordBloc, ForgetPasswordState>(
          listenWhen: (_, current) =>
              current is ForgetPasswordOtpSuccess ||
              current is ForgetPasswordEmailSuccess ||
              current is ForgetPasswordFailure,
          listener: (_, state) {
            if (state is ForgetPasswordOtpSuccess) {
              // Navigate only — no scaffold calls.
              GoRouter.of(context).pushNamed(
                'resetPassword',
                extra: ResetRouteExtra(
                  email: widget.email,
                  bloc: context.read<ForgetPasswordBloc>(),
                ),
              );
            } else if (state is ForgetPasswordEmailSuccess) {
              // Resend success — screen stays mounted, context is safe.
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP resent!')),
                );
              }
            } else if (state is ForgetPasswordFailure) {
              // Failure — screen stays mounted, context is safe.
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                  Text('OTP Verification',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the verification code we just sent to your email address.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 35,
                          fieldWidth: 35,
                          activeFillColor: Theme.of(context).colorScheme.surface,
                          inactiveFillColor: Theme.of(context).colorScheme.surface,
                          selectedFillColor: Theme.of(context).colorScheme.surface,
                          activeColor: AppColors.primaryPink,
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                          selectedColor: AppColors.primaryPink,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        controller: _pinController,
                        onCompleted: (_) => _verifyOtp(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Verify',
                    isLoading: state is ForgetPasswordLoading,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Didn't receive code? ",
                            style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7))),
                        GestureDetector(
                          onTap: () => context.read<ForgetPasswordBloc>().add(
                                ForgetPasswordEmailSubmitted(
                                    email: widget.email),
                              ),
                          child: Text('Resend',
                              style: GoogleFonts.inter(
                                  color: AppColors.primaryPink,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
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