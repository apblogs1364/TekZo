import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminReturnOrderScreen extends StatefulWidget {
  final String returnDocId;

  const AdminReturnOrderScreen({Key? key, required this.returnDocId})
    : super(key: key);

  @override
  State<AdminReturnOrderScreen> createState() => _AdminReturnOrderScreenState();
}

class _AdminReturnOrderScreenState extends State<AdminReturnOrderScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSavingStatus = false;
  Map<String, dynamic>? _returnData;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _orderData;
  String _currentStatus = 'Pending';

  final List<String> _statusOptions = ['Requested', 'Rejected', 'Approved'];

  @override
  void initState() {
    super.initState();
    _loadReturn();
  }

  Future<void> _loadReturn() async {
    try {
      final doc = await _db.collection('returns').doc(widget.returnDocId).get();
      final data = doc.data();
      if (data == null) {
        throw Exception('Return not found');
      }

      final userId = data['userId']?.toString() ?? '';
      final orderId = data['orderId']?.toString() ?? '';
      final userDoc = userId.isEmpty
          ? null
          : await _db.collection('users').doc(userId).get();
      final orderDoc = orderId.isEmpty
          ? null
          : await _db.collection('orders').doc(orderId).get();
      final fallbackOrderQuery =
          (orderDoc == null || !orderDoc.exists) && orderId.isNotEmpty
          ? await _db
                .collection('orders')
                .where('orderNumber', isEqualTo: orderId)
                .limit(1)
                .get()
          : null;
      final fallbackOrderDoc =
          (fallbackOrderQuery != null && fallbackOrderQuery.docs.isNotEmpty)
          ? fallbackOrderQuery.docs.first
          : null;

      if (mounted) {
        setState(() {
          _returnData = data;
          _userData = userDoc?.data();
          _orderData = orderDoc?.data() ?? fallbackOrderDoc?.data();
          _currentStatus = _normalizeStatus(
            data['status']?.toString() ?? 'Pending',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading return: $e')));
      }
    }
  }

  String _normalizeStatus(String value) {
    final status = value.trim();
    if (status.isEmpty) return 'Requested';
    final normalized =
        status[0].toUpperCase() + status.substring(1).toLowerCase();
    return _statusOptions.contains(normalized) ? normalized : 'Requested';
  }

  Future<void> _updateStatus(String status) async {
    if (status == _currentStatus) return;
    setState(() {
      _currentStatus = status;
      _isSavingStatus = true;
    });

    try {
      await _db.collection('returns').doc(widget.returnDocId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _returnData = {...?_returnData, 'status': status};
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Return status updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      setState(() {
        _currentStatus = _normalizeStatus(
          _returnData?['status']?.toString() ?? 'Pending',
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
                          _buildReturnSummaryCard(),
                          const SizedBox(height: 14),
                          _buildCustomerInfoCard(),
                          const SizedBox(height: 14),
                          _buildReturnDetailsCard(),
                          const SizedBox(height: 14),
                          _buildRefundSummaryCard(),
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
    final orderId = _returnData?['orderId']?.toString() ?? widget.returnDocId;
    final createdAt = _formatDate(_parseDateTime(_returnData?['createdAt']));

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
                  'Return $orderId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Requested on $createdAt',
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

  Widget _buildReturnSummaryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RETURN SUMMARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _accentBlue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow('Return ID', widget.returnDocId),
          const SizedBox(height: 8),
          _infoRow('Order ID', _returnData?['orderId']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final email = _userData?['email']?.toString() ?? 'N/A';
    final phone = _userData?['phone']?.toString() ?? 'N/A';

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
            _userDisplayName(),
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
        ],
      ),
    );
  }

  Widget _buildReturnDetailsCard() {
    final reason = _returnData?['reason']?.toString() ?? 'N/A';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_return_outlined,
                color: _accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Return Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Current Status', _currentStatus),
          const SizedBox(height: 12),
          _infoLabel('Reason'),
          Text(
            reason,
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

  Widget _buildRefundSummaryCard() {
    final orderTotalAmount = _intValue(_orderData?['totalAmount']);
    final refundAmount = orderTotalAmount > 0
        ? orderTotalAmount
        : _intValue(_returnData?['refundAmount']);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_rupee, color: _accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Refund Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Order Total', _formatCurrency(orderTotalAmount)),
          const SizedBox(height: 8),
          _infoRow('Refund Amount', _formatCurrency(refundAmount)),
        ],
      ),
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

  Widget _infoRow(String label, String value) {
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

  String _userDisplayName() {
    final first = _userData?['firstName']?.toString() ?? '';
    final last = _userData?['lastName']?.toString() ?? '';
    final full = [
      first,
      last,
    ].where((p) => p.trim().isNotEmpty).toList().join(' ');
    if (full.isNotEmpty) return full;
    return _userData?['name']?.toString() ??
        _userData?['userName']?.toString() ??
        'Unknown';
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

  Color get _statusBadgeBg {
    switch (_currentStatus.toLowerCase()) {
      case 'approved':
        return const Color(0xFFEEF2FF);
      case 'refunded':
      case 'completed':
        return const Color(0xFFF0FDF4);
      case 'pending':
        return const Color(0xFFFFF7ED);
      case 'rejected':
        return const Color(0xFFFFE4E6);
      default:
        return AppColors.grey100;
    }
  }

  Color get _statusBadgeColor {
    switch (_currentStatus.toLowerCase()) {
      case 'approved':
        return _accentBlue;
      case 'refunded':
      case 'completed':
        return const Color(0xFF16A34A);
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.grey500;
    }
  }
}
