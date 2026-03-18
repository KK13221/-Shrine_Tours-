import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/trip_card.dart';
import '../bloc/itinerary_bloc.dart';

class MyItinerariesScreen extends StatefulWidget {
  const MyItinerariesScreen({super.key});

  @override
  State<MyItinerariesScreen> createState() => _MyItinerariesScreenState();
}

class _MyItinerariesScreenState extends State<MyItinerariesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ItineraryBloc>().add(LoadItineraries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ItineraryBloc, ItineraryState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Itineraries',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.itineraries.length} trips saved',
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      // Avatar
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'JD',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Trip list
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                        : ListView.builder(
                            itemCount: state.itineraries.length,
                            itemBuilder: (context, index) {
                              final trip = state.itineraries[index];
                              return TripCard(
                                cityName: trip.city,
                                imageUrl: trip.imageUrl,
                                dateRange: trip.dateRange,
                                places: trip.places,
                                days: trip.days,
                                onTap: () {
                                  context.read<ItineraryBloc>().add(SelectItinerary(trip.id));
                                  context.push('/trip-details');
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plan-trip'),
        backgroundColor: AppColors.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
