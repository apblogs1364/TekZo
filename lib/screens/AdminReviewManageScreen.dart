import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminEditReviewScreen.dart';

class AdminReviewManageScreen extends StatefulWidget {
  const AdminReviewManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminReviewManageScreen> createState() =>
      _AdminReviewManageScreenState();
}

class _AdminReviewManageScreenState extends State<AdminReviewManageScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);

  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'Published', 'Flagged'];

  final List<_Review> _allReviews = [
    _Review(
      customerName: 'Arjun Sharma',
      productName: 'Tekzo Pro Buds Max',
      avatarColor: Color(0xFF5B8EA6),
      avatarInitials: 'AS',
      rating: 4,
      reviewText:
          'The sound quality is absolutely phenomenal. I\'ve been using it for a week and the battery life is amazing. Worth every rupee!',
      date: 'OCT 12, 2024',
      status: 'Published',
    ),
    _Review(
      customerName: 'Vikram Singh',
      productName: 'Tekzo Sonic Buds G2',
      avatarColor: Color(0xFF7B8EA0),
      avatarInitials: 'VS',
      rating: 1,
      reviewText:
          'This review contains promotional links and spam content. Needs immediate moderation by the admin team.',
      date: 'OCT 10, 2024',
      status: 'Flagged',
    ),
    _Review(
      customerName: 'Ananya Reddy',
      productName: 'Tekzo ErgoDesk Pad',
      avatarColor: Color(0xFFE8A87C),
      avatarInitials: 'AR',
      rating: 5,
      reviewText:
          'Exceptional product! The desk pad is super smooth and the stitching is top-notch. My entire setup looks premium now.',
      date: 'OCT 09, 2024',
      status: 'Published',
    ),
    _Review(
      customerName: 'Meera Nair',
      productName: 'Tekzo Laptop Stand',
      avatarColor: Color(0xFFA78BDA),
      avatarInitials: 'MN',
      rating: 2,
      reviewText:
          'The stand keeps wobbling even on a flat surface. Expected better build quality for the price. Very disappointed.',
      date: 'OCT 07, 2024',
      status: 'Flagged',
    ),
  ];

  late List<_Review> _filteredReviews;

  @override
  void initState() {
    super.initState();
    _filteredReviews = _allReviews;
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReviews = _allReviews.where((r) {
        final matchesSearch = query.isEmpty ||
            r.customerName.toLowerCase().contains(query) ||
            r.productName.toLowerCase().contains(query) ||
            r.reviewText.toLowerCase().contains(query);
        final matchesFilter =
            _activeFilter == 'All' || r.status == _activeFilter;
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
            Expanded(child: _buildReviewList()),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                color: AppColors.black, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Manage Reviews',
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
              const Icon(Icons.notifications_none_outlined,
                  color: AppColors.black, size: 24),
              Positioned(
                right: 0,
                top: 0,
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

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon:
                Icon(Icons.search, color: AppColors.grey400, size: 20),
            hintText: 'Search reviews, customers, or products',
            hintStyle: TextStyle(color: AppColors.grey400, fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Filter Tabs ────────────────────────────────────────────────────────────

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
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
                    color:
                        isActive ? AppColors.white : AppColors.grey500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Review List ────────────────────────────────────────────────────────────

  Widget _buildReviewList() {
    if (_filteredReviews.isEmpty) {
      return const Center(
        child: Text(
          'No reviews found',
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
      itemCount: _filteredReviews.length,
      itemBuilder: (context, index) =>
          _ReviewCard(review: _filteredReviews[index]),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _Review {
  final String customerName;
  final String productName;
  final Color avatarColor;
  final String avatarInitials;
  final int rating; // 1–5
  final String reviewText;
  final String date;
  final String status; // 'Published' | 'Pending' | 'Flagged'

  const _Review({
    required this.customerName,
    required this.productName,
    required this.avatarColor,
    required this.avatarInitials,
    required this.rating,
    required this.reviewText,
    required this.date,
    required this.status,
  });
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({Key? key, required this.review}) : super(key: key);

  Color get _statusBg {
    switch (review.status) {
      case 'Published': return const Color(0xFFDCFCE7);
      case 'Flagged':   return const Color(0xFFFFE4E6);
      default:          return AppColors.grey100;
    }
  }

  Color get _statusColor {
    switch (review.status) {
      case 'Published': return AppColors.success;
      case 'Flagged':   return AppColors.danger;
      default:          return AppColors.grey500;
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
          // ── Top row: avatar / name / badge ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: review.avatarColor,
                child: Text(
                  review.avatarInitials,
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
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'on ${review.productName}',
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  review.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Star rating ────────────────────────────────────────────────
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                color: AppColors.amber,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),

          // ── Review text (truncated to 2 lines) ─────────────────────────
          Text(
            review.reviewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // ── Date + action icons ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  // Edit
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEditReviewScreen(
                            customerName: review.customerName,
                            customerEmail:
                                '${review.customerName.toLowerCase().replaceAll(' ', '.')}@email.com',
                            productName: review.productName,
                            sku: 'TKZ-2024-${review.avatarInitials}',
                            rating: review.rating,
                            reviewText: review.reviewText,
                            status: review.status,
                            avatarColor: review.avatarColor,
                            avatarInitials: review.avatarInitials,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit_note_outlined,
                        color: AppColors.grey400, size: 22),
                  ),
                  const SizedBox(width: 16),
                  // Delete
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.grey400, size: 22),
                  ),
                  const SizedBox(width: 16),
                  // Flag
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Flagged review by ${review.customerName}')),
                    ),
                    child: Icon(
                      review.status == 'Flagged'
                          ? Icons.flag
                          : Icons.flag_outlined,
                      color: review.status == 'Flagged'
                          ? AppColors.danger
                          : AppColors.grey400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Delete review by ${review.customerName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grey500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Review by ${review.customerName} deleted')),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
