import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class UserLevelsScreen extends StatelessWidget {
  const UserLevelsScreen({super.key});

  static const _levels = [
    {'name': 'Wanderer', 'trips': '0-2 trips', 'color': Color(0xFF9E9E9E), 'locked': false, 'current': false},
    {'name': 'Explorer', 'trips': '3-7 trips', 'color': Color(0xFF7C4DFF), 'locked': false, 'current': true},
    {'name': 'Adventurer', 'trips': '8-15 trips', 'color': Color(0xFFFF9800), 'locked': true, 'current': false},
    {'name': 'Globetrotter', 'trips': '16-30 trips', 'color': Color(0xFFFF9800), 'locked': true, 'current': false},
    {'name': 'Legend', 'trips': '31+ trips', 'color': Color(0xFFFF9800), 'locked': true, 'current': false},
  ];

  @override
  Widget build(BuildContext context) {
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
          'User Levels',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
            // Current level card
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
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Explorer',
                            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
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
                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to Adventurer',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                      ),
                      Text(
                        '75%',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete 3 more trips to level up!',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // All Levels
            Text(
              'All Levels',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            ..._levels.map((level) {
              final isCurrent = level['current'] as bool;
              final isLocked = level['locked'] as bool;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primaryPinkSoft : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? AppColors.primaryPink : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (level['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: level['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              level['name'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.lock, size: 14, color: AppColors.textMuted),
                            ],
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPink,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level['trips'] as String,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Level Benefits
            Text(
              'Level Benefits',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            ..._benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: GoogleFonts.inter(fontSize: 14)),
                  Expanded(
                    child: Text(
                      benefit,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            )),
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
