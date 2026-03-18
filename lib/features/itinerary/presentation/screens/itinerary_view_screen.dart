import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/itinerary_bloc.dart';

class ItineraryViewScreen extends StatelessWidget {
  const ItineraryViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
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
                                    'Itinerary for Bhopal',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
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
                                  '23 Oct - 26 Oct 25  (2 Adults, 1 Kid)',
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryPink),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Day Tabs
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: List.generate(3, (index) {
                              final day = index + 1;
                              final isSelected = state.selectedDay == day;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => context.read<ItineraryBloc>().add(ChangeDay(day)),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isSelected ? AppColors.primaryPink : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Day $day',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? AppColors.textDark : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Map placeholder
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Route dots
                              CustomPaint(
                                size: const Size(double.infinity, 200),
                                painter: _RoutePainter(),
                              ),
                              // Open in Maps
                              Positioned(
                                top: 12,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Open in Maps',
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.map, size: 16, color: AppColors.successGreen),
                                    ],
                                  ),
                                ),
                              ),
                              // Re-optimize Route
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bolt, size: 16, color: AppColors.primaryPink),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Re-optimize Route',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date header
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '24 Oct 25',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryPink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ),

                        // Activities timeline
                        ...state.activities.map((activity) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Timeline icon
                                    Column(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundGrey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getActivityIcon(activity.icon),
                                            size: 20,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: AppColors.cardBorder,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                activity.time,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '₹ ${activity.cost.toInt()}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            activity.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            activity.duration,
                                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
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
                    text: 'Save and Proceed',
                    onPressed: () => context.push('/packing-list'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String icon) {
    switch (icon) {
      case 'car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'temple':
        return Icons.temple_hindu;
      case 'water':
        return Icons.water;
      default:
        return Icons.explore;
    }
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.45, size.height * 0.45),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.8),
    ];

    // Draw dotted lines
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
