import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/features/profile/data/model/payment_card_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/payment_method_bloc.dart';

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentMethodBloc>().add(LoadPaymentMethods());
  }

  void _openAddCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentMethodBloc>(),
        child: const _AddCardSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
      listener: (context, state) {
        if (state.addSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Card added successfully!',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );
          context.read<PaymentMethodBloc>().add(ClearPaymentStatus());
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!,
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );
          context.read<PaymentMethodBloc>().add(ClearPaymentStatus());
        }
      },
      builder: (context, state) {
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
              'Payment Methods',
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
                // ── Loading state ─────────────────────────────────────────
                if (state.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPink),
                    ),
                  )

                // ── Card list ──────────────────────────────────────────────
                else if (state.cards.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No payment methods added yet.',
                        style: GoogleFonts.inter(color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.cards.length,
                      itemBuilder: (_, index) =>
                          _PaymentCardWidget(card: state.cards[index]),
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Add New Card button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: (state.isLoading || state.isAdding)
                        ? null
                        : _openAddCardSheet,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryPink),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: state.isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryPink),
                          )
                        : Text(
                            '+ Add New Card',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPink,
                            ),
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
}

// ─────────────────────────────────────────────
// PAYMENT CARD WIDGET
// Primary  → dark navy gradient
// Others   → pink gradient
// ─────────────────────────────────────────────

class _PaymentCardWidget extends StatelessWidget {
  final PaymentCardModel card;

  const _PaymentCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: card.isPrimary
            ? AppColors.pinkGradient
            : const LinearGradient(
                colors: [Color(0xFF1B2A4A), Color(0xFF2D3E5E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.isPrimary ? 'Primary Card' : 'Secondary Card',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7)),
              ),
              Text(
                card.type,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '••••  ••••  ••••  ${card.lastFour}',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardDetail(label: 'Card Holder', value: card.holderName),
              _CardDetail(
                  label: 'Expires',
                  value: card.expiry,
                  crossAxisAlignment: CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardDetail extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _CardDetail({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ADD CARD BOTTOM SHEET
// Theme-aware. On confirm → dispatches AddPaymentMethod.
// ─────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedType = 'VISA';
  bool _setAsPrimary = false;

  static const _cardTypes = ['VISA', 'MC', 'AMEX', 'RuPay'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<PaymentMethodBloc>().add(AddPaymentMethod(
          type: _selectedType,
          cardNumber: _cardNumberController.text,
          holderName: _holderController.text,
          expiry: _expiryController.text,
          setAsPrimary: _setAsPrimary,
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final labelColor = isDark ? Colors.white70 : AppColors.textMuted;
    final inputFillColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F8F8);
    final inputTextColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final handleColor = isDark ? Colors.white24 : const Color(0xFFDDDDDD);
    final titleColor = isDark ? Colors.white : AppColors.textDark;
    final chipUnselectedBg =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F3F3);
    final chipUnselectedText = isDark ? Colors.white60 : AppColors.textMuted;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),

                  Text('Add New Card',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: titleColor)),
                  const SizedBox(height: 20),

                  // ── Card type chips ─────────────────────────────────────
                  Text('Card Type',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: labelColor)),
                  const SizedBox(height: 10),
                  Row(
                    children: _cardTypes.map((type) {
                      final selected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryPink
                                  : chipUnselectedBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(type,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : chipUnselectedText)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Card Number ─────────────────────────────────────────
                  _SheetField(
                    label: 'Card Number',
                    controller: _cardNumberController,
                    hintText: '1234 5678 9012 3456',
                    labelColor: labelColor,
                    fillColor: inputFillColor,
                    textColor: inputTextColor,
                    borderColor: borderColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberFormatter(),
                    ],
                    maxLength: 19,
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(' ', '');
                      if (digits.length < 16) {
                        return 'Enter a valid 16-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Card Holder ─────────────────────────────────────────
                  _SheetField(
                    label: 'Card Holder Name',
                    controller: _holderController,
                    hintText: 'JOHN DOE',
                    labelColor: labelColor,
                    fillColor: inputFillColor,
                    textColor: inputTextColor,
                    borderColor: borderColor,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Enter card holder name' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Expiry + CVV ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SheetField(
                          label: 'Expiry Date',
                          controller: _expiryController,
                          hintText: 'MM/YY',
                          labelColor: labelColor,
                          fillColor: inputFillColor,
                          textColor: inputTextColor,
                          borderColor: borderColor,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpiryFormatter(),
                          ],
                          maxLength: 5,
                          validator: (v) {
                            final clean = (v ?? '').replaceAll('/', '');
                            if (clean.length < 4) return 'MM/YY format';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SheetField(
                          label: 'CVV',
                          controller: _cvvController,
                          hintText: '•••',
                          labelColor: labelColor,
                          fillColor: inputFillColor,
                          textColor: inputTextColor,
                          borderColor: borderColor,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 4,
                          validator: (v) {
                            if ((v ?? '').length < 3) return 'Invalid CVV';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Set as primary checkbox ─────────────────────────────
                  GestureDetector(
                    onTap: () =>
                        setState(() => _setAsPrimary = !_setAsPrimary),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _setAsPrimary
                                ? AppColors.primaryPink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _setAsPrimary
                                  ? AppColors.primaryPink
                                  : borderColor,
                              width: 2,
                            ),
                          ),
                          child: _setAsPrimary
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text('Set as primary card',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: titleColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Confirm ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: Text('Add Card',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE SHEET FIELD
// ─────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final Color labelColor;
  final Color fillColor;
  final Color textColor;
  final Color borderColor;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.labelColor,
    required this.fillColor,
    required this.textColor,
    required this.borderColor,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: labelColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                GoogleFonts.inter(fontSize: 15, color: labelColor),
            filled: true,
            fillColor: fillColor,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primaryPink, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// INPUT FORMATTERS
// ─────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip spaces and cap at 16 digits
    final digits = newValue.text.replaceAll(' ', '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' '); // single space
      buffer.write(capped[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}