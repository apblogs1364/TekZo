import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminOrderDetailScreen.dart';
import 'AdminReturnOrderScreen.dart';

class AdminOrderManageScreen extends StatefulWidget {
  const AdminOrderManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderManageScreen> createState() => _AdminOrderManageScreenState();
}

class _AdminOrderManageScreenState extends State<AdminOrderManageScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Orders',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Returned',
  ];

  String _activeFilter = 'All Orders';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
  }

  Future<List<_OrderRecord>> _loadOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    return Future.wait(
      docs.map((doc) async {
        final data = doc.data();
        final userId = data['userId']?.toString() ?? '';
        final userDoc = userId.isEmpty
            ? null
            : await _db.collection('users').doc(userId).get();
        final itemsSnapshot = await doc.reference.collection('items').get();
        final items = await Future.wait(
          itemsSnapshot.docs.map((itemDoc) async {
            final itemData = itemDoc.data();
            final productId = itemData['productId']?.toString() ?? '';
            final productDoc = productId.isEmpty
                ? null
                : await _db.collection('products').doc(productId).get();
            final productData = productDoc?.data();
            return _OrderItemRecord.fromSources(
              itemDoc.id,
              itemData,
              productData,
            );
          }),
        );
        return _OrderRecord.fromSources(doc.id, data, userDoc?.data(), items);
      }),
    );
  }

  Future<List<_OrderRecord>> _loadReturns() async {
    final db = _db;
    final snap = await db.collection('returns').get();
    return Future.wait(
      snap.docs.map((doc) async {
        final data = doc.data();
        final userId = data['userId']?.toString() ?? '';
        final userDoc = userId.isEmpty
            ? null
            : await db.collection('users').doc(userId).get();
        return _OrderRecord.fromReturnSources(doc.id, data, userDoc?.data());
      }),
    );
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
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
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    );
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
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
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return FutureBuilder<List<List<_OrderRecord>>>(
          future: Future.wait([_loadOrders(docs), _loadReturns()]),
          builder: (context, enrichedSnapshot) {
            if (enrichedSnapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load orders',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            if (enrichedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              );
            }
            final lists =
                enrichedSnapshot.data ?? [<_OrderRecord>[], <_OrderRecord>[]];
            final orders = <_OrderRecord>[];
            if (lists.isNotEmpty) orders.addAll(lists[0]);
            if (lists.length > 1) orders.addAll(lists[1]);
            final filteredOrders = orders.where((order) {
              final matchesSearch =
                  _searchQuery.isEmpty || order.matches(_searchQuery);
              final active = _activeFilter.toLowerCase();
              final matchesFilter =
                  _activeFilter == 'All Orders' ||
                  (active == 'returned'
                      ? (order.isReturn ||
                            order.orderStatus.toLowerCase() == 'returned')
                      : order.orderStatus.toLowerCase() == active);
              return matchesSearch && matchesFilter;
            }).toList();

            if (filteredOrders.isEmpty) {
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
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: filteredOrders[index]);
              },
            );
          },
        );
      },
    );
  }
}

class _OrderRecord {
  final String id;
  final String orderNumber;
  final String userId;
  final String userName;
  final String userEmail;
  final bool isReturn;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String trackingNumber;
  final DateTime createdAt;
  final int discountAmount;
  final int shippingCost;
  final int subTotal;
  final int totalAmount;
  final List<_OrderItemRecord> items;

  const _OrderRecord({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.isReturn = false,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.trackingNumber,
    required this.createdAt,
    required this.discountAmount,
    required this.shippingCost,
    required this.subTotal,
    required this.totalAmount,
    required this.items,
  });

  factory _OrderRecord.fromSources(
    String id,
    Map<String, dynamic> data,
    Map<String, dynamic>? userData,
    List<_OrderItemRecord> items,
  ) {
    final firstName = userData?['firstName']?.toString() ?? '';
    final lastName = userData?['lastName']?.toString() ?? '';
    final nameParts = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).toList();
    final fallbackName =
        userData?['name']?.toString() ??
        userData?['userName']?.toString() ??
        '';
    final userName = nameParts.isNotEmpty ? nameParts.join(' ') : fallbackName;
    final userEmail = userData?['email']?.toString() ?? '';

    return _OrderRecord(
      id: id,
      orderNumber: data['orderNumber']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: userName,
      userEmail: userEmail,
      isReturn: false,
      orderStatus: _stringField(data['orderStatus']) ?? 'Pending',
      paymentStatus: _stringField(data['paymentStatus']) ?? 'Pending',
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      trackingNumber: data['trackingNumber']?.toString() ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      discountAmount: _parseInt(data['discountAmount']),
      shippingCost: _parseInt(data['shippingCost']),
      subTotal: _parseInt(data['subTotal']),
      totalAmount: _parseInt(data['totalAmount']),
      items: items,
    );
  }

  factory _OrderRecord.fromReturnSources(
    String id,
    Map<String, dynamic> data,
    Map<String, dynamic>? userData,
  ) {
    final firstName = userData?['firstName']?.toString() ?? '';
    final lastName = userData?['lastName']?.toString() ?? '';
    final nameParts = [
      firstName,
      lastName,
    ].where((p) => p.trim().isNotEmpty).toList();
    final fallbackName =
        userData?['name']?.toString() ??
        userData?['userName']?.toString() ??
        '';
    final userName = nameParts.isNotEmpty ? nameParts.join(' ') : fallbackName;
    final userEmail = userData?['email']?.toString() ?? '';

    return _OrderRecord(
      id: id,
      orderNumber: data['orderId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: userName,
      userEmail: userEmail,
      isReturn: true,
      orderStatus: data['status']?.toString() ?? 'Returned',
      paymentStatus: '',
      paymentMethod: '',
      trackingNumber: '',
      createdAt: _parseDateTime(data['createdAt']),
      discountAmount: 0,
      shippingCost: 0,
      subTotal: 0,
      totalAmount: _parseInt(data['refundAmount']),
      items: [
        _OrderItemRecord(
          id: data['productId']?.toString() ?? '',
          productId: data['productId']?.toString() ?? '',
          productName: '',
          productImage: '',
          quantity: 1,
          price: _parseInt(data['refundAmount']),
        ),
      ],
    );
  }

  bool matches(String query) {
    final haystack = [
      orderNumber,
      userId,
      userName,
      userEmail,
      orderStatus,
      paymentStatus,
      paymentMethod,
      trackingNumber,
      _formatDate(createdAt),
      totalAmount.toString(),
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  static String? _stringField(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }
}

class _OrderItemRecord {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final int price;

  const _OrderItemRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  factory _OrderItemRecord.fromSources(
    String id,
    Map<String, dynamic> data,
    Map<String, dynamic>? productData,
  ) {
    return _OrderItemRecord(
      id: id,
      productId: data['productId']?.toString() ?? '',
      productName:
          data['productName']?.toString() ??
          productData?['name']?.toString() ??
          '',
      productImage:
          data['productImage']?.toString() ??
          productData?['productImage']?.toString() ??
          '',
      quantity: _parseInt(data['quantity']),
      price: _parseInt(data['price']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderRecord order;
  static const Color _accentBlue = Color(0xFF4C6FFF);

  const _OrderCard({Key? key, required this.order}) : super(key: key);

  Color get _statusBg {
    switch (order.orderStatus.toLowerCase()) {
      case 'processing':
        return const Color(0xFFEEF2FF);
      case 'shipped':
        return const Color(0xFFDCFCE7);
      case 'delivered':
        return const Color(0xFFF0FDF4);
      case 'cancelled':
      case 'returned':
        return const Color(0xFFFFE4E6);
      case 'pending':
        return const Color(0xFFFFF7ED);
      default:
        return AppColors.grey100;
    }
  }

  Color get _statusColor {
    switch (order.orderStatus.toLowerCase()) {
      case 'processing':
        return _accentBlue;
      case 'shipped':
        return AppColors.success;
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'cancelled':
      case 'returned':
        return AppColors.danger;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }

  String _formatCurrency(int value) {
    final text = value.toString();
    return '₹${_addThousandsSeparators(text)}';
  }

  String _addThousandsSeparators(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final customerInitials = _buildInitials(order.userName);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey400,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.orderStatus.toUpperCase(),
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
          Text(
            order.orderNumber.isNotEmpty ? order.orderNumber : order.id,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _customerColor(order.userName),
                child: Text(
                  customerInitials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                      order.userName.isNotEmpty
                          ? order.userName
                          : 'Unknown Customer',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
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
                    _formatCurrency(order.totalAmount),
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
                  if (order.isReturn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminReturnOrderScreen(returnDocId: order.id),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminOrderDetailScreen(orderDocId: order.id),
                      ),
                    );
                  }
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

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color _customerColor(String name) {
    final colors = [
      const Color(0xFF5B8EA6),
      const Color(0xFFD4A574),
      const Color(0xFF7B8EA0),
      const Color(0xFFE8A87C),
      const Color(0xFF6B9E8A),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }
}
