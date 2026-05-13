import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';
import 'OrderDetailScreen.dart';
import 'ReviewScreen.dart';
import 'TrackOrderScreen.dart';

/// Order screen displaying active and completed orders with tabs.
class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedTabIndex = 0;

  final List<Order> activeOrders = [
    Order(
      id: 'STKZ-08788',
      productName: 'Leather Backpack',
      imagePath: 'assets/images/backpack.jpg',
      price: '₹1,299.00',
      status: 'PENDING',
      statusColor: AppColors.primary,
      date: 'Oct 20, 2050 • 2 hours',
    ),
    Order(
      id: 'STKZ-08092',
      productName: 'Smart Speaker',
      imagePath: 'assets/images/speaker.jpg',
      price: '₹199.00',
      status: 'PROCESSING',
      statusColor: AppColors.warning,
      date: 'Oct 19, 2050 • 1 hour',
    ),
  ];

  final List<Order> completedOrders = [
    Order(
      id: 'STKZ-07420',
      productName: 'Wireless Headphones',
      imagePath: 'assets/images/headphones.jpg',
      price: '₹349.00',
      status: 'DELIVERED',
      statusColor: AppColors.success,
      date: 'Oct 18, 2050 • 3 hours',
    ),
    Order(
      id: 'STKZ-07100',
      productName: 'USB-C Cable',
      imagePath: 'assets/images/cable.jpg',
      price: '₹29.99',
      status: 'DELIVERED',
      statusColor: AppColors.success,
      date: 'Oct 15, 2050 • 1 day',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: isLoggedIn
            ? Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'My Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedTabIndex = 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 0
                                      ? AppColors.white
                                      : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedTabIndex == 0
                                          ? AppColors.primary
                                          : AppColors.grey600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedTabIndex = 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 1
                                      ? AppColors.white
                                      : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedTabIndex == 1
                                          ? AppColors.primary
                                          : AppColors.grey600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Orders List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _selectedTabIndex == 0
                          ? activeOrders.length
                          : completedOrders.length,
                      itemBuilder: (context, index) {
                        final order = _selectedTabIndex == 0
                            ? activeOrders[index]
                            : completedOrders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _OrderCard(order: order),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please login to view your orders',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          final route = NavigationIndexService.routeForIndex(index);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Row
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.grey100,
                ),
                child: Image.asset(
                  order.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Name
                    Text(
                      order.productName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: order.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.date,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (order.status == 'DELIVERED' ||
                        order.status == 'COMPLETED') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReviewScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrackOrderScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    (order.status == 'DELIVERED' || order.status == 'COMPLETED')
                        ? 'Reviews'
                        : 'Track Order',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderDetailScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.grey300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Buy Again Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.grey300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Buy Again',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String id;
  final String productName;
  final String imagePath;
  final String price;
  final String status;
  final Color statusColor;
  final String date;

  Order({
    required this.id,
    required this.productName,
    required this.imagePath,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.date,
  });
}
