import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminReviewDetailsScreen extends StatefulWidget {
  final String reviewId;

  const AdminReviewDetailsScreen({Key? key, required this.reviewId})
    : super(key: key);

  @override
  State<AdminReviewDetailsScreen> createState() =>
      _AdminReviewDetailsScreenState();
}

class _AdminReviewDetailsScreenState extends State<AdminReviewDetailsScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewTextController = TextEditingController();
  final TextEditingController _createdAtController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  bool _isLoading = true;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    try {
      final doc = await _db.collection('reviews').doc(widget.reviewId).get();
      final data = doc.data();
      if (data != null) {
        _userNameController.text = data['userName']?.toString() ?? '';
        _userIdController.text = data['userId']?.toString() ?? '';
        _productIdController.text = data['productId']?.toString() ?? '';
        _reviewTitleController.text = data['reviewTitle']?.toString() ?? '';
        _reviewTextController.text = data['reviewText']?.toString() ?? '';
        _rating = double.tryParse(data['rating']?.toString() ?? '') ?? 0;
        _ratingController.text = _rating.toStringAsFixed(
          _rating.truncateToDouble() == _rating ? 0 : 1,
        );
        _createdAtController.text = _formatCreatedAt(data['createdAt']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading review: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userIdController.dispose();
    _productIdController.dispose();
    _reviewTitleController.dispose();
    _reviewTextController.dispose();
    _createdAtController.dispose();
    _ratingController.dispose();
    super.dispose();
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
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                          _buildReviewMetaCard(),
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

  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.grey600,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Review Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return _card(
      sectionLabel: 'CUSTOMER INFORMATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'User Name',
            controller: _userNameController,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'User ID',
            controller: _userIdController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return _card(
      sectionLabel: 'PRODUCT INFORMATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Product ID',
            controller: _productIdController,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Review Title',
            controller: _reviewTitleController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

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
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  i < _rating.round() ? Icons.star : Icons.star_border,
                  color: _accentBlue,
                  size: 28,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

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
          _buildMultilineField(
            controller: _reviewTextController,
            hint: 'Review text...',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewMetaCard() {
    return _card(
      sectionLabel: 'REVIEW META',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Created At',
            controller: _createdAtController,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Rating Value',
            controller: _ratingController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _deleteReview,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  Future<void> _deleteReview() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _db.collection('reviews').doc(widget.reviewId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting review: $e')));
    }
  }

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
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        maxLines: 5,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.black,
          height: 1.5,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.grey400),
        ),
      ),
    );
  }

  String _formatCreatedAt(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final day = date.day.toString().padLeft(2, '0');
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
      return '$day ${months[date.month - 1]} ${date.year}';
    }
    if (value is DateTime) {
      final day = value.day.toString().padLeft(2, '0');
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
      return '$day ${months[value.month - 1]} ${value.year}';
    }
    if (value is String && value.isNotEmpty) return value;
    return 'N/A';
  }
}
