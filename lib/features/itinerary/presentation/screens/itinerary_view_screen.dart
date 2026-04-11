import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/itinerary_bloc.dart';
import '../bloc/get_itinerary_bloc.dart';
import '../../../trip_planning/presentation/bloc/trip_planning_bloc.dart';

class ItineraryViewScreen extends StatelessWidget {
  const ItineraryViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planState = context.read<TripPlanningBloc>().state;
    final city =
        planState.destination.isEmpty ? 'New Trip' : planState.destination;

    String dateRangeText = 'Pending Dates';
    if (planState.startDate != null && planState.endDate != null) {
      final start = planState.startDate!;
      final end = planState.endDate!;
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      dateRangeText =
          '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year % 100}';
    }

    final adultsStr =
        '${planState.adults} Adult${planState.adults > 1 ? 's' : ''}';
    final kidsStr = planState.kids > 0
        ? ', ${planState.kids} Kid${planState.kids > 1 ? 's' : ''}'
        : '';
    final subtitleText = '$dateRangeText  ($adultsStr$kidsStr)';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<GetItineraryBloc, GetItineraryState>(
          builder: (context, state) {
            // ── Loading ────────────────────────────────────────────────────
            if (state is GetItineraryInitial || state is GetItineraryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Failure ────────────────────────────────────────────────────
            if (state is GetItineraryFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load itinerary',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Retry',
                        onPressed: () {
                          final bloc = context.read<GetItineraryBloc>();
                          context.read<GetItineraryBloc>().add(
                                FetchItineraryRequested(bloc.lastRequestedId),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── Success ────────────────────────────────────────────────────
            if (state is GetItinerarySuccess) {
              final itinerary = state.itinerary;
              final totalDays = itinerary.days.length;
              final selectedDay = state.selectedDay;

              // Find the activities for the currently selected day
              final dayData = itinerary.days.firstWhere(
                (d) => d.dayNumber == selectedDay,
                orElse: () => itinerary.days.first,
              );

              // Compute the date for the selected day
              String selectedDayDateText = '';
              if (planState.startDate != null) {
                final dayDate =
                    planState.startDate!.add(Duration(days: selectedDay - 1));
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                selectedDayDateText =
                    '${dayDate.day} ${months[dayDate.month - 1]} ${dayDate.year % 100}';
              } else {
                selectedDayDateText = 'Day $selectedDay';
              }

              return Column(
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
                                      child: const Icon(Icons.chevron_left,
                                          size: 28, color: AppColors.textDark),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Itinerary for $city',
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
                                    subtitleText,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.primaryPink),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Day Tabs
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: totalDays <= 3
                                ? Row(
                                    children: List.generate(totalDays, (index) {
                                      final day =
                                          itinerary.days[index].dayNumber;
                                      final isSelected = selectedDay == day;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            context
                                                .read<GetItineraryBloc>()
                                                .add(ChangeItineraryDay(day));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: isSelected
                                                      ? AppColors.primaryPink
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Day $day',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? AppColors.textDark
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundGrey,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.cardBorder),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: selectedDay,
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: AppColors.textMuted,
                                            size: 24),
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                        onChanged: (int? newValue) {
                                          if (newValue != null) {
                                            context
                                                .read<GetItineraryBloc>()
                                                .add(ChangeItineraryDay(
                                                    newValue));
                                          }
                                        },
                                        items: itinerary.days.map((d) {
                                          return DropdownMenuItem<int>(
                                            value: d.dayNumber,
                                            child: Text(
                                                'Day ${d.dayNumber} Itinerary'),
                                          );
                                        }).toList(),
                                      ),
                                    ),
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
                                CustomPaint(
                                  size: const Size(double.infinity, 200),
                                  painter: _RoutePainter(),
                                ),
                                // Open in Maps
                                Positioned(
                                  top: 12,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Open in Maps',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.map,
                                            size: 16,
                                            color: AppColors.successGreen),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.primaryPink
                                                .withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.bolt,
                                              size: 16,
                                              color: AppColors.primaryPink),
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

                          // Date header for selected day
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDayDateText,
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
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),

                          // Activities timeline
                          ...dayData.activities.map((activity) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Timeline icon
                                      Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  activity.activityTime,
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
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.textMuted),
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
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: PrimaryButton(
                      text: 'Save and Proceed',
                      onPressed: () {
                        final int calculatedDays = itinerary.days.length;
                        final newItinerary = Trips(
                          id: itinerary.id,
                          city: city,
                          imageUrl:
                              'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
                          startDate: planState.startDate != null
                              ? planState.startDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first
                              : '',
                          endDate: planState.endDate != null
                              ? planState.endDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first
                              : '',
                          placesCount: planState.selectedPlaces.isNotEmpty
                              ? planState.selectedPlaces.length
                              : 5,
                          days: calculatedDays,
                          adults: planState.adults,
                          kids: planState.kids,
                        );
                        context
                            .read<ItineraryBloc>()
                            .add(AddItinerary(newItinerary));
                        context.push('/packing-list');
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
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
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'map':
        return Icons.map_outlined;
      case 'hotel':
        return Icons.hotel;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'camera':
        return Icons.camera_alt_outlined;
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

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
