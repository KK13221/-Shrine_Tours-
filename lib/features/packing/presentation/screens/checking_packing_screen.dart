import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shrine_tours/core/theme/app_theme.dart';
import 'package:shrine_tours/core/widgets/primary_button.dart';
import 'package:shrine_tours/features/trip_planning/presentation/bloc/trip_planning_bloc.dart';
import 'package:shrine_tours/features/packing/presentation/bloc/packing_bloc.dart';

class CheckingPackingScreen extends StatefulWidget {
  final String? tripId;
  final bool isFromTabs;

  const CheckingPackingScreen({
    super.key,
    this.tripId,
    this.isFromTabs = false,
  });

  @override
  State<CheckingPackingScreen> createState() => _CheckingPackingScreenState();
}

class _CheckingPackingScreenState extends State<CheckingPackingScreen> {
  // Tracks which category currently has the inline \"add item\" text field open.
  int? _addingItemToCategoryIndex;

  // Tracks whether the \"add category\" text field row is visible at the bottom.
  bool _addingCategory = false;

  final TextEditingController _addItemController = TextEditingController();
  final TextEditingController _addCategoryController = TextEditingController();

  final FocusNode _addItemFocus = FocusNode();
  final FocusNode _addCategoryFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final effectiveTripId = widget.tripId ??
        context.read<TripPlanningBloc>().state.createdTrip?.id ??
        '';
    context.read<PackingBloc>().add(LoadPackingList(effectiveTripId));
  }

  @override
  void dispose() {
    _addItemController.dispose();
    _addCategoryController.dispose();
    _addItemFocus.dispose();
    _addCategoryFocus.dispose();
    super.dispose();
  }

  // ── Add item helpers ──────────────────────────────────────────────────────

  void _openAddItem(int catIndex) {
    if (_addingCategory) {
      setState(() => _addingCategory = false);
      _addCategoryController.clear();
    }
    setState(() {
      _addingItemToCategoryIndex = catIndex;
      _addItemController.clear();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _addItemFocus.requestFocus());
  }

  void _confirmAddItem(int catIndex, String categoryId, String tripId) {
    final name = _addItemController.text.trim();
    if (name.isNotEmpty) {
      context.read<PackingBloc>().add(AddItemToCategory(
            tripId: tripId,
            categoryId: categoryId,
            categoryIndex: catIndex,
            itemName: name,
          ));
    }
    setState(() => _addingItemToCategoryIndex = null);
    _addItemController.clear();
    _addItemFocus.unfocus();
  }

  void _cancelAddItem() {
    setState(() => _addingItemToCategoryIndex = null);
    _addItemController.clear();
    _addItemFocus.unfocus();
  }

  // ── Add category helpers ──────────────────────────────────────────────────

  void _openAddCategory() {
    if (_addingItemToCategoryIndex != null) {
      setState(() => _addingItemToCategoryIndex = null);
      _addItemController.clear();
    }
    setState(() {
      _addingCategory = true;
      _addCategoryController.clear();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _addCategoryFocus.requestFocus());
  }

  void _confirmAddCategory(String tripId) {
    final name = _addCategoryController.text.trim();
    if (name.isNotEmpty) {
      context.read<PackingBloc>().add(AddCategory(
            tripId: tripId,
            categoryName: name,
          ));
    }
    setState(() => _addingCategory = false);
    _addCategoryController.clear();
    _addCategoryFocus.unfocus();
  }

  void _cancelAddCategory() {
    setState(() => _addingCategory = false);
    _addCategoryController.clear();
    _addCategoryFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTripId = widget.tripId ??
        context.watch<TripPlanningBloc>().state.createdTrip?.id ??
        '';

    return BlocListener<PackingBloc, PackingState>(
      listener: (context, state) {
        if (state.submitSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Packing list updated successfully',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryPink,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );
        }
      },
      child: BlocBuilder<PackingBloc, PackingState>(
        builder: (context, state) {
          final content = _buildContent(context, state, effectiveTripId);

          if (widget.isFromTabs) {
            return content;
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
                'Checking My Packing',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              centerTitle: true,
            ),
            body: content,
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PackingState state, String tripId) {
    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isFromTabs) ...[
          // ── Trip header ───────────────────────────────────────
          BlocBuilder<TripPlanningBloc, TripPlanningState>(
            builder: (context, tripState) {
              final city = tripState.destination;
              final startDate = tripState.startDate;
              final endDate = tripState.endDate;

              String dateRange = 'Date not set';
              if (startDate != null && endDate != null) {
                final formatter = DateFormat('EEE, d MMM');
                final yearFormatter = DateFormat('y');
                final nights = endDate.difference(startDate).inDays;
                dateRange =
                    '${formatter.format(startDate)} - ${formatter.format(endDate)}, ${yearFormatter.format(startDate)} ($nights Nights)';
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel to $city',
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRange,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textDark),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // ── Hero image with progress ──────────────────────────
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
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${state.totalItems} Items',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${(state.progress * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
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

        if (state.isLoading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryPink)))
        else if (state.errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(state.errorMessage!,
                      style: GoogleFonts.inter(color: Colors.red),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context
                        .read<PackingBloc>()
                        .add(LoadPackingList(tripId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(state.categories.length, (catIndex) {
            final category = state.categories[catIndex];
            final isAddingHere = _addingItemToCategoryIndex == catIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context
                        .read<PackingBloc>()
                        .add(ToggleCategory(catIndex)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category.name),
                              size: 20, color: AppColors.primaryPink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark),
                            ),
                          ),
                          Text(
                            '${category.checkedCount}/${category.items.length}',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryPink),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                              category.isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  if (category.isExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          ...List.generate(category.items.length, (itemIndex) {
                            final item = category.items[itemIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: item.isChecked
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryPink,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: const Icon(Icons.check,
                                                size: 16,
                                                color: AppColors.primaryPink),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(item.name,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white)),
                                          ),
                                          GestureDetector(
                                            onTap: () => context
                                                .read<PackingBloc>()
                                                .add(ToggleItem(
                                                  tripId: tripId,
                                                  itemId: item.id,
                                                  categoryIndex: catIndex,
                                                  itemIndex: itemIndex,
                                                )),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => context
                                              .read<PackingBloc>()
                                              .add(ToggleItem(
                                                tripId: tripId,
                                                itemId: item.id,
                                                categoryIndex: catIndex,
                                                itemIndex: itemIndex,
                                              )),
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: AppColors.cardBorder,
                                                    width: 2)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(item.name,
                                              style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: AppColors.textDark)),
                                        ),
                                        if (item.quantity > 1) ...[
                                          GestureDetector(
                                            onTap: () => context
                                                .read<PackingBloc>()
                                                .add(UpdateItemQuantity(
                                                    categoryIndex: catIndex,
                                                    itemIndex: itemIndex,
                                                    quantity:
                                                        item.quantity - 1)),
                                            child: const Text('—',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text('${item.quantity}',
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          GestureDetector(
                                            onTap: () => context
                                                .read<PackingBloc>()
                                                .add(UpdateItemQuantity(
                                                    categoryIndex: catIndex,
                                                    itemIndex: itemIndex,
                                                    quantity:
                                                        item.quantity + 1)),
                                            child: const Text('+',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                            );
                          }),
                          if (isAddingHere)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: AppColors.primaryPink,
                                            width: 2)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _addItemController,
                                      focusNode: _addItemFocus,
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textDark),
                                      decoration: InputDecoration(
                                        hintText: 'Item name...',
                                        hintStyle: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.textMuted),
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _confirmAddItem(
                                          catIndex, category.id, tripId),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () => _confirmAddItem(
                                        catIndex, category.id, tripId),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryPink,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: const Icon(Icons.check,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _cancelAddItem,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                          color: AppColors.cardBorder,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Icon(Icons.close,
                                          size: 16, color: AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          GestureDetector(
                            onTap: () => _openAddItem(catIndex),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      size: 16,
                                      color: isAddingHere
                                          ? AppColors.primaryPink
                                          : AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text('Add Item',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: isAddingHere
                                              ? AppColors.primaryPink
                                              : AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),

        const SizedBox(height: 4),

        if (_addingCategory)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryPink)),
            child: Row(
              children: [
                Icon(_getCategoryIcon(''),
                    size: 20, color: AppColors.primaryPink),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _addCategoryController,
                    focusNode: _addCategoryFocus,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Category name...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _confirmAddCategory(tripId),
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmAddCategory(tripId),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: AppColors.primaryPink,
                        borderRadius: BorderRadius.circular(6)),
                    child:
                        const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _cancelAddCategory,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(6)),
                    child:
                        Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),

        GestureDetector(
          onTap: _openAddCategory,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add,
                    size: 16,
                    color: _addingCategory
                        ? AppColors.primaryPink
                        : AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Add Category',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _addingCategory
                            ? AppColors.primaryPink
                            : AppColors.textMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );

    if (widget.isFromTabs) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: mainContent,
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: mainContent,
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
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Essentials':
        return Icons.luggage;
      case 'Airplane':
        return Icons.flight;
      case 'Bus':
        return Icons.directions_bus;
      case 'Hotel':
        return Icons.hotel;
      case 'International':
        return Icons.public;
      case 'Personal':
        return Icons.person;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
