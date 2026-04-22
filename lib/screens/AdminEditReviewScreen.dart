import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminEditReviewScreen extends StatefulWidget {
  final String customerName;
  final String customerEmail;
  final String productName;
  final String sku;
  final int rating;
  final String reviewText;
  final String status;
  final Color avatarColor;
  final String avatarInitials;

  const AdminEditReviewScreen({
    Key? key,
    required this.customerName,
    required this.customerEmail,
    required this.productName,
    required this.sku,
    required this.rating,
    required this.reviewText,
    required this.status,
    required this.avatarColor,
    required this.avatarInitials,
  }) : super(key: key);

  @override
  State<AdminEditReviewScreen> createState() => _AdminEditReviewScreenState();
}

class _AdminEditReviewScreenState extends State<AdminEditReviewScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);

  late int _rating;
  late TextEditingController _reviewController;
  late TextEditingController _responseController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Published', 'Flagged'];

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _reviewController = TextEditingController(text: widget.reviewText);
    _responseController = TextEditingController(
      text:
          'Hi ${widget.customerName.split(' ').first}! We\'re thrilled to hear you\'re enjoying the ${widget.productName}. '
          'Your feedback means a lot to us and helps us improve. Thank you for the support!',
    );
    _selectedStatus =
        _statusOptions.contains(widget.status) ? widget.status : 'Published';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _buildCustomerInfoCard(),
                    const SizedBox(height: 14),
                    _buildProductInfoCard(),
                    const SizedBox(height: 14),
                    _buildRatingCard(),
                    const SizedBox(height: 14),
                    _buildReviewContentCard(),
                    const SizedBox(height: 14),
                    _buildDisplayStatusCard(),
                    const SizedBox(height: 14),
                    _buildOfficialResponseCard(),
                    const SizedBox(height: 20),
                    _buildDeleteButton(),
                    const SizedBox(height: 10),
                    const Text(
                      'This action cannot be undone. All review data will be erased\nfrom our database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
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

  // ── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                color: AppColors.grey600, size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Edit Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review saved!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Customer Information ────────────────────────────────────────────────────

  Widget _buildCustomerInfoCard() {
    return _card(
      sectionLabel: 'CUSTOMER INFORMATION',
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: widget.avatarColor,
            child: Text(
              widget.avatarInitials,
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
              Text(
                widget.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.customerEmail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Product Information ─────────────────────────────────────────────────────

  Widget _buildProductInfoCard() {
    return _card(
      sectionLabel: 'PRODUCT INFORMATION',
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.headphones,
                color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'SKU: ${widget.sku}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Rating ──────────────────────────────────────────────────────────────────

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Rating',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: _accentBlue,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Review Content ──────────────────────────────────────────────────────────

  Widget _buildReviewContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Content',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _reviewController,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                hintText: 'Review text...',
                hintStyle: TextStyle(color: AppColors.grey400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Display Status ──────────────────────────────────────────────────────────

  Widget _buildDisplayStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.grey400, size: 20),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              )),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Official Response ───────────────────────────────────────────────────────

  Widget _buildOfficialResponseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_clock_outlined,
                  color: _accentBlue, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Official Response',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _responseController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey700,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Write an official response...',
              hintStyle: TextStyle(color: AppColors.grey400),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete Button ───────────────────────────────────────────────────────────

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => _showDeleteDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            SizedBox(width: 10),
            Text(
              'Delete Review Permanently',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'This action cannot be undone. All review data will be permanently erased.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grey500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review deleted permanently')),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // ── Shared helper ────────────────────────────────────────────────────────────

  Widget _card({required String sectionLabel, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.grey400,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
