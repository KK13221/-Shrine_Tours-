import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/core/widgets/title_case.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/trip_planning_bloc.dart';
import '../../data/model/place.dart';

class TripPreferencesScreen extends StatefulWidget {
  const TripPreferencesScreen({super.key});

  @override
  State<TripPreferencesScreen> createState() => _TripPreferencesScreenState();
}

class _TripPreferencesScreenState extends State<TripPreferencesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Pre-fill search field with existing starting point name in modification flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<TripPlanningBloc>().state;
      if (state.editingTripId != null &&
          state.selectedStartingPoint != null &&
          _searchController.text.isEmpty) {
        _searchController.text = state.selectedStartingPoint!.name;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripPlanningBloc, TripPlanningState>(
      listenWhen: (previous, current) =>
          previous.createdTrip != current.createdTrip ||
          previous.creationErrorMessage != current.creationErrorMessage,
      listener: (context, state) {
        if (state.creationErrorMessage != null &&
            state.creationErrorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.creationErrorMessage!,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state.createdTrip != null && !state.isGenerating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.editingTripId != null
                    ? 'Trip updated successfully! ✨'
                    : 'Trip created successfully! ✨',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
          Future.microtask(() => context.go('/add-places'));
        }
      },
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
                              onTap: () => context.go('/itineraries'),
                              child: const Icon(Icons.chevron_left,
                                  size: 28, color: AppColors.textDark),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.editingTripId != null
                                  ? 'Modify: ${TitleCase.toTitleCase(state.destination)}'
                                  : (state.destination.isNotEmpty
                                      ? TitleCase.toTitleCase(state.destination)
                                      : 'Your destination'),
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
                            state.editingTripId != null
                                ? 'Adjust your preferences for this trip'
                                : (state.startDate != null &&
                                        state.endDate != null
                                    ? '${state.startDate!.month}/${state.startDate!.day}/${state.startDate!.year} - ${state.endDate!.month}/${state.endDate!.day}/${state.endDate!.year}'
                                    : 'Select travel dates'),
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Starting Point Search Section
                        Text(
                          'Starting Point',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            if (val.trim().isNotEmpty) {
                              context
                                  .read<TripPlanningBloc>()
                                  .add(SearchStartingPoint(val));
                            } else {
                              context
                                  .read<TripPlanningBloc>()
                                  .add(ClearStartingPointSearch());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Where will you start your trip?',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.location_on_outlined,
                                color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.backgroundGrey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),

                        // Search Results or Selected Place
                        if (state.isSearchingStartingPoint)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryPink)),
                          )
                        else if (state.startingPointPredictions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 300),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount:
                                    state.startingPointPredictions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final place =
                                      state.startingPointPredictions[index];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.backgroundGrey,
                                      child: Icon(Icons.map_outlined,
                                          size: 20, color: AppColors.textDark),
                                    ),
                                    title: Text(place.name,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(place.category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textMuted)),
                                    onTap: () {
                                      _searchController.clear();
                                      context
                                          .read<TripPlanningBloc>()
                                          .add(SelectStartingPoint(place.id));
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        else if (state.selectedStartingPoint != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Location',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                _buildStartingPointCard(
                                    context, state.selectedStartingPoint!),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Travellers
                        Text(
                          'Travellers',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 20),
                        _buildCounter(
                          context,
                          'Adults',
                          state.adults,
                          (val) {
                            int minAdults = 1;
                            if (state.travellerType == 'solo') {
                              return;
                            } else if (state.travellerType == 'couple') {
                              minAdults = 2;
                              if (val < minAdults) val = minAdults;
                            } else {
                              minAdults = 1;
                              if (val < minAdults) val = minAdults;
                            }
                            context
                                .read<TripPlanningBloc>()
                                .add(UpdateAdults(val));
                          },
                          enabled: state.travellerType != 'solo',
                          amountToAdd: state.travellerType == 'couple' ? 2 : 1,
                          tooltipMessage:
                              'Above 12 years will be considered as adult.',
                        ),
                        const SizedBox(height: 16),
                        _buildCounter(
                          context,
                          'Kids',
                          state.kids,
                          (val) {
                            if (val < 0) val = 0;
                            context
                                .read<TripPlanningBloc>()
                                .add(UpdateKids(val));
                          },
                          enabled: state.travellerType == 'family' ||
                              state.travellerType == 'friends',
                          tooltipMessage: '2 to 12 years will be kids.',
                        ),
                        const SizedBox(height: 32),

                        // Trip Style
                        Text(
                          'Trip Style',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
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
                    text:
                        state.editingTripId != null ? 'Update ✨' : 'Generate ✨',
                    isLoading: state.isGenerating,
                    onPressed: state.isGenerating
                        ? null
                        : () {
                            context
                                .read<TripPlanningBloc>()
                                .add(GenerateItinerary());
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

  Widget _buildStartingPointCard(BuildContext context, Place place) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppColors.backgroundGrey,
                child: const Icon(Icons.image, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  place.category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${place.rating} (${place.reviewsCount})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<TripPlanningBloc>().add(ClearStartingPointSearch());
              context
                  .read<TripPlanningBloc>()
                  .add(const SelectStartingPoint('')); // Clear selected
            },
            icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged, {
    bool enabled = true,
    int amountToAdd = 1,
    String tooltipMessage = '',
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            if (tooltipMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tooltipMessage, style: GoogleFonts.inter()),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const Icon(Icons.info_outline,
              size: 16, color: AppColors.textMuted),
        ),
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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: enabled ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _counterButton(
            Icons.remove,
            enabled
                ? () {
                    onChanged(value - amountToAdd);
                  }
                : null,
            enabled),
        const SizedBox(width: 8),
        _counterButton(Icons.add,
            enabled ? () => onChanged(value + amountToAdd) : null, enabled),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback? onTap, bool enabled) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? Colors.transparent : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon,
            color: enabled ? AppColors.textDark : AppColors.textMuted,
            size: 20),
      ),
    );
  }

  List<Widget> _buildTripStyles(BuildContext context, String selected) {
    final styles = [
      {
        'title': 'Budget Friendly',
        'desc': 'Cost-effective choices for smart travellers.'
      },
      {'title': 'Fast Travel', 'desc': 'Cover more places in less time.'},
      {
        'title': 'Relaxed Vacation',
        'desc': 'Take it easy and unwind completely.'
      },
      {
        'title': 'Explore Everything',
        'desc': 'Comprehensive itinerary covering all spots.'
      },
      {'title': 'Food Lover', 'desc': 'Focus on local culinary experiences.'},
    ];

    return styles.map((styleObj) {
      final style = styleObj['title']!;
      final desc = styleObj['desc']!;
      final isSelected = selected == style;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () =>
              context.read<TripPlanningBloc>().add(UpdateTripStyle(style)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? AppColors.primaryPink : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? AppColors.primaryPink.withOpacity(0.05)
                  : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPink
                          : AppColors.cardBorder,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
