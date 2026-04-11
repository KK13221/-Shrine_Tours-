import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/features/packing/presentation/screens/checking_packing_screen.dart';
import 'package:shrine_tours/features/trip_planning/data/model/trips.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../itinerary/presentation/bloc/itinerary_bloc.dart';
import '../bloc/trip_planning_bloc.dart';
import '../bloc/weather/weather_bloc.dart';
import '../../../../core/di/injection.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trips? trip;
  const TripDetailsScreen({super.key, this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _selectedTab = 0;
  final _tabs = ['Overview', 'Discover', 'My Items'];

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

        return BlocProvider(
          create: (context) => getIt<WeatherBloc>()
            ..add(FetchWeather(city: trip.city, date: trip.startDate)),
          child: Scaffold(
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
                trip.city,
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              centerTitle: false,
            ),
            body: Column(
              children: [
                // Custom Tab Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            onTap: () => setState(() => _selectedTab = index),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
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
                    padding: EdgeInsets.symmetric(horizontal: _selectedTab == 2 ? 0 : 24),
                    child: _buildTabContent(_selectedTab, trip, itineraryState),
                  ),
                ),

                if (_selectedTab == 1)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: PrimaryButton(
                      text: 'Proceed',
                      onPressed: () => context.push('/itinerary-view'),
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
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTabContent(int tabIndex, Trips trip, ItineraryState state) {
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
                    child: CircularProgressIndicator(color: AppColors.primaryPink),
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
                      _weatherRow(Icons.water_drop_outlined, 'Precipitation',
                          '${weather.precipitationChance}%', AppColors.primaryPink),
                      const SizedBox(height: 16),
                      _weatherRow(Icons.air, 'Wind', weather.wind,
                          AppColors.primaryPink),
                      const SizedBox(height: 16),
                      _weatherRow(Icons.opacity, 'Humidity', '${weather.humidity}%',
                          AppColors.primaryPink),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        weather.summary,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                context.read<TripPlanningBloc>().add(InitializeModification(trip));
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
                  'Top ${trip.placesCount.clamp(1, 5)} Places to Visit',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
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
          ...state.activities.take(5).map((activity) {
            final idx = state.activities.indexOf(activity);
            final dayIndex = (idx ~/ 2) + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primaryPink, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.title,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPinkSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Day $dayIndex',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Morning • ${activity.duration}',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'One of the popular places with stunning views and great architecture to explore.',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      return CheckingPackingScreen(tripId: trip.id, isFromTabs: true);
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
