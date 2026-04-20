import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/core/widgets/title_case.dart';
import 'package:shrine_tours/features/packing/presentation/screens/checking_packing_screen.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../itinerary/presentation/bloc/itinerary_bloc.dart';
import '../bloc/trip_planning_bloc.dart';
import '../bloc/weather/weather_bloc.dart';
import '../../../../core/di/injection.dart';

import '../../../itinerary/presentation/bloc/get_itinerary_bloc.dart';
import '../../../itinerary/data/model/itinerary_model.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trips? trip;
  const TripDetailsScreen({super.key, this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _selectedTab = 0;
  final _tabs = ['Overview', 'Discover', 'My Items'];
  late TripPlanningBloc _tripPlanningBloc;

  @override
  void initState() {
    super.initState();
    _tripPlanningBloc = context.read<TripPlanningBloc>();

    // Fetch full trip details if we have a trip ID
    final tripId = widget.trip?.id;
    if (tripId != null) {
      _tripPlanningBloc.add(FetchTripById(tripId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, itineraryState) {
        // Use either the passed trip or the one from the bloc
        final trip = widget.trip ?? itineraryState.selectedTrip;

        if (trip == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<WeatherBloc>()
                ..add(FetchWeather(city: trip.city, date: trip.startDate)),
            ),
            BlocProvider(
              create: (context) => getIt<GetItineraryBloc>(),
            ),
          ],
          child: BlocConsumer<TripPlanningBloc, TripPlanningState>(
            listener: (context, state) {
              if (state.selectedTripDetails != null &&
                  state.selectedTripDetails!.itineraryId.isNotEmpty) {
                // Debug: log full trip details API response to verify starting_point
                debugPrint('=== TripDetailsScreen: getTripById response ===');
                debugPrint('  ID         : ${state.selectedTripDetails!.id}');
                debugPrint('  City       : ${state.selectedTripDetails!.city}');
                debugPrint(
                    '  StartingPt : ${state.selectedTripDetails!.startingPoint?.name ?? "NULL"}');
                debugPrint(
                    '  SP ID      : ${state.selectedTripDetails!.startingPoint?.id ?? "NULL"}');
                debugPrint(
                    '  SP LatLng  : ${state.selectedTripDetails!.startingPoint?.latitude}, ${state.selectedTripDetails!.startingPoint?.longitude}');
                debugPrint('===============================================');

                context.read<GetItineraryBloc>().add(FetchItineraryRequested(
                    state.selectedTripDetails!.itineraryId));
              }

              if (state.creationErrorMessage != null &&
                  state.isLoadingDetails == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.creationErrorMessage!)),
                );
              }
            },
            builder: (context, planningState) {
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
                    TitleCase.toTitleCase(trip.city),
                    style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  centerTitle: false,
                ),
                body: planningState.isLoadingDetails
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryPink))
                    : Column(
                        children: [
                          // Custom Tab Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: List.generate(_tabs.length, (index) {
                                  final isSelected = _selectedTab == index;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedTab = index),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 4)
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _tabs[index],
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // Content Area
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                  horizontal: _selectedTab == 2 ? 0 : 24),
                              child: _buildTabContent(_selectedTab, trip,
                                  itineraryState, planningState),
                            ),
                          ),

                          if (_selectedTab == 1)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: PrimaryButton(
                                text: 'Proceed',
                                onPressed: () {
                                  final itineraryId =
                                      planningState.createdTrip?.itineraryId ??
                                          planningState.selectedTripDetails
                                              ?.itineraryId ??
                                          trip.itineraryId;
                                  final startPt = planningState
                                      .selectedTripDetails?.startingPoint;
                                  context.push('/itinerary-map',
                                      extra: itineraryId.isNotEmpty
                                          ? ItineraryMapExtra(
                                              itineraryId: itineraryId,
                                              startLat: startPt?.latitude,
                                              startLng: startPt?.longitude,
                                              startName: startPt?.name,
                                            )
                                          : null);
                                },
                              ),
                            ),
                        ],
                      ),
                floatingActionButton: _selectedTab == 1
                    ? FloatingActionButton(
                        backgroundColor: AppColors.primaryPink,
                        elevation: 4,
                        shape: const CircleBorder(),
                        onPressed: () => context.push('/add-places'),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 28),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabContent(int tabIndex, Trips trip, ItineraryState state,
      TripPlanningState planningState) {
    if (tabIndex == 0) {
      // Overview Tab (existing logic...)
      final startDateStr = _formatDate(trip.startDate);
      final endDateStr = _formatDate(trip.endDate);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _dateCard(
                      'Start', _getDayOfWeek(trip.startDate), startDateStr)),
              const SizedBox(width: 16),
              Expanded(
                  child: _dateCard(
                      'End', _getDayOfWeek(trip.endDate), endDateStr)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Duration',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.days} days',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Travel included',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Weather Forecast
          Text(
            'Weather Forecast',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child:
                        CircularProgressIndicator(color: AppColors.primaryPink),
                  ),
                );
              } else if (state is WeatherError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
                  ),
                );
              } else if (state is WeatherLoaded) {
                final weather = state.weather;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _weatherRow(
                          Icons.thermostat_outlined,
                          'Temperature',
                          '${weather.maxTemp.round()}°C / ${weather.minTemp.round()}°C',
                          AppColors.primaryPink),
                      const SizedBox(height: 16),
                      _weatherRow(
                          Icons.water_drop_outlined,
                          'Precipitation',
                          '${weather.precipitationChance}%',
                          AppColors.primaryPink),
                      const SizedBox(height: 16),
                      _weatherRow(Icons.air, 'Wind', weather.wind,
                          AppColors.primaryPink),
                      const SizedBox(height: 16),
                      _weatherRow(Icons.opacity, 'Humidity',
                          '${weather.humidity}%', AppColors.primaryPink),
                      const SizedBox(height: 12),
                      // const Divider(),
                      // const SizedBox(height: 8),
                      // Text(
                      //   weather.summary,
                      //   style: GoogleFonts.inter(
                      //     fontSize: 13,
                      //     color: AppColors.textMuted,
                      //     fontStyle: FontStyle.italic,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Since we already fetched details in initState, we just need to ensure
                // the editingTripId is set (which happens in the Bloc's FetchTripById handler)
                context.push('/plan-trip');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Modify Itinerary Plan',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPink),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else if (tabIndex == 1) {
      // Discover Tab
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top 5 Places to Visit',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  final itineraryId =
                      planningState.createdTrip?.itineraryId ??
                          planningState.selectedTripDetails?.itineraryId ??
                          trip.itineraryId;

                  if (itineraryId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Itinerary not available yet. Please wait.')),
                    );
                    return;
                  }
                  final startPt =
                      planningState.selectedTripDetails?.startingPoint;
                  context.push('/itinerary-map',
                      extra: ItineraryMapExtra(
                        itineraryId: itineraryId,
                        startLat: startPt?.latitude,
                        startLng: startPt?.longitude,
                        startName: startPt?.name,
                      ));
                },
                icon: const Icon(Icons.map_outlined,
                    size: 16, color: AppColors.primaryPink),
                label: Text(
                  'Map View',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  side:
                      BorderSide(color: AppColors.primaryPink.withOpacity(0.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<GetItineraryBloc, GetItineraryState>(
            builder: (context, state) {
              if (state is GetItineraryLoading) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryPink),
                ));
              }

              if (state is GetItinerarySuccess) {
                // Flatten activities across all days
                final allActivities = state.itinerary.days
                    .expand((day) => day.activities
                        .map((act) => MapEntry(day.dayNumber, act)))
                    .toList();

                final activitiesToShow = allActivities.take(5).toList();

                return Column(
                  children: activitiesToShow.map((entry) {
                    final dayNum = entry.key;
                    final activity = entry.value;

                    return _buildActivityCard(activity, dayNum);
                  }).toList(),
                );
              }

              if (state is GetItineraryFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Failed to load recommendations',
                      style: GoogleFonts.inter(color: AppColors.textMuted),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      );
    } else {
      return CheckingPackingScreen(tripId: trip.id, isFromTabs: true);
    }
  }

  Widget _buildActivityCard(ItineraryActivityModel activity, int dayNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getActivityDesignIcon(activity.icon),
                  color: AppColors.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPinkSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day $dayNumber',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 40),
              Icon(Icons.access_time_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '${activity.activityTime} • ${activity.duration}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Padding(
          //   padding: const EdgeInsets.only(left: 40),
          //   child: Text(
          //     (activity.description?.isNotEmpty == true)
          //       ? activity.description!
          //       : 'Enjoy a beautiful visit to this popular spot known for its stunning architecture and cultural significance.',
          //     style: GoogleFonts.inter(
          //       fontSize: 14,
          //       color: AppColors.textDark.withOpacity(0.8),
          //       height: 1.5,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  IconData _getActivityDesignIcon(String icon) {
    switch (icon) {
      case 'temple':
        return Icons.temple_hindu_outlined;
      case 'activity':
        return Icons.history_edu_outlined;
      case 'explore':
        return Icons.explore_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _dateCard(String label, String dayName, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style:
                    GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weatherRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthAbbrev(date.month)} ${date.year.toString().substring(2)}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthAbbrev(int month) {
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
    return months[month - 1];
  }

  String _getDayOfWeek(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return days[date.weekday - 1];
    } catch (e) {
      return 'Unknown';
    }
  }
}
