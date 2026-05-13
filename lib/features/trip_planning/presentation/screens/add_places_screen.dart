import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/add_places_bloc.dart';
import '../bloc/trip_planning_bloc.dart' as trip_planning;
import 'package:shrine_tours/features/itinerary/presentation/bloc/generate_itinerary_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AddPlacesScreen extends StatefulWidget {
  const AddPlacesScreen({super.key});

  @override
  State<AddPlacesScreen> createState() => _AddPlacesScreenState();
}

class _AddPlacesScreenState extends State<AddPlacesScreen> {
  late final String _city;
  late final String _tripId;
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    final tripPlanningState =
        context.read<trip_planning.TripPlanningBloc>().state;
    _city = tripPlanningState.createdTrip?.city ??
        tripPlanningState.selectedTripDetails?.city ??
        (tripPlanningState.destination.isNotEmpty
            ? tripPlanningState.destination
            : 'Unknown');

    _tripId = tripPlanningState.editingTripId ??
        tripPlanningState.createdTrip?.id ??
        '';

    List<String> alreadyAddedPlaceIds = [];
    if (tripPlanningState.selectedTripDetails != null) {
      alreadyAddedPlaceIds = tripPlanningState.selectedTripDetails!.places
          .map((p) => p.id)
          .toList();
    }

    context.read<AddPlacesBloc>().add(LoadPlaces(
          city: _city,
          tripId: _tripId,
          initialSelectedPlaceIds: alreadyAddedPlaceIds,
        ));
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            // Trigger search
            context.read<AddPlacesBloc>().add(
                  SearchPlacesRequested(query: result.recognizedWords),
                );
          }
        });
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<AddPlacesBloc, AddPlacesState>(
                listenWhen: (previous, current) =>
                    previous is AddPlacesLoaded &&
                    current is AddPlacesLoaded &&
                    (previous as AddPlacesLoaded).message !=
                        (current as AddPlacesLoaded).message,
                listener: (context, state) {
                  if (state is AddPlacesLoaded &&
                      state.message != null &&
                      state.message!.isNotEmpty) {
                    final isSuccess = state.message!.contains('successfully');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message!,
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: isSuccess
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  // FAILURE
                  if (state is AddPlacesFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
              BlocListener<GenerateItineraryBloc, GenerateItineraryState>(
                listener: (context, state) {
                  if (state is GenerateItinerarySuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        context.go(
                          '/itinerary-view',
                          extra: state.itinerary.id,
                        );
                      }
                    });
                  } else if (state is GenerateItineraryFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<AddPlacesBloc, AddPlacesState>(
              builder: (context, state) {
                if (state is AddPlacesLoading || state is AddPlacesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AddPlacesFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Unable to load places.',
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
                            onPressed: () => context
                                .read<AddPlacesBloc>()
                                .add(LoadPlaces(city: _city, tripId: _tripId)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is AddPlacesLoaded) {
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
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              context.go('/itineraries'),
                                          child: const Icon(Icons.chevron_left,
                                              size: 28,
                                              color: AppColors.textDark),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add Places to Visit',
                                          style: GoogleFonts.inter(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        context.read<AddPlacesBloc>().add(
                                              SearchPlacesRequested(
                                                  query: value),
                                            );
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search for a place',
                                        prefixIcon: const Icon(Icons.search,
                                            color: AppColors.textMuted),
                                        suffixIcon: _searchController
                                                .text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  context
                                                      .read<AddPlacesBloc>()
                                                      .add(
                                                        const SearchPlacesRequested(
                                                            query: ''),
                                                      );
                                                },
                                              )
                                            : IconButton(
                                                icon: Icon(
                                                  _isListening
                                                      ? Icons.graphic_eq
                                                      : Icons.mic,
                                                  color: _isListening
                                                      ? AppColors.primaryPink
                                                      : AppColors.textMuted,
                                                ),
                                                onPressed: _isListening
                                                    ? _stopListening
                                                    : _startListening,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                        filled: true,
                                        fillColor: AppColors.backgroundGrey,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    if (state.searchError != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        state.searchError!,
                                        style: GoogleFonts.inter(
                                          color: Colors.red.shade600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    if (_searchController.text.isEmpty) ...[
                                      Row(
                                        children: [
                                          const Text('✨',
                                              style: TextStyle(fontSize: 18)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Suggested for You',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Text(
                                        'Search Results',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (state.isSearching)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(
                                        color: AppColors.primaryPink),
                                  ),
                                )
                              else if (_searchController.text.isNotEmpty)
                                // Search Results View
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    children: state.searchResults.map((place) {
                                      final isSelected = state.selectedPlaceIds
                                          .contains(place.id);
                                      return _buildPlaceItem(place, isSelected);
                                    }).toList(),
                                  ),
                                )
                              else ...[
                                // Original View (Suggested + All Places)
                                SizedBox(
                                  height: 210,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    itemCount: state.suggestedPlaces.length,
                                    itemBuilder: (context, index) {
                                      final place =
                                          state.suggestedPlaces[index];
                                      final isSelected = state.selectedPlaceIds
                                          .contains(place.id);
                                      return _buildSuggestedCard(
                                          place, isSelected);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'All Places',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...state.places.map((place) {
                                        final isSelected = state
                                            .selectedPlaceIds
                                            .contains(place.id);
                                        return _buildPlaceItem(
                                            place, isSelected);
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              '${state.selectedPlaceIds.length} places selected',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<GenerateItineraryBloc,
                                GenerateItineraryState>(
                              builder: (context, generateState) {
                                return PrimaryButton(
                                  text: 'Generate Itinerary',
                                  isLoading:
                                      generateState is GenerateItineraryLoading,
                                  onPressed: () {
                                    final tripPlanningState = context
                                        .read<trip_planning.TripPlanningBloc>()
                                        .state;
                                    int days = 1;
                                    if (tripPlanningState.startDate != null &&
                                        tripPlanningState.endDate != null) {
                                      days = tripPlanningState.endDate!
                                              .difference(
                                                  tripPlanningState.startDate!)
                                              .inDays
                                              .abs() +
                                          1;
                                    }
                                    context.read<GenerateItineraryBloc>().add(
                                          GenerateItineraryRequested(
                                            tripId: _tripId,
                                            city: _city,
                                            days: days,
                                            itineraryId: tripPlanningState
                                                .selectedTripDetails
                                                ?.itineraryId,
                                          ),
                                        );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ));
  }

  Widget _buildSuggestedCard(place, bool isSelected) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place.imageUrl,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                width: 160,
                color: AppColors.backgroundGrey,
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      place.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.primaryPink),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.read<AddPlacesBloc>().add(
                      TogglePlaceSelection(placeId: place.id),
                    ),
                child: Text(
                  isSelected ? 'Remove' : 'Add',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceItem(place, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              place.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppColors.backgroundGrey,
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.camera_alt_outlined,
                        size: 16, color: AppColors.textMuted),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.read<AddPlacesBloc>().add(
                            TogglePlaceSelection(placeId: place.id),
                          ),
                      child: Text(
                        isSelected ? 'Remove' : 'Add',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryPink
                              : AppColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.typicalDuration,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${place.rating} (${place.reviewsCount})',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    if (place.verified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Verified',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
