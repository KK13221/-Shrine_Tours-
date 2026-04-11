import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/trip_planning_bloc.dart';
import '../bloc/weather/weather_bloc.dart';
import '../../../../core/di/injection.dart';
import 'package:intl/intl.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripPlanningBloc, TripPlanningState>(
      builder: (context, state) {
        final destination =
            state.destination.isNotEmpty ? state.destination : 'Location';
        final startDate = state.startDate;
        final endDate = state.endDate;

        if (startDate == null || endDate == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final durationDays = endDate.difference(startDate).inDays + 1;

        return BlocProvider(
          create: (context) => getIt<WeatherBloc>()
            ..add(FetchWeather(
              city: destination,
              date: DateFormat('yyyy-MM-dd').format(startDate),
            )),
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
                destination,
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              centerTitle: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Summary',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _dateCard('Start', startDate)),
                        const SizedBox(width: 16),
                        Expanded(child: _dateCard('End', endDate)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Duration',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
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
                            '$durationDays days',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text('Travel included',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Weather Forecast',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    BlocBuilder<WeatherBloc, WeatherState>(
                      builder: (context, weatherState) {
                        if (weatherState is WeatherLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryPink),
                            ),
                          );
                        } else if (weatherState is WeatherError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                weatherState.message,
                                style: GoogleFonts.inter(
                                    color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else if (weatherState is WeatherLoaded) {
                          final weather = weatherState.weather;
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
                                _weatherRow(
                                    Icons.opacity,
                                    'Humidity',
                                    '${weather.humidity}%',
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
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: PrimaryButton(
                text: 'Proceed',
                onPressed: () => context.push('/trip-preferences'),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$month/$day/$year';
  }

  Widget _dateCard(String label, DateTime date) {
    final dayName = _weekdayName(date.weekday);
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
              Text(dayName,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                _formatFullDate(date),
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  Widget _weatherRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }
}
