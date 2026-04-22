import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final String customerName;
  final String status;
  final String totalAmount;
  final Color avatarColor;
  final String avatarInitials;

  const AdminOrderDetailScreen({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.avatarColor,
    required this.avatarInitials,
  }) : super(key: key);

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  late String _currentStatus;

  final List<String> _statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
  ];

  // Step definitions for progress tracker
  static const List<Map<String, dynamic>> _steps = [
    {'label': 'Placed',     'icon': Icons.check_circle_outline},
    {'label': 'Confirmed',  'icon': Icons.verified_outlined},
    {'label': 'Processing', 'icon': Icons.sync},
    {'label': 'Shipped',    'icon': Icons.local_shipping_outlined},
    {'label': 'Delivered',  'icon': Icons.inventory_2_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  /// Returns which step index is "active" (current) based on status
  int get _activeStep {
    switch (_currentStatus) {
      case 'Pending':     return 0;
      case 'Processing':  return 2;
      case 'Shipped':     return 3;
      case 'Delivered':   return 4;
      default:            return 0;
    }
  }

  /// Steps with index < _activeStep are "done"; == _activeStep is "active"
  bool _isDone(int idx)   => idx < _activeStep;
  bool _isActive(int idx) => idx == _activeStep;

  Color get _statusBadgeBg {
    switch (_currentStatus) {
      case 'Processing': return const Color(0xFFEEF2FF);
      case 'Shipped':    return const Color(0xFFDCFCE7);
      case 'Pending':    return const Color(0xFFFFF7ED);
      case 'Delivered':  return const Color(0xFFF0FDF4);
      default:           return AppColors.grey100;
    }
  }

  Color get _statusBadgeColor {
    switch (_currentStatus) {
      case 'Processing': return _accentBlue;
      case 'Shipped':    return AppColors.success;
      case 'Pending':    return AppColors.warning;
      case 'Delivered':  return const Color(0xFF16A34A);
      default:           return AppColors.grey500;
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Placed on ${widget.orderDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
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

  // ── Order Progress ──────────────────────────────────────────────────────────

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
                // Connector line
                final stepIdx = i ~/ 2; // line between stepIdx and stepIdx+1
                final lineActive = _isDone(stepIdx) && (_isDone(stepIdx + 1) || _isActive(stepIdx + 1));
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: lineActive ? _accentBlue : AppColors.grey200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              } else {
                final idx = i ~/ 2;
                return _buildStepNode(idx);
              }
            }),
          ),
          const SizedBox(height: 8),
          // Labels row
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) return const Expanded(child: SizedBox());
              final idx = i ~/ 2;
              return SizedBox(
                width: 52,
                child: Text(
                  _steps[idx]['label'],
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
    final done   = _isDone(idx);
    final active = _isActive(idx);

    final bg   = (done || active) ? _accentBlue : AppColors.grey200;
    final iconColor = AppColors.white;

    IconData iconData;
    if (done) {
      iconData = Icons.check;
    } else {
      iconData = _steps[idx]['icon'] as IconData;
    }

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
      child: Icon(iconData, color: iconColor, size: 16),
    );
  }

  // ── Customer Information ────────────────────────────────────────────────────

  Widget _buildCustomerInfoCard() {
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

          // Name
          _infoLabel('Name'),
          Text(
            widget.customerName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Email + Phone side by side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoLabel('Email'),
                    Text(
                      _emailFor(widget.customerName),
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
                      '+91 98765 43210',
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

          // Shipping Address
          _infoLabel('Shipping Address'),
          const Text(
            '123 MG Road, Indiranagar,\nBengaluru, Karnataka 560038, India',
            style: TextStyle(
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

  // ── Order Items ─────────────────────────────────────────────────────────────

  Widget _buildOrderItemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: _accentBlue, size: 20),
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
          _buildOrderItem(
            icon: Icons.headphones,
            name: 'Tekzo Pro Buds Max',
            variant: 'Midnight Black · Qty: 1',
            price: '₹24,999.00',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _buildOrderItem(
            icon: Icons.watch,
            name: 'Tekzo Smart Watch Pro',
            variant: 'Silver Titanium · Qty: 1',
            price: '₹19,999.00',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required IconData icon,
    required String name,
    required String variant,
    required String price,
  }) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                variant,
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
          price,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  // ── Payment Summary ─────────────────────────────────────────────────────────

  Widget _buildPaymentSummaryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_outlined, color: _accentBlue, size: 20),
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
          _paymentRow('Subtotal',       '₹44,998.00', valueColor: AppColors.black),
          const SizedBox(height: 8),
          _paymentRow('Shipping Fee',   'Free',        valueColor: AppColors.success),
          const SizedBox(height: 8),
          _paymentRow('Estimated Tax',  '₹4,050.00',  valueColor: AppColors.black),
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
                widget.totalAmount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
            ],
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Update Status ───────────────────────────────────────────────────────────

  Widget _buildUpdateStatusCard() {
    return _card(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey400, size: 20),
          hint: Text('Update Status: $_currentStatus'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
          onChanged: (val) {
            if (val != null) setState(() => _currentStatus = val);
          },
          items: _statusOptions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    'Update Status: $s',
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

  String _emailFor(String name) {
    final parts = name.toLowerCase().split(' ');
    if (parts.length >= 2) return '${parts[0]}.${parts[1][0]}@email.com';
    return '${parts[0]}@email.com';
  }
}
