import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminReviewDetailsScreen.dart';

class AdminReviewManageScreen extends StatefulWidget {
  const AdminReviewManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminReviewManageScreen> createState() =>
      _AdminReviewManageScreenState();
}

class _AdminReviewManageScreenState extends State<AdminReviewManageScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildReviewList()),
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
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 22,
            ),
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
          const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.black,
            size: 24,
          ),
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
              color: AppColors.grey200.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: AppColors.grey400, size: 20),
            hintText: 'Search reviews, users, or products',
            hintStyle: TextStyle(color: AppColors.grey400, fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load reviews',
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

        final reviews =
            snapshot.data?.docs
                .map((doc) => _ReviewRecord.fromDoc(doc.id, doc.data()))
                .toList() ??
            [];

        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filteredReviews = _searchQuery.isEmpty
            ? reviews
            : reviews.where((review) => review.matches(_searchQuery)).toList();

        if (filteredReviews.isEmpty) {
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: filteredReviews.length,
          itemBuilder: (context, index) {
            final review = filteredReviews[index];
            return _ReviewCard(
              review: review,
              onView: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminReviewDetailsScreen(reviewId: review.id),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }
}

class _ReviewRecord {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String reviewTitle;
  final String reviewText;
  final double rating;
  final DateTime createdAt;

  const _ReviewRecord({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.reviewTitle,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
  });

  factory _ReviewRecord.fromDoc(String id, Map<String, dynamic> data) {
    return _ReviewRecord(
      id: id,
      productId: data['productId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      reviewTitle: data['reviewTitle']?.toString() ?? '',
      reviewText: data['reviewText']?.toString() ?? '',
      rating: double.tryParse(data['rating']?.toString() ?? '') ?? 0.0,
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  bool matches(String query) {
    final text = [
      productId,
      userId,
      userName,
      reviewTitle,
      reviewText,
      rating.toString(),
      _formatDate(createdAt),
    ].join(' ').toLowerCase();
    return text.contains(query);
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty)
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
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

class _ReviewCard extends StatelessWidget {
  final _ReviewRecord review;
  final VoidCallback onView;

  const _ReviewCard({
    Key? key,
    required this.review,
    required this.onView,
  }) : super(key: key);

  String get _avatarInitials {
    final parts = review.userName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1)
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color get _avatarColor {
    final hash = review.userName.hashCode.abs();
    final colors = [
      const Color(0xFF5B8EA6),
      const Color(0xFF7B8EA0),
      const Color(0xFFE8A87C),
      const Color(0xFFA78BDA),
      const Color(0xFF6AA6A1),
    ];
    return colors[hash % colors.length];
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _avatarColor,
                child: Text(
                  _avatarInitials,
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
                      review.userName.isNotEmpty
                          ? review.userName
                          : 'Unnamed User',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Review: ${review.reviewTitle.isNotEmpty ? review.reviewTitle : 'Untitled'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onView,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: AppColors.grey600,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating.round() ? Icons.star : Icons.star_border,
                color: AppColors.amber,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Product ID: ${review.productId.isNotEmpty ? review.productId : 'N/A'}',
                style: const TextStyle(
                  fontSize: 11,
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
}
