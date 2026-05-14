import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderDocId;

  const AdminOrderDetailScreen({Key? key, required this.orderDocId})
    : super(key: key);

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSavingStatus = false;
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _userData;
  List<_OrderItemRecord> _items = [];
  String _currentStatus = 'Pending';

  final List<String> _statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Returned',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final orderDoc = await _db
          .collection('orders')
          .doc(widget.orderDocId)
          .get();
      final orderData = orderDoc.data();
      if (orderData == null) {
        throw Exception('Order not found');
      }

      final userId = orderData['userId']?.toString() ?? '';
      final userDoc = userId.isEmpty
          ? null
          : await _db.collection('users').doc(userId).get();

      final itemsSnapshot = await orderDoc.reference.collection('items').get();
      final items = await Future.wait(
        itemsSnapshot.docs.map((itemDoc) async {
          final itemData = itemDoc.data();
          final productId = itemData['productId']?.toString() ?? '';
          final productDoc = productId.isEmpty
              ? null
              : await _db.collection('products').doc(productId).get();
          return _OrderItemRecord.fromSources(
            itemDoc.id,
            itemData,
            productDoc?.data(),
          );
        }),
      );

      if (mounted) {
        setState(() {
          _orderData = orderData;
          _userData = userDoc?.data();
          _items = items;
          _currentStatus = _normalizeStatus(
            orderData['orderStatus']?.toString() ?? 'Pending',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading order: $e')));
      }
    }
  }

  String _normalizeStatus(String value) {
    final status = value.trim();
    if (status.isEmpty) return 'Pending';
    final normalized =
        status[0].toUpperCase() + status.substring(1).toLowerCase();
    return _statusOptions.contains(normalized) ? normalized : 'Pending';
  }

  Future<void> _updateStatus(String status) async {
    if (status == _currentStatus) return;
    setState(() {
      _currentStatus = status;
      _isSavingStatus = true;
    });

    try {
      await _db.collection('orders').doc(widget.orderDocId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order status updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      setState(() {
        _currentStatus = _normalizeStatus(
          _orderData?['orderStatus']?.toString() ?? 'Pending',
        );
      });
    } finally {
      if (mounted) setState(() => _isSavingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          _buildProgressCard(),
                          const SizedBox(height: 14),
                          _buildCustomerInfoCard(),
                          const SizedBox(height: 14),
                          _buildOrderItemsCard(),
                          const SizedBox(height: 14),
                          _buildPaymentSummaryCard(),
                          const SizedBox(height: 14),
                          _buildUpdateStatusCard(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const AdminBottomNavigationBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final orderNumber =
        _orderData?['orderNumber']?.toString() ?? widget.orderDocId;
    final createdAt = _formatDate(_parseDateTime(_orderData?['createdAt']));

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $orderNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Placed on $createdAt',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBadgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentStatus.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _statusBadgeColor,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER PROGRESS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _accentBlue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIdx = i ~/ 2;
                final lineActive =
                    _isDone(stepIdx) &&
                    (_isDone(stepIdx + 1) || _isActive(stepIdx + 1));
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: lineActive ? _accentBlue : AppColors.grey200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
              final idx = i ~/ 2;
              return _buildStepNode(idx);
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) return const Expanded(child: SizedBox());
              final idx = i ~/ 2;
              return SizedBox(
                width: 52,
                child: Text(
                  _steps[idx]['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: (_isDone(idx) || _isActive(idx))
                        ? _accentBlue
                        : AppColors.grey400,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int idx) {
    final done = _isDone(idx);
    final active = _isActive(idx);
    final bg = (done || active) ? _accentBlue : AppColors.grey200;

    final iconData = done ? Icons.check : _steps[idx]['icon'] as IconData;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: (done || active)
            ? [
                BoxShadow(
                  color: _accentBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(iconData, color: AppColors.white, size: 16),
    );
  }

  Widget _buildCustomerInfoCard() {
    final name = _customerName();
    final email = _customerEmail();
    final phone = _customerPhone();
    final address = _customerAddress();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: _accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoLabel('Name'),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoLabel('Email'),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoLabel('Phone'),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoLabel('Shipping Address'),
          Text(
            address,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: _accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_items.isEmpty)
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return Column(
                  children: [
                    _buildOrderItem(item: item),
                    if (index != _items.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({required _OrderItemRecord item}) {
    return Row(
      children: [
        _buildItemImage(item.productImage),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName.isNotEmpty ? item.productName : item.productId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Qty: ${item.quantity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatCurrency(item.lineTotal),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(String imagePath) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.grey400,
        size: 24,
      ),
    );

    final normalizedPath = _normalizeImagePath(imagePath);
    if (normalizedPath.isEmpty) return placeholder;

    if (normalizedPath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          normalizedPath,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      );
    }

    final file = File(normalizedPath);
    if (!file.existsSync()) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        file,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }

  String _normalizeImagePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('file://')) {
      return Uri.parse(trimmed).toFilePath();
    }
    if (trimmed.startsWith('file:/')) {
      return Uri.parse(trimmed).toFilePath();
    }
    return trimmed;
  }

  Widget _buildPaymentSummaryCard() {
    final subtotal = _intValue(_orderData?['subTotal']);
    final shippingCost = _intValue(_orderData?['shippingCost']);
    final discountAmount = _intValue(_orderData?['discountAmount']);
    final totalAmount = _intValue(_orderData?['totalAmount']);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: _accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _paymentRow(
            'Subtotal',
            _formatCurrency(subtotal),
            valueColor: AppColors.black,
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Shipping Cost',
            _formatCurrency(shippingCost),
            valueColor: AppColors.black,
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Discount',
            _formatCurrency(discountAmount),
            valueColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Payment Method',
            _paymentMethod(),
            valueColor: AppColors.black,
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Payment Status',
            _paymentStatus(),
            valueColor: _paymentStatusColor(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Tracking Number',
            _trackingNumber(),
            valueColor: AppColors.grey500,
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {required Color valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.grey500,
            fontWeight: FontWeight.w400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateStatusCard() {
    return _card(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.grey400,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
          onChanged: _isSavingStatus
              ? null
              : (val) {
                  if (val != null) {
                    _updateStatus(val);
                  }
                },
          items: _statusOptions
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    'Update Status: $status',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _infoLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.grey400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _customerName() {
    final firstName = _userData?['firstName']?.toString() ?? '';
    final lastName = _userData?['lastName']?.toString() ?? '';
    final fullName = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).toList().join(' ');
    if (fullName.isNotEmpty) return fullName;
    return _userData?['name']?.toString() ??
        _userData?['userName']?.toString() ??
        'Unknown Customer';
  }

  String _customerEmail() {
    return _userData?['email']?.toString() ?? 'N/A';
  }

  String _customerPhone() {
    return _userData?['phone']?.toString() ?? 'N/A';
  }

  String _customerAddress() {
    final location = _userData?['location']?.toString() ?? '';
    final city = _userData?['city']?.toString() ?? '';
    final state = _userData?['state']?.toString() ?? '';
    final parts = [
      location,
      city,
      state,
    ].where((part) => part.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return 'N/A';
  }

  String _paymentMethod() {
    return _orderData?['paymentMethod']?.toString() ?? 'N/A';
  }

  String _paymentStatus() {
    return _orderData?['paymentStatus']?.toString() ?? 'N/A';
  }

  Color _paymentStatusColor() {
    switch (_paymentStatus().toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'refunded':
        return AppColors.danger;
      default:
        return AppColors.grey500;
    }
  }

  String _trackingNumber() {
    return _orderData?['trackingNumber']?.toString() ?? 'N/A';
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatCurrency(int value) {
    return '₹${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
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

  int get _activeStep {
    switch (_currentStatus) {
      case 'Pending':
        return 0;
      case 'Processing':
        return 2;
      case 'Shipped':
        return 3;
      case 'Delivered':
        return 4;
      default:
        return 0;
    }
  }

  bool _isDone(int idx) => idx < _activeStep;
  bool _isActive(int idx) => idx == _activeStep;

  Color get _statusBadgeBg {
    switch (_currentStatus) {
      case 'Processing':
        return const Color(0xFFEEF2FF);
      case 'Shipped':
        return const Color(0xFFDCFCE7);
      case 'Pending':
        return const Color(0xFFFFF7ED);
      case 'Delivered':
        return const Color(0xFFF0FDF4);
      case 'Cancelled':
      case 'Returned':
        return const Color(0xFFFFE4E6);
      default:
        return AppColors.grey100;
    }
  }

  Color get _statusBadgeColor {
    switch (_currentStatus) {
      case 'Processing':
        return _accentBlue;
      case 'Shipped':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Delivered':
        return const Color(0xFF16A34A);
      case 'Cancelled':
      case 'Returned':
        return AppColors.danger;
      default:
        return AppColors.grey500;
    }
  }

  static const List<Map<String, dynamic>> _steps = [
    {'label': 'Placed', 'icon': Icons.check_circle_outline},
    {'label': 'Confirmed', 'icon': Icons.verified_outlined},
    {'label': 'Processing', 'icon': Icons.sync},
    {'label': 'Shipped', 'icon': Icons.local_shipping_outlined},
    {'label': 'Delivered', 'icon': Icons.inventory_2_outlined},
  ];
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
    final productImage =
        data['productImage']?.toString() ??
        data['productImageUrl']?.toString() ??
        data['imageUrl']?.toString() ??
        data['image']?.toString() ??
        productData?['productImage']?.toString() ??
        productData?['productImageUrl']?.toString() ??
        productData?['imageUrl']?.toString() ??
        productData?['image']?.toString() ??
        '';

    final productName =
        data['productName']?.toString() ??
        productData?['name']?.toString() ??
        '';

    return _OrderItemRecord(
      id: id,
      productId: data['productId']?.toString() ?? '',
      productName: productName,
      productImage: productImage,
      quantity: _parseInt(data['quantity']),
      price: _parseInt(data['price']),
    );
  }

  int get lineTotal => price * quantity;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
