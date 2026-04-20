import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shrine_tours/features/payment/data/models/payment_models.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';

// ─────────────────────────────────────────────
// INTERNAL DATA TYPES
// ─────────────────────────────────────────────

enum _BillingStatus { paid, pending, failed }

// _BillingStatus parsing logic if needed
_BillingStatus _parseStatus(String status) {
  if (status.toUpperCase() == 'CREATED') return _BillingStatus.pending;
  if (status.toUpperCase() == 'PAID' || status.toUpperCase() == 'SUCCESS') return _BillingStatus.paid;
  return _BillingStatus.failed;
}

// ─────────────────────────────────────────────
// ENTRY POINT
// Usage: SubscriptionBillsSheet.show(context);
// ─────────────────────────────────────────────

class SubscriptionBillsSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SubscriptionBillsSheetBody(),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM SHEET BODY
// ─────────────────────────────────────────────

class _SubscriptionBillsSheetBody extends StatefulWidget {
  const _SubscriptionBillsSheetBody();

  @override
  State<_SubscriptionBillsSheetBody> createState() =>
      _SubscriptionBillsSheetBodyState();
}

class _SubscriptionBillsSheetBodyState
    extends State<_SubscriptionBillsSheetBody> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadSubscription());
    context.read<ProfileBloc>().add(LoadBillingHistory());
  }

  void _onDownload(String id) {
    context.read<ProfileBloc>().add(DownloadInvoiceEvent(id));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final sub = state.subscription;
        return Container(
          height: screenHeight * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              Expanded(
                child: state.isLoading && sub == null
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFE91E8C)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Plan card ───────────────────────────────────────────
                            _PremiumPlanCard(
                              name: sub?.displayName ?? 'Free Plan',
                              // description: sub != null
                              //     ? sub.features.join(' • ')
                              //     : 'Explore shrines with basic features',
                              priceLabel: sub?.priceLabel ?? '\$0.00',
                              billingCycle: sub?.billingCycle ?? '/month',
                              nextBilling:
                                  sub != null && sub.renewsAt.isNotEmpty
                                      ? sub.renewsAt
                                      : 'N/A',
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Billing History',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // ── Billing list ────────────────────────────────────────
                            if (state.isBillingLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFE91E8C)),
                                ),
                              )
                            else if (state.billingRecords.isEmpty)
                              const _EmptyBillingHistory()
                            else
                              _BillingHistoryList(
                                records: state.billingRecords,
                                downloadingId: state.downloadingInvoiceId,
                                onDownload: _onDownload,
                              ),
                          ],
                        ),
                      ),

              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HANDLE
// ─────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFDDDDDD),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HEADER
// ─────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Colors.black87,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Subscription & Bills',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, size: 22, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PREMIUM PLAN CARD
// Props are plain primitives → easy to swap with model fields
// ─────────────────────────────────────────────

class _PremiumPlanCard extends StatelessWidget {
  final String name;
  final String? description;
  final String priceLabel;
  final String billingCycle;
  final String nextBilling;

  const _PremiumPlanCard({
    required this.name,
    this.description,
    required this.priceLabel,
    required this.billingCycle,
    required this.nextBilling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E8C), Color(0xFFF06292)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description ?? "",
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          //const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceLabel,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  billingCycle,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Next billing: $nextBilling',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BILLING HISTORY LIST
// ─────────────────────────────────────────────

class _BillingHistoryList extends StatelessWidget {
  final List<PaymentOrderData> records;
  final String? downloadingId;
  final void Function(String id) onDownload;

  const _BillingHistoryList({
    required this.records,
    required this.onDownload,
    this.downloadingId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records
          .map((record) => _BillingHistoryItem(
                record: record,
                isDownloading: downloadingId == record.id,
                onDownload: onDownload,
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// BILLING HISTORY ITEM
// ─────────────────────────────────────────────

class _BillingHistoryItem extends StatelessWidget {
  final PaymentOrderData record;
  final bool isDownloading;
  final void Function(String id) onDownload;

  const _BillingHistoryItem({
    required this.record,
    required this.onDownload,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine date logic
    final dateString = record.paidAt ?? record.createdAt;
    String formattedDate = dateString;
    try {
      final dt = DateTime.parse(dateString);
      formattedDate = DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {}

    final status = _parseStatus(record.status);
    return GestureDetector(
      onTap: () => context.push('/payment-details', extra: record.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F3F3), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusLabel(status: status),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.currency.toUpperCase() == 'INR' ? '₹' : record.currency} ${(record.amount / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE91E8C),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => onDownload(record.id),
                        child: const Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE91E8C),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS LABEL
// ─────────────────────────────────────────────

class _StatusLabel extends StatelessWidget {
  final _BillingStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _BillingStatus.paid => ('Paid', const Color(0xFF4CAF50)),
      _BillingStatus.pending => ('Pending', const Color(0xFFFFA726)),
      _BillingStatus.failed => ('Failed', const Color(0xFFF44336)),
    };

    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyBillingHistory extends StatelessWidget {
  const _EmptyBillingHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No billing history yet.',
          style: TextStyle(fontSize: 14, color: Colors.black45),
        ),
      ),
    );
  }
}
