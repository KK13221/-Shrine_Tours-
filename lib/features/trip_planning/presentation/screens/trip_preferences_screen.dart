import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/trip_planning_bloc.dart';

class TripPreferencesScreen extends StatelessWidget {
  const TripPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripPlanningBloc, TripPlanningState>(
      builder: (context, state) {
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
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Goa',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Text(
                            'Dec 5, 25 - Dec 9, 25',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Travellers
                        Text(
                          'Travellers',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 20),
                        _buildCounter(context, 'Adults', state.adults, (val) {
                          context.read<TripPlanningBloc>().add(UpdateAdults(val));
                        }),
                        const SizedBox(height: 16),
                        _buildCounter(context, 'Kids', state.kids, (val) {
                          context.read<TripPlanningBloc>().add(UpdateKids(val));
                        }),
                        const SizedBox(height: 32),

                        // Trip Style
                        Text(
                          'Trip Style',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        ..._buildTripStyles(context, state.tripStyle),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PrimaryButton(
                    text: 'Generate ✨',
                    isLoading: state.isGenerating,
                    onPressed: () {
                      context.read<TripPlanningBloc>().add(GenerateItinerary());
                      context.push('/add-places');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounter(BuildContext context, String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark),
        ),
        const SizedBox(width: 4),
        Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _counterButton(Icons.remove, () {
          if (value > 0) onChanged(value - 1);
        }),
        const SizedBox(width: 8),
        _counterButton(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20),
      ),
    );
  }

  List<Widget> _buildTripStyles(BuildContext context, String selected) {
    final styles = [
      'Budget Friendly',
      'Fast Travel',
      'Relaxed Vacation',
      'Explore Everything',
      'Food Lover',
    ];

    return styles.map((style) {
      final isSelected = selected == style;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => context.read<TripPlanningBloc>().add(UpdateTripStyle(style)),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  style,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark),
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      );
    }).toList();
  }
}
