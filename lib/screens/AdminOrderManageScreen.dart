import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminOrderDetailScreen.dart';

class AdminOrderManageScreen extends StatefulWidget {
  const AdminOrderManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderManageScreen> createState() => _AdminOrderManageScreenState();
}

class _AdminOrderManageScreenState extends State<AdminOrderManageScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);

  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All Orders';

  final List<String> _filters = ['All Orders', 'Processing', 'Shipped', 'Pending'];

  final List<_Order> _allOrders = [
    _Order(
      date: 'OCT 24, 2026',
      orderId: '#ORD-7742',
      customerName: 'Arjun Sharma',
      avatarColor: Color(0xFF5B8EA6),
      avatarInitials: 'AS',
      totalAmount: '₹1,24,000.00',
      status: 'Processing',
    ),
    _Order(
      date: 'OCT 23, 2026',
      orderId: '#ORD-7741',
      customerName: 'Priya Patel',
      avatarColor: Color(0xFFD4A574),
      avatarInitials: 'PP',
      totalAmount: '₹89,950.00',
      status: 'Shipped',
    ),
    _Order(
      date: 'OCT 22, 2026',
      orderId: '#ORD-7738',
      customerName: 'Vikram Singh',
      avatarColor: Color(0xFF7B8EA0),
      avatarInitials: 'VS',
      totalAmount: '₹2,45,000.00',
      status: 'Pending',
    ),
    _Order(
      date: 'OCT 21, 2026',
      orderId: '#ORD-7735',
      customerName: 'Ananya Reddy',
      avatarColor: Color(0xFFE8A87C),
      avatarInitials: 'AR',
      totalAmount: '₹56,500.00',
      status: 'Shipped',
    ),
    _Order(
      date: 'OCT 20, 2026',
      orderId: '#ORD-7730',
      customerName: 'Rohan Gupta',
      avatarColor: Color(0xFF6B9E8A),
      avatarInitials: 'RG',
      totalAmount: '₹1,08,000.00',
      status: 'Processing',
    ),
  ];

  late List<_Order> _filteredOrders;

  @override
  void initState() {
    super.initState();
    _filteredOrders = _allOrders;
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final matchesSearch = query.isEmpty ||
            o.orderId.toLowerCase().contains(query) ||
            o.customerName.toLowerCase().contains(query);
        final matchesFilter =
            _activeFilter == 'All Orders' || o.status == _activeFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(child: _buildOrderList()),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Back button in a light circle
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.black,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Manage Orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          // Notification bell with badge
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey200.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.black,
                  size: 20,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.grey400, size: 20),
                  hintText: 'Search Order ID or Customer',
                  hintStyle: TextStyle(color: AppColors.grey400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey200.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_outlined,
              color: AppColors.grey500,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Tabs ──────────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isActive = filter == _activeFilter;
            return GestureDetector(
              onTap: () => _setFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _accentBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _accentBlue : AppColors.grey200,
                    width: 1.2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _accentBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.white : AppColors.grey500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Order List ───────────────────────────────────────────────────────────────

  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: _filteredOrders[index]);
      },
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _Order {
  final String date;
  final String orderId;
  final String customerName;
  final Color avatarColor;
  final String avatarInitials;
  final String totalAmount;
  final String status; // 'Processing' | 'Shipped' | 'Pending'

  const _Order({
    required this.date,
    required this.orderId,
    required this.customerName,
    required this.avatarColor,
    required this.avatarInitials,
    required this.totalAmount,
    required this.status,
  });
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _Order order;
  static const Color _accentBlue = Color(0xFF4C6FFF);

  const _OrderCard({Key? key, required this.order}) : super(key: key);

  Color get _statusBg {
    switch (order.status) {
      case 'Processing':
        return const Color(0xFFEEF2FF);
      case 'Shipped':
        return const Color(0xFFDCFCE7);
      case 'Pending':
        return const Color(0xFFFFF7ED);
      default:
        return AppColors.grey100;
    }
  }

  Color get _statusColor {
    switch (order.status) {
      case 'Processing':
        return _accentBlue;
      case 'Shipped':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date + Status badge ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey400,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Order ID ────────────────────────────────────────────────────
          Text(
            order.orderId,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),

          // ── Customer row ────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: order.avatarColor,
                child: Text(
                  order.avatarInitials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Divider ─────────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // ── Total amount + Details link ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.totalAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrderDetailScreen(
                        orderId: order.orderId,
                        orderDate: order.date,
                        customerName: order.customerName,
                        status: order.status,
                        totalAmount: order.totalAmount,
                        avatarColor: order.avatarColor,
                        avatarInitials: order.avatarInitials,
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4C6FFF),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF4C6FFF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
