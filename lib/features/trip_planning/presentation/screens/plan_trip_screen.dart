import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/trip_planning_bloc.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final _cityController = TextEditingController();
  String _selectedTraveller = '';
  String _selectedPurpose = '';
  DateTime? _startDate;
  DateTime? _endDate;

  final _travellerOptions = [
    {'label': 'Solo Traveller', 'emoji': '🧑', 'value': 'solo'},
    {'label': 'Couple', 'emoji': '💑', 'value': 'couple'},
    {'label': 'Family', 'emoji': '👨‍👩‍👧', 'value': 'family'},
    {"label": "Friend's Group", 'emoji': '👥', 'value': 'friends'},
  ];

  final _purposeOptions = [
    {'label': 'Leisure', 'emoji': '❤️', 'value': 'leisure'},
    {'label': 'Birthday', 'emoji': '🎊', 'value': 'birthday'},
    {'label': 'Bachelorette', 'emoji': '🏛️', 'value': 'bachelorette'},
  ];

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryPink),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Plan Your Trip',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us about your travel plans',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Where do you want to go?
                    Text(
                      'Where do you want to go?',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Enter city name (e.g., Bhopal)',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.backgroundGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Who's travelling?
                    Text(
                      "Who's travelling?",
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: _travellerOptions.map((option) {
                        final isSelected = _selectedTraveller == option['value'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTraveller = option['value']!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryPinkSoft : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(option['emoji']!, style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(
                                  option['label']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Purpose
                    Text(
                      "What's the purpose of travel?",
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    ..._purposeOptions.map((option) {
                      final isSelected = _selectedPurpose == option['value'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPurpose = option['value']!),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryPinkSoft : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(option['emoji']!, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Text(
                                  option['label']!,
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickDate(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted),
                                      const SizedBox(width: 8),
                                      Text(
                                        _startDate != null
                                            ? '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}'
                                            : 'mm/dd/yyyy',
                                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickDate(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted),
                                      const SizedBox(width: 8),
                                      Text(
                                        _endDate != null
                                            ? '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'
                                            : 'mm/dd/yyyy',
                                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Continue',
                onPressed: () => context.push('/trip-preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
