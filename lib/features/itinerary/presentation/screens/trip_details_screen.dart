import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/itinerary_bloc.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _selectedTab = 0;
  final _tabs = ['Overview', 'Discover', 'My Items'];

  final List<Map<String, dynamic>> _packingItems = [
    {'name': 'test', 'packed': false},
    {'name': 'test 2', 'packed': true},
    {'name': 'test 3', 'packed': false},
  ];
  final TextEditingController _itemController = TextEditingController();
  bool _isAddingItem = false;

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, state) {
        final itinerary = state.selectedItinerary;
        if (itinerary == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

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
              itinerary.city,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Custom Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabs[index],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.textDark : AppColors.textDark,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildTabContent(_selectedTab, itinerary, state),
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
        );
      },
    );
  }

  Widget _buildTabContent(int tabIndex, Itinerary itinerary, ItineraryState state) {
    if (tabIndex == 0) {
      // Overview Tab
      final dates = itinerary.dateRange.split('-');
      final startDateStr = dates.isNotEmpty ? dates[0].trim() : 'N/A';
      final endDateStr = dates.length > 1 ? dates[1].trim() : 'N/A';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _dateCard('Start', 'Thursday', startDateStr)),
              const SizedBox(width: 16),
              Expanded(child: _dateCard('End', 'Sunday', endDateStr)),
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
                  '${itinerary.days} days',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Travel included',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _weatherRow(Icons.thermostat_outlined, 'Temperature', '32°C / 24°C', AppColors.primaryPink),
                const SizedBox(height: 16),
                _weatherRow(Icons.water_drop_outlined, 'Precipitation', '20%', AppColors.primaryPink),
                const SizedBox(height: 16),
                _weatherRow(Icons.air, 'Wind', '12 km/h NE', AppColors.primaryPink),
                const SizedBox(height: 16),
                _weatherRow(Icons.opacity, 'Humidity', '65%', AppColors.primaryPink),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/plan-trip'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Modify Itinerary Plan',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryPink),
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
                  'Top ${itinerary.places.clamp(1, 5)} Places to Visit',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.primaryPink),
                label: Text(
                  'Map View',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryPink),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  side: BorderSide(color: AppColors.primaryPink.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      const Icon(Icons.location_on_outlined, color: AppColors.primaryPink, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.title,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPinkSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Day $dayIndex',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Morning • ${activity.duration}',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'One of the popular places with stunning views and great architecture to explore.',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      return _buildMyItemsTab(itinerary.city);
    }
  }

  Widget _dateCard(String label, String dayName, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
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
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
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

  Widget _weatherRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildMyItemsTab(String city) {
    if (_packingItems.isEmpty && !_isAddingItem) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.primaryPink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'My Packing Items for $city',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textMuted.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No items added yet',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isAddingItem = true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    backgroundColor: AppColors.primaryPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: Text(
                    'Add First Item',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final packedCount = _packingItems.where((i) => i['packed'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.primaryPink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'My Packing Items for $city',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._packingItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _packingItems[index]['packed'] = !_packingItems[index]['packed'];
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: item['packed'] ? AppColors.primaryPink : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item['packed'] ? AppColors.primaryPink : AppColors.textMuted.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: item['packed']
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        item['name'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item['packed'] ? AppColors.textMuted : AppColors.textDark,
                          decoration: item['packed'] ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              if (_isAddingItem)
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryPink, width: 1.5),
                      ),
                      child: const Icon(Icons.add, color: AppColors.primaryPink, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter item name...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryPink, width: 1.5),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryPink, width: 1.5),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryPink, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_itemController.text.trim().isNotEmpty) {
                          setState(() {
                            _packingItems.add({'name': _itemController.text.trim(), 'packed': false});
                            _itemController.clear();
                            _isAddingItem = false;
                          });
                        } else {
                          setState(() {
                            _isAddingItem = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: AppColors.primaryPink,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () => setState(() => _isAddingItem = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.textMuted.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add Item',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_packingItems.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark),
                    ),
                    Text(
                      '$packedCount / ${_packingItems.length} packed',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryPink),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _packingItems.isEmpty ? 0 : packedCount / _packingItems.length,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
