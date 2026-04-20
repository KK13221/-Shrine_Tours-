import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shrine_tours/core/theme/app_theme.dart';
import 'package:shrine_tours/features/payment/presentation/bloc/payment_order_detail_bloc.dart';
import 'package:shrine_tours/features/payment/presentation/bloc/payment_order_detail_event.dart';
import 'package:shrine_tours/features/payment/presentation/bloc/payment_order_detail_state.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String orderId;

  const PaymentDetailsScreen({super.key, required this.orderId});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<PaymentOrderDetailBloc>()
        .add(LoadPaymentOrderDetail(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PaymentOrderDetailBloc, PaymentOrderDetailState>(
        builder: (context, state) {
          if (state is PaymentOrderDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          } else if (state is PaymentOrderDetailLoaded) {
            final order = state.orderDetail;
            String rawDate = order.paidAt ?? order.createdAt;

            if (!rawDate.endsWith('Z')) {
              rawDate = '${rawDate}Z';
            }

            final date = DateTime.parse(rawDate).toLocal();

            final formattedDate =
                DateFormat('MMM dd, yyyy • hh:mm a').format(date);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(order.status).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(order.status),
                            color: _getStatusColor(order.status),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${order.currency.toUpperCase() == 'INR' ? '₹' : order.currency} ${(order.amount / 100).toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildDetailItem('Order ID', order.id),
                  _buildDetailItem('Plan Code', order.planCode),
                  _buildDetailItem('Receipt', order.receipt),
                  _buildDetailItem('Razorpay Order ID', order.razorpayOrderId),
                  _buildDetailItem('Payment Date', formattedDate),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  if (order.status.toLowerCase() == 'paid' ||
                      order.status.toLowerCase() == 'success')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This payment was processed successfully via Razorpay.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          } else if (state is PaymentOrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PaymentOrderDetailBloc>()
                          .add(LoadPaymentOrderDetail(widget.orderId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return AppColors.successGreen;
      case 'created':
      case 'pending':
        return AppColors.warningOrange;
      case 'failed':
        return AppColors.errorRed;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return Icons.check_circle_outline;
      case 'created':
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
