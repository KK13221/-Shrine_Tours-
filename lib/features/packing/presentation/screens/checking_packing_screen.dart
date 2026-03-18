import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/packing_bloc.dart';

class CheckingPackingScreen extends StatefulWidget {
  const CheckingPackingScreen({super.key});

  @override
  State<CheckingPackingScreen> createState() => _CheckingPackingScreenState();
}

class _CheckingPackingScreenState extends State<CheckingPackingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PackingBloc>().add(LoadPackingList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackingBloc, PackingState>(
      builder: (context, state) {
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
              'Checking My Packing',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travel to Florence',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fri, 24 Ago - Thu, 2 Set, 2023 (9 Nights)',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const Icon(Icons.more_vert, color: AppColors.textDark),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hero image with progress
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1541370976299-4d24ebbc9077?w=500',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: AppColors.backgroundGrey,
                                child: const Center(child: Icon(Icons.image, size: 48)),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${state.totalItems} Items',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${(state.progress * 100).toInt()}%',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: state.progress,
                                        backgroundColor: AppColors.cardBorder,
                                        color: AppColors.primaryPink,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Categories
                      ...List.generate(state.categories.length, (catIndex) {
                        final category = state.categories[catIndex];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              // Category header
                              GestureDetector(
                                onTap: () => context.read<PackingBloc>().add(ToggleCategory(catIndex)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(category.name),
                                        size: 20,
                                        color: AppColors.primaryPink,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${category.checkedCount}/${category.items.length}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryPink,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        category.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Items
                              if (category.isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Column(
                                    children: List.generate(category.items.length, (itemIndex) {
                                      final item = category.items[itemIndex];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: item.isChecked
                                            // Checked item (pink)
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryPink,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Icon(Icons.check, size: 16, color: AppColors.primaryPink),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => context.read<PackingBloc>().add(
                                                        ToggleItem(categoryIndex: catIndex, itemIndex: itemIndex),
                                                      ),
                                                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            // Unchecked item
                                            : Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => context.read<PackingBloc>().add(
                                                      ToggleItem(categoryIndex: catIndex, itemIndex: itemIndex),
                                                    ),
                                                    child: Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: AppColors.cardBorder, width: 2),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                                                    ),
                                                  ),
                                                  // Quantity controls
                                                  if (item.quantity > 1) ...[
                                                    GestureDetector(
                                                      onTap: () => context.read<PackingBloc>().add(
                                                        UpdateItemQuantity(
                                                          categoryIndex: catIndex,
                                                          itemIndex: itemIndex,
                                                          quantity: item.quantity - 1,
                                                        ),
                                                      ),
                                                      child: const Text('—', style: TextStyle(fontSize: 16)),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                                      child: Text(
                                                        '${item.quantity}',
                                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => context.read<PackingBloc>().add(
                                                        UpdateItemQuantity(
                                                          categoryIndex: catIndex,
                                                          itemIndex: itemIndex,
                                                          quantity: item.quantity + 1,
                                                        ),
                                                      ),
                                                      child: const Text('+', style: TextStyle(fontSize: 16)),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                      );
                                    }),
                                    // Add item button
                                    GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add, size: 16, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Add Item',
                                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  text: 'Save to my Itinerary',
                  onPressed: () => context.go('/itineraries'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Essentials': return Icons.luggage;
      case 'Airplane': return Icons.flight;
      case 'Bus': return Icons.directions_bus;
      case 'Hotel': return Icons.hotel;
      case 'International': return Icons.public;
      case 'Personal': return Icons.person;
      default: return Icons.inventory;
    }
  }
}
