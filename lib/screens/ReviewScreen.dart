import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';
//import 'dart:math' as math;
import 'dart:ui';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final Color primaryBlue = const Color(0xFF4A66FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write a Review',
          style: TextStyle(
            color: AppColors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductCard(),
            const SizedBox(height: 32),
            _buildOverallRating(),
            const SizedBox(height: 32),
            const Text(
              'Your Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewTextField(),
            const SizedBox(height: 24),
            const Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPhotosRow(),
            const SizedBox(height: 24),
            _buildInfoBox(),
            const SizedBox(height: 24), // Add space before bottom nav
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: const Color(0xFFF6F8FB),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review Submitted!')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                label: const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          CustomBottomNavigationBar(
            currentIndex: NavigationIndexService.currentIndex,
            onTap: (index) {
              NavigationIndexService.setIndex(index);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.laptop_chromebook, color: AppColors.grey400, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tekzo Pro Laptop',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Electronics & Tech',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹99,999',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
    return Column(
      children: [
        const Text(
          'OVERALL RATING',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.grey500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStarItem(1, true),
            const SizedBox(width: 16),
            _buildStarItem(2, true),
            const SizedBox(width: 16),
            _buildStarItem(3, true),
            const SizedBox(width: 16),
            _buildStarItem(4, true),
            const SizedBox(width: 16),
            _buildStarItem(5, false),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Great product! (4/5)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildStarItem(int number, bool isActive) {
    Color bgColor = isActive ? primaryBlue : AppColors.grey200;
    Color iconColor = isActive ? Colors.white : AppColors.grey400;
    Color textColor = isActive ? primaryBlue : AppColors.grey400;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Icon(Icons.star_border, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          number.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Share your experience with this product...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.grey400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPhotosRow() {
    return Row(
      children: [
        // Dashed Upload Box
        CustomPaint(
          painter: DashedRectPainter(
            color: const Color(0xFFB0C4DE),
            strokeWidth: 2.0,
            gap: 5.0,
          ),
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_a_photo_outlined, color: Color(0xFF8CA5C1), size: 28),
                SizedBox(height: 4),
                Text(
                  'UPLOAD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8CA5C1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildUploadedPhotoBox(),
        const SizedBox(width: 16),
        _buildUploadedPhotoBox(isSecond: true),
      ],
    );
  }

  Widget _buildUploadedPhotoBox({bool isSecond = false}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSecond ? const Color(0xFFEEDADB) : const Color(0xFFEBD2BE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.laptop, color: Colors.black54, size: 36),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFF5D70F5), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your review will be public and helps other customers make better choices. Please follow our community guidelines.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7B8F),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for dashed border
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({
    this.strokeWidth = 2.0,
    this.color = Colors.black,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x, y)
      ..lineTo(0, y)
      ..close();

    Path dashPath = Path();
    double dashLength = 6.0;
    bool draw = true;

    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        double length = dashLength;
        if (distance + length > measurePath.length) {
          length = measurePath.length - distance;
        }
        if (draw) {
          dashPath.addPath(
              measurePath.extractPath(distance, distance + length), Offset.zero);
        }
        distance += length + gap;
        draw = true; // Always draw next after gap in simple dashes
      }
    }

    // Adding rounded corners by clipping visually (Simplistic approach)
    // Actually, dashed path doesn't smoothly round automatically unless using addRRect
    // But for a simple square/box, Path() works fine. To do RRect dashes is harder.
    // Let's replace simple straight path with an RRect path:
    Path rrectPath = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, x, y), Radius.circular(12)));
    Path finalDashPath = Path();
    
    for (PathMetric measurePath in rrectPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        double length = dashLength;
        if (draw) {
          finalDashPath.addPath(
              measurePath.extractPath(distance, distance + length), Offset.zero);
        }
        distance += length + gap;
        // draw = !draw; if we wanted strictly alternating
      }
    }

    canvas.drawPath(finalDashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
