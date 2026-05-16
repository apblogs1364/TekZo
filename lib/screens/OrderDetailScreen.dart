import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'ReviewScreen.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderDocId;

  const OrderDetailScreen({Key? key, required this.orderDocId})
    : super(key: key);

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
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() ?? {};
                    final orderNumber =
                        data['orderNumber']?.toString() ?? orderDocId;
                    final placedOn = _formatDate(data['createdAt']);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black87,
                          ),
                        ),
                        Text(
                          placedOn.isEmpty
                              ? 'Placed recently'
                              : 'Placed on $placedOn',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() ?? {};
                  final status = (data['orderStatus'] ?? 'PROCESSING')
                      .toString()
                      .toUpperCase();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderDocId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load order details'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};
          final items =
              (data['items'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ??
              <Map<String, dynamic>>[];
          final subTotal = _asDouble(data['subTotal'] ?? data['subtotal']);
          final discountAmount = _asDouble(data['discountAmount']);
          final shippingCost = _asDouble(data['shippingCost']);
          final totalAmount = _asDouble(data['totalAmount'] ?? data['total']);
          final customerName =
              data['userName']?.toString() ??
              data['customerName']?.toString() ??
              'Customer';
          final userEmail = data['userEmail']?.toString() ?? '';
          final userPhone = data['userPhone']?.toString() ?? '';
          final address =
              data['shippingAddress']?.toString() ??
              data['address']?.toString() ??
              'Not available';
          final status = data['orderStatus']?.toString() ?? 'PROCESSING';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderProgressCard(primaryBlue, status),
                const SizedBox(height: 16),
                _buildCustomerInfoCard(
                  customerName,
                  userEmail,
                  userPhone,
                  address,
                ),
                const SizedBox(height: 16),
                _buildOrderItemsCard(items),
                const SizedBox(height: 16),
                _buildPaymentSummaryCard(
                  primaryBlue,
                  subTotal,
                  discountAmount,
                  shippingCost,
                  totalAmount,
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context, primaryBlue),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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

  Widget _buildOrderProgressCard(Color primaryBlue, String orderStatus) {
    final normalized = orderStatus.toUpperCase();
    final isCompleted = normalized == 'DELIVERED' || normalized == 'COMPLETED';

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
        children: [
          Row(
            children: [
              _buildProgressDot(true, primaryBlue),
              _buildProgressLine(true, primaryBlue),
              _buildProgressDot(true, primaryBlue),
              _buildProgressLine(isCompleted, primaryBlue),
              _buildProgressDot(isCompleted, primaryBlue),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ordered',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
              Text(
                'Shipped',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
              Text(
                'Delivered',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(bool active, Color primaryBlue) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? primaryBlue : AppColors.grey200,
      ),
    );
  }

  Widget _buildProgressLine(bool active, Color primaryBlue) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? primaryBlue : AppColors.grey200,
      ),
    );
  }

  Widget _buildCustomerInfoCard(
    String customerName,
    String userEmail,
    String userPhone,
    String address,
  ) {
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
          const Row(
            children: [
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
          _buildInfoRow('Name', customerName),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Email', userEmail)),
              Expanded(child: _buildInfoRow('Phone', userPhone)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Shipping Address',
            style: TextStyle(fontSize: 12, color: AppColors.grey400),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(List<Map<String, dynamic>> items) {
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
          const Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: Color(0xFF4A66FF),
              ),
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
          if (items.isEmpty)
            const Text(
              'No items found',
              style: TextStyle(color: AppColors.grey500),
            )
          else
            ...items.map((item) {
              final name =
                  item['productName']?.toString() ??
                  item['name']?.toString() ??
                  'Product';
              final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
              final variant = item['variant']?.toString() ?? '';
              final price = _asDouble(
                item['price'] ?? item['discountedPrice'] ?? item['unitPrice'],
              );
              final imageUrl =
                  item['productImage']?.toString() ??
                  item['image']?.toString() ??
                  '';

              return Column(
                children: [
                  _buildItemRow(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'assets/images/placeholder.png',
                    name,
                    '${variant.isNotEmpty ? '$variant • ' : ''}Qty: $quantity',
                    '₹${price.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
    Color primaryBlue,
    double subTotal,
    double discountAmount,
    double shippingCost,
    double totalAmount,
  ) {
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
          const Row(
            children: [
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
          _buildSummaryRow(
            'Subtotal',
            '₹${subTotal.toStringAsFixed(2)}',
            false,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Shipping Fee',
            shippingCost == 0 ? 'Free' : '₹${shippingCost.toStringAsFixed(2)}',
            false,
            isGreen: shippingCost == 0,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Discount',
            '-₹${discountAmount.toStringAsFixed(2)}',
            false,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey400),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(
    String imageUrl,
    String title,
    String subtitle,
    String price,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
              : Image.asset(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.black87,
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.grey100,
      child: const Icon(Icons.image_outlined, color: AppColors.grey400),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isBold, {
    bool isGreen = false,
  }) {
    final color = isGreen ? Colors.green : AppColors.black87;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: AppColors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primaryBlue) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewScreen()),
              );
            },
            child: const Text('Rate Order'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal().toString();
    }
    if (value is DateTime) {
      return value.toLocal().toString();
    }
    return '';
  }
}
