import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/core/di/injection.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';
import 'package:shrine_tours/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/trip_card.dart';
import '../../../itinerary/presentation/bloc/itinerary_bloc.dart';
import '../bloc/trip_planning_bloc.dart';
import '../../../../core/widgets/plan_restriction_bottom_sheet.dart';

class MyItinerariesScreen extends StatefulWidget {
  const MyItinerariesScreen({super.key});

  @override
  State<MyItinerariesScreen> createState() => _MyItinerariesScreenState();
}

class _MyItinerariesScreenState extends State<MyItinerariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load user profile data when authenticated
    context.read<ProfileBloc>().add(LoadProfile());
    // Load itineraries
    context.read<ItineraryBloc>().add(LoadItineraries());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateRange(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      final startFormatted =
          '${start.day} ${_getMonthAbbrev(start.month)} ${start.year.toString().substring(2)}';
      final endFormatted =
          '${end.day} ${_getMonthAbbrev(end.month)} ${end.year.toString().substring(2)}';

      return '$startFormatted - $endFormatted';
    } catch (e) {
      return '$startDate - $endDate';
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

  Future<void> _onRefresh() async {
    context.read<ItineraryBloc>().add(LoadItineraries());
    // Wait for the loading state to complete
    await Future.delayed(const Duration(seconds: 2));
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
                            '${state.trips.length} trips saved',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textMuted),
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
                            child: CachedNetworkImage(
                              imageUrl: getIt<TokenStorageRepo>()
                                      .userProfilePicture ??
                                  "",
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                              errorWidget: (context, url, error) => const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 28),
                              fit: BoxFit.cover,
                              //height: 56,
                              //width: 56,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search your trips by city...',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                    style: GoogleFonts.inter(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),

                  // Trip list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primaryPink,
                      backgroundColor: Colors.white,
                      child: state.isLoading
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primaryPink)),
                              ),
                            )
                          : state.error != null && state.trips.isEmpty
                              ? SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Failed to load trips',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            state.error!,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: AppColors.textMuted,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Builder(builder: (context) {
                                  final filteredTrips =
                                      state.trips.where((trip) {
                                    return trip.city
                                        .toLowerCase()
                                        .contains(_searchQuery);
                                  }).toList();

                                  if (filteredTrips.isEmpty) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Center(
                                          child: Text(
                                            'No trips found',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: filteredTrips.length,
                                    itemBuilder: (context, index) {
                                      final trip = filteredTrips[index];
                                      return TripCard(
                                        cityName: trip.city,
                                        imageUrl: trip.imageUrl,
                                        dateRange: _formatDateRange(
                                            trip.startDate, trip.endDate),
                                        places: trip.placesCount,
                                        days: trip.days,
                                        onTap: () {
                                          context
                                              .read<ItineraryBloc>()
                                              .add(SelectItinerary(trip.id));
                                          context.push('/trip-details',
                                              extra: trip);
                                        },
                                      );
                                    },
                                  );
                                }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<ItineraryBloc, ItineraryState>(
        builder: (context, itineraryState) {
          return FloatingActionButton(
            onPressed: () {
              final profileState = context.read<ProfileBloc>().state;
              final isPremium = profileState.profile.premium;
              final tripCount = itineraryState.trips.length;

              final limit = isPremium ? 10 : 2;

              if (tripCount >= limit) {
                PlanRestrictionBottomSheet.show(
                  context,
                  title: 'Trip Limit Reached',
                  message: isPremium
                      ? 'You have reached the maximum limit of 10 trips for Premium users.'
                      : 'Free users can create up to 2 trips. Upgrade to Premium to create up to 10 trips and unlock full AI potential!',
                );
                return;
              }

              context.read<TripPlanningBloc>().add(ClearTripModification());
              context.push('/plan-trip');
            },
            backgroundColor: AppColors.primaryPink,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}
