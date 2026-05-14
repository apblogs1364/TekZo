import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminProfileScreen.dart';
import '../widgets/app_name_text.dart';

/// Admin dashboard screen showing stats, quick actions, and recent orders.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  String _totalSales = '₹0';
  String _activeUsers = '0';
  String _newOrders = '0';
  String _totalProducts = '0';
  List<_RecentOrder> _recentOrders = [];
  bool _isLoading = true;

  static const _quickActions = <_QuickAction>[
    _QuickAction(label: 'Manage Product', icon: Icons.add_shopping_cart),
    _QuickAction(label: 'Manage Users', icon: Icons.people),
    _QuickAction(label: 'View Orders', icon: Icons.receipt_long),
    _QuickAction(label: 'Manage Category', icon: Icons.category),
    _QuickAction(label: 'Manage Reviews', icon: Icons.rate_review),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Fetch active users count
      final usersSnapshot = await _db.collection('users').get();
      final int userCount = usersSnapshot.docs.length;

      // Fetch total products count
      final productsSnapshot = await _db.collection('products').get();
      final int productCount = productsSnapshot.docs.length;

      // Listen to orders so dashboard updates live when status changes
      _ordersSub?.cancel();
      _ordersSub = _db
          .collection('orders')
          .snapshots()
          .listen(
            (ordersSnapshot) {
              double totalSales = 0;
              int orderCount = 0;
              List<_RecentOrder> recentOrders = [];

              for (var doc in ordersSnapshot.docs) {
                final data = doc.data();
                totalSales +=
                    (double.tryParse(data['totalAmount']?.toString() ?? '0') ??
                    0);
                orderCount++;
                final status = data['orderStatus']?.toString() ?? 'Pending';
                final statusColor = _getStatusColor(status);
                recentOrders.add(
                  _RecentOrder(
                    product: data['orderNumber']?.toString() ?? 'Order',
                    customer:
                        'Order #${data['orderNumber']?.toString() ?? 'N/A'}',
                    orderId: '#${doc.id.substring(0, 6).toUpperCase()}',
                    price: '₹${data['totalAmount']?.toString() ?? '0'}',
                    status: status,
                    statusColor: statusColor,
                  ),
                );
              }

              if (recentOrders.length > 3) {
                recentOrders = recentOrders.sublist(recentOrders.length - 3);
              }

              if (mounted) {
                setState(() {
                  _totalSales = '₹${(totalSales / 1000).toStringAsFixed(1)}k';
                  _activeUsers = userCount.toString();
                  _newOrders = orderCount.toString();
                  _totalProducts = productCount.toString();
                  _recentOrders = recentOrders;
                  _isLoading = false;
                });
              }
            },
            onError: (e) {
              if (mounted) setState(() => _isLoading = false);
            },
          );
    } catch (e) {
      print('Dashboard fetch error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'shipped':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.grey600;
    }
  }

  void _handleQuickActionTap(String actionLabel) {
    switch (actionLabel) {
      case 'Manage Product':
        Navigator.pushNamed(context, '/admin/products');
        break;
      case 'Manage Users':
        Navigator.pushNamed(context, '/admin/users');
        break;
      case 'View Orders':
        Navigator.pushNamed(context, '/admin/orders');
        break;
      case 'Manage Category':
        Navigator.pushNamed(context, '/admin/categories');
        break;
      case 'Manage Reviews':
        Navigator.pushNamed(context, '/admin/reviews');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: _HeaderInfo()),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 18),
          _buildQuickActions(),
          const SizedBox(height: 22),
          _buildRecentOrders(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              label: 'Total Sales',
              value: _totalSales,
              icon: Icons.monetization_on_outlined,
              iconBackground: AppColors.primary,
              valueColor: AppColors.primaryDark,
            ),
            _StatCard(
              label: 'Active Users',
              value: _activeUsers,
              icon: Icons.person_outline,
              iconBackground: AppColors.warning,
              valueColor: AppColors.grey700,
            ),
            _StatCard(
              label: 'New Orders',
              value: _newOrders,
              icon: Icons.shopping_cart_outlined,
              iconBackground: AppColors.secondary,
              valueColor: AppColors.grey700,
            ),
            _StatCard(
              label: 'Total Products',
              value: _totalProducts,
              icon: Icons.inventory_2_outlined,
              iconBackground: AppColors.success,
              valueColor: AppColors.grey700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickActions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return _QuickActionCard(
                action: action,
                onTap: () {
                  _handleQuickActionTap(action.label);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : _recentOrders.isEmpty
            ? const Center(
                child: Text(
                  'No orders yet',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              )
            : Column(
                children: _recentOrders
                    .map((order) => _RecentOrderTile(order: order))
                    .toList(),
              ),
      ],
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/tekzo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppNameText(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Admin Portal',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBackground;
  final Color valueColor;

  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.6),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBackground, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;

  const _QuickAction({required this.label, required this.icon});
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback? onTap;

  const _QuickActionCard({Key? key, required this.action, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrder {
  final String product;
  final String customer;
  final String orderId;
  final String price;
  final String status;
  final Color statusColor;

  const _RecentOrder({
    required this.product,
    required this.customer,
    required this.orderId,
    required this.price,
    required this.status,
    required this.statusColor,
  });
}

class _RecentOrderTile extends StatelessWidget {
  final _RecentOrder order;

  const _RecentOrderTile({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.grey400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.product,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customer} • ${order.orderId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }
}
