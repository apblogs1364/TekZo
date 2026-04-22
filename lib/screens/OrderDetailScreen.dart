import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';
import 'ReviewScreen.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A66FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 8, right: 16),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Order #ORD-7742',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                    ),
                    Text(
                      'Placed on Oct 24, 2023',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROCESSING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOrderProgressCard(primaryBlue),
          const SizedBox(height: 16),
          _buildCustomerInfoCard(),
          const SizedBox(height: 16),
          _buildOrderItemsCard(),
          const SizedBox(height: 16),
          _buildPaymentSummaryCard(primaryBlue),
          const SizedBox(height: 24),
          _buildActionButtons(context, primaryBlue),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildOrderProgressCard(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER PROGRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStep('Placed', true, isFirst: true, primaryBlue: primaryBlue),
              _buildProgressLine(true, primaryBlue),
              _buildProgressStep('Confirmed', true, primaryBlue: primaryBlue),
              _buildProgressLine(true, primaryBlue),
              _buildProgressStep('Processing', true, isCurrent: true, primaryBlue: primaryBlue),
              _buildProgressLine(false, primaryBlue),
              _buildProgressStep('Shipped', false),
              _buildProgressLine(false, primaryBlue),
              _buildProgressStep('Delivered', false, isLast: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted,
      {bool isCurrent = false,
      bool isFirst = false,
      bool isLast = false,
      Color? primaryBlue}) {
    IconData iconData = Icons.check;
    if (isCurrent && label == 'Processing') iconData = Icons.sync;
    if (!isCompleted && label == 'Shipped') iconData = Icons.local_shipping_outlined;
    if (!isCompleted && label == 'Delivered') iconData = Icons.inventory_2_outlined;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? primaryBlue : AppColors.grey100,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                        color: primaryBlue!.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2)
                  ]
                : null,
          ),
          child: Icon(
            iconData,
            size: 16,
            color: isCompleted ? Colors.white : AppColors.grey400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? primaryBlue : (isCompleted ? AppColors.black87 : AppColors.grey400),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted, Color primaryBlue) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? primaryBlue : AppColors.grey200,
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline, size: 20, color: Color(0xFF4A66FF)),
              SizedBox(width: 8),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name', 'Rohan Sharma'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Email', 'rohan.s@email.com')),
              Expanded(child: _buildInfoRow('Phone', '+91 98765 43210')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Shipping Address', style: TextStyle(fontSize: 12, color: AppColors.grey400)),
          const SizedBox(height: 4),
          const Text(
            '45, MG Road, Indiranagar, Bengaluru, KA 560038, India',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black87)),
      ],
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF4A66FF)),
              SizedBox(width: 8),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildItemRow('assets/images/headphones.png', 'Sony WH-1000XM5 Wir...', 'Midnight Blue • Qty: 1', '₹349.99'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.grey100, height: 1),
          const SizedBox(height: 16),
          _buildItemRow('assets/images/watch.png', 'Tekzo Smart Watch Pro', 'Silver Titanium • Qty: 1', '₹199.00'),
        ],
      ),
    );
  }

  Widget _buildItemRow(String imagePath, String name, String subtitle, String price) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Icon(Icons.image, color: AppColors.grey300), // Placeholder since assets might not exist
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey400),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black87),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryCard(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.payment_outlined, size: 20, color: Color(0xFF4A66FF)),
              SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Subtotal', '₹548.99', false),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping Fee', 'Free', false, isGreen: true),
          const SizedBox(height: 12),
          _buildSummaryRow('Estimated Tax', '₹43.92', false),
          const SizedBox(height: 16),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black87),
              ),
              Text(
                '₹592.91',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.black87 : AppColors.grey500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold || isGreen ? FontWeight.bold : FontWeight.w600,
            color: isGreen ? AppColors.success : AppColors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primaryBlue) {
    return Column(
      children: [
        _buildFullWidthButton(Icons.print_outlined, 'Print Invoice', primaryBlue),
        const SizedBox(height: 12),
        _buildFullWidthButton(Icons.assignment_return_outlined, 'Process Return', primaryBlue),
        const SizedBox(height: 12),
        _buildFullWidthButton(Icons.money_off, 'Issue Refund', primaryBlue),
        const SizedBox(height: 12),
        _buildFullWidthButton(Icons.star_outline, 'Write Review', primaryBlue, onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewScreen()));
        }),
      ],
    );
  }

  Widget _buildFullWidthButton(IconData icon, String label, Color color, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
