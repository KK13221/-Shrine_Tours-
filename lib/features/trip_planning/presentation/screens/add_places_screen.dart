import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';

class AddPlacesScreen extends StatefulWidget {
  const AddPlacesScreen({super.key});

  @override
  State<AddPlacesScreen> createState() => _AddPlacesScreenState();
}

class _AddPlacesScreenState extends State<AddPlacesScreen> {
  final Set<String> _selectedPlaces = {'Van Vihar'};

  final _suggestedPlaces = [
    {'name': 'Sanchi Stupa', 'category': 'Historical', 'image': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=300'},
    {'name': 'Local Food Tour', 'category': 'Food', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=300'},
    {'name': 'Bhojpur Temple', 'category': 'Religious', 'image': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=300'},
  ];

  final _allPlaces = [
    {'name': 'Van Vihar', 'duration': 'Typically requires 3h', 'rating': '4.8', 'reviews': '47', 'verified': true, 'image': 'https://images.unsplash.com/photo-1564507592412-553f7c1fcb42?w=200'},
    {'name': 'Upper Lake', 'duration': 'Typically requires 2h', 'rating': '4.6', 'reviews': '32', 'verified': true, 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200'},
    {'name': 'Tribal Museum', 'duration': 'Typically requires 1.5h', 'rating': '4.4', 'reviews': '28', 'verified': false, 'image': 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=200'},
  ];

  @override
  Widget build(BuildContext context) {
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
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
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

                          // Search bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for a place',
                              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                              suffixIcon: const Icon(Icons.mic, color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.backgroundGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Suggested for You
                          Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 18)),
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
                        ],
                      ),
                    ),

                    // Horizontal scroll cards
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _suggestedPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _suggestedPlaces[index];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    place['image']!,
                                    height: 130,
                                    width: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 130,
                                      width: 160,
                                      color: AppColors.backgroundGrey,
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  place['name']!,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  place['category']!,
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryPink),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // All Places
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Places',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 12),
                          ..._allPlaces.map((place) {
                            final isSelected = _selectedPlaces.contains(place['name']);
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
                                      place['image'] as String,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80, height: 80,
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
                                            Text(
                                              place['name'] as String,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.textMuted),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () => setState(() {
                                                if (isSelected) {
                                                  _selectedPlaces.remove(place['name']);
                                                } else {
                                                  _selectedPlaces.add(place['name'] as String);
                                                }
                                              }),
                                              child: Text(
                                                isSelected ? 'Remove' : 'Add',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected ? AppColors.primaryPink : AppColors.successGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          place['duration'] as String,
                                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${place['rating']} (${place['reviews']})',
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                            if (place['verified'] == true) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${_selectedPlaces.length} places selected',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Generate Itinerary',
                    onPressed: () => context.push('/itinerary-view'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
