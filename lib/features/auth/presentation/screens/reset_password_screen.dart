import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/forget_password_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    context.read<ForgetPasswordBloc>().add(
          ForgetPasswordResetSubmitted(
            email: widget.email,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<ForgetPasswordBloc, ForgetPasswordState>(
          listenWhen: (_, current) =>
              current is ForgetPasswordResetSuccess ||
              current is ForgetPasswordFailure,
          listener: (_, state) {
            if (state is ForgetPasswordResetSuccess) {
              // Use GoRouter.of(context) — GoRouter holds its own
              // InheritedWidget separately from Scaffold, stays valid
              // longer during navigation transitions.
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                );
              GoRouter.of(context).go('/sign-in');
            } else if (state is ForgetPasswordFailure) {
              // Failure — screen is still mounted, safe.
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
                  Text('Create new password',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    'Your new password must be unique from those previously used.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'New Password',
                    hint: 'new password',
                    prefixIcon: Icons.lock_outline,
                    controller: _newPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'confirm password',
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Reset Password',
                    isLoading: state is ForgetPasswordLoading,
                    onPressed: _resetPassword,
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