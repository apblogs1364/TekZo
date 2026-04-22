import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: AppColors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfoCard(),
            const SizedBox(height: 32),
            _buildMainTimeline(),
            _buildDeliveryInfoCard(),
            const SizedBox(height: 16),
            _buildUpdatesTimeline(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        border: Border.all(color: AppColors.grey200.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER ID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey400,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IN TRANSIT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5D70F5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '#TKZ-98765',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.grey400),
              SizedBox(width: 8),
              Text(
                'Standard Shipping • 2 Items',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineStep(
            icon: Icons.check,
            title: 'Order Placed',
            subtitle: 'March 12, 2026 • 10:00 AM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.check,
            title: 'Processed',
            subtitle: 'March 13, 2026 • 02:30 PM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.local_shipping_outlined,
            title: 'Shipped',
            subtitle: 'March 14, 2026 • 09:15 AM',
            isCompleted: false,
            isActive: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.home_outlined,
            title: 'Delivered',
            subtitle: 'Expected March 15, 2026',
            isCompleted: false,
            isActive: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    final Color blueTheme = const Color(0xFF7A8B9D);
    final Color greyTheme = const Color(0xFFD3D8E0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? blueTheme : (isActive ? Colors.white : Colors.white),
                  border: Border.all(
                    color: isCompleted ? blueTheme : (isActive ? blueTheme : greyTheme),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16,
                    color: isCompleted ? Colors.white : (isActive ? blueTheme : greyTheme),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: (isCompleted && title != 'Processed') ? blueTheme : greyTheme,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isActive || isCompleted ? AppColors.black87 : AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 24),
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
        border: Border.all(color: AppColors.grey200.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Est. Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'March 15, 2026',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Courier',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Delhivery',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.grey200, height: 1),
          ),
          const Text(
            'Tracking Number',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TX-123456789',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D70F5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Text(
                      'COPY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.copy, size: 14, color: AppColors.grey500),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Updates',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildUpdateStep(
          title: 'Picked up by courier',
          subtitle: 'Arrived at Delhivery Facility • 11:20 AM',
          isCompleted: true,
        ),
        _buildUpdateStep(
          title: 'Arrived at sorting facility',
          subtitle: 'Bengaluru Regional Hub • 08:45 AM',
          isCompleted: true,
        ),
        _buildUpdateStep(
          title: 'Departure from hub',
          subtitle: 'Expected update in 2 hours',
          isCompleted: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildUpdateStep({
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isLast = false,
  }) {
    final Color blueTheme = const Color(0xFF7A8B9D);
    final Color greyTheme = const Color(0xFFD3D8E0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? blueTheme : greyTheme,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Container(
                        decoration: BoxDecoration(
                          color: blueTheme,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? blueTheme : greyTheme,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.black87 : AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted ? AppColors.grey400 : AppColors.grey400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
