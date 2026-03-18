import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/packing_bloc.dart';

class PackingListScreen extends StatelessWidget {
  const PackingListScreen({super.key});

  static const _transportModes = [
    {'label': 'Airplane', 'icon': Icons.flight},
    {'label': 'Boat', 'icon': Icons.directions_boat},
    {'label': 'Bus', 'icon': Icons.directions_bus},
    {'label': 'Car', 'icon': Icons.directions_car},
    {'label': 'Public', 'icon': Icons.train},
    {'label': 'Train', 'icon': Icons.train},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackingBloc, PackingState>(
      builder: (context, state) {
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
              'Packing List',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              // Travel / Vacation tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flight, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text('Travel', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            'Vacation',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Which way will you be\ntravelling?',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._transportModes.map((mode) {
                        final isSelected = state.selectedTransports.contains(mode['label']);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => context.read<PackingBloc>().add(
                              ToggleTransportMode(mode['label'] as String),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.textDark : AppColors.textDark,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  mode['label'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  text: 'Next',
                  onPressed: () {
                    context.read<PackingBloc>().add(LoadPackingList());
                    context.push('/checking-packing');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
