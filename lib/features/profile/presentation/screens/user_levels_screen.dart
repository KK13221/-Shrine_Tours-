import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../trip_planning/data/datasource/trips_data_source.dart';
import '../../../trip_planning/data/model/trips.dart';

class UserLevelsScreen extends StatefulWidget {
  const UserLevelsScreen({super.key});

  @override
  State<UserLevelsScreen> createState() => _UserLevelsScreenState();
}

class _UserLevelsScreenState extends State<UserLevelsScreen> {
  int tripCount = 0;
  bool isLoading = true;

  static const _levels = [
    {'name': 'Wanderer', 'trips': '0-2 trips', 'color': Color(0xFF9E9E9E)},
    {'name': 'Explorer', 'trips': '3-7 trips', 'color': Color(0xFF7C4DFF)},
    {'name': 'Adventurer', 'trips': '8-15 trips', 'color': Color(0xFFFF9800)},
    {
      'name': 'Globetrotter',
      'trips': '16-30 trips',
      'color': Color(0xFFFF9800)
    },
    {'name': 'Legend', 'trips': '31+ trips', 'color': Color(0xFFFF9800)},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final dataSource = TripsDataSourceImpl(ApiClient());
      final trips = await dataSource.getTrips();

      setState(() {
        tripCount = trips.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// 🔥 LEVEL LOGIC
  Map<String, dynamic> _getUserLevel(int trips) {
    if (trips <= 2) {
      return {'name': 'Wanderer', 'min': 0, 'max': 2};
    } else if (trips <= 7) {
      return {'name': 'Explorer', 'min': 3, 'max': 7};
    } else if (trips <= 15) {
      return {'name': 'Adventurer', 'min': 8, 'max': 15};
    } else if (trips <= 30) {
      return {'name': 'Globetrotter', 'min': 16, 'max': 30};
    } else {
      return {'name': 'Legend', 'min': 31, 'max': null};
    }
  }

  /// 🔥 PROGRESS LOGIC
  double _getProgress(int trips, int min, int? max) {
    if (max == null) return 1.0;
    return (trips - min) / (max - min);
  }

  bool _isLocked(String levelName) {
    switch (levelName) {
      case 'Wanderer':
        return false;
      case 'Explorer':
        return tripCount < 3;
      case 'Adventurer':
        return tripCount < 8;
      case 'Globetrotter':
        return tripCount < 16;
      case 'Legend':
        return tripCount < 31;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final level = _getUserLevel(tripCount);
    final progress =
        _getProgress(tripCount, level['min'], level['max']).clamp(0.0, 1.0);

    String nextLevelText;
    String progressTitle;

    if (level['max'] == null) {
      nextLevelText = 'You reached the highest level!';
      progressTitle = 'Max Level Achieved';
    } else {
      final remaining = level['max'] - tripCount;
      nextLevelText = 'Complete $remaining more trips to level up!';
      progressTitle = 'Progress to next level';
    }

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
          'User Levels',
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 CURRENT LEVEL CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.levelCardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Current Level',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level['name'],
                            style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events,
                            color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// 🔥 PROGRESS TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        progressTitle,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white.withOpacity(0.8)),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// 🔥 PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// 🔥 NEXT LEVEL TEXT
                  Text(
                    nextLevelText,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// 🔥 ALL LEVELS
            Text(
              'All Levels',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 16),

            ..._levels.map((lvl) {
              final isCurrent = lvl['name'] == level['name'];
              final isLocked = _isLocked(lvl['name'] as String);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primaryPinkSoft : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.primaryPink
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (lvl['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.emoji_events,
                          color: lvl['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              lvl['name'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.lock,
                                  size: 14, color: AppColors.textMuted),
                            ],
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPink,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lvl['trips'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            /// 🔥 BENEFITS
            // Text(
            //   'Level Benefits',
            //   style: GoogleFonts.inter(
            //       fontSize: 18,
            //       fontWeight: FontWeight.w600,
            //       color: AppColors.textDark),
            // ),
            // const SizedBox(height: 12),
            // ..._benefits.map((benefit) => Padding(
            //       padding: const EdgeInsets.only(bottom: 8),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('•  ', style: GoogleFonts.inter(fontSize: 14)),
            //           Expanded(
            //             child: Text(
            //               benefit,
            //               style: GoogleFonts.inter(
            //                   fontSize: 14, color: AppColors.textDark),
            //             ),
            //           ),
            //         ],
            //       ),
            //     )),
          ],
        ),
      ),
    );
  }

  static const _benefits = [
    'Unlock exclusive trip templates',
    'Priority AI optimization',
    'Special badges on shared itineraries',
    'Early access to new features',
  ];
}
