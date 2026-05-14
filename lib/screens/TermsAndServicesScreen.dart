import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';
import 'package:tekzo/services/app_config_service.dart';

class TermsAndServicesScreen extends StatelessWidget {
  const TermsAndServicesScreen({Key? key}) : super(key: key);

  final String _termsText =
      '''Welcome to Tekzo. These Terms and Services govern your use of the app and services provided.\n\n1. Acceptance of Terms\nBy using this application, you agree to be bound by these Terms and Services. If you do not agree, please discontinue use.\n\n2. Use of Service\nThe service grants you a limited, non-exclusive, non-transferable license to access and use the app for personal purposes.\n\n3. Privacy\nWe respect your privacy. Personal data will be processed according to our Privacy Policy.\n\n4. Purchases and Payments\nAll purchases are subject to payment and fulfillment terms. Prices may change at any time.\n\n5. Intellectual Property\nAll content, trademarks, and logos are the property of their respective owners.\n\n6. Limitation of Liability\nTo the fullest extent permitted by law, Tekzo is not liable for any indirect damages arising from use of the service.\n\n7. Changes to Terms\nWe may modify these Terms at any time; continued use implies acceptance of the updated terms.\n\nIf you have questions, please contact our support team via the "Contact Us" page.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Terms & Services',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<String>(
        stream: AppConfigService.appNameStream(),
        builder: (context, snapshot) {
          final appName = snapshot.data ?? AppConfigService.defaultAppName;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.015),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TERMS & SERVICES',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _termsText.replaceAll('Tekzo', appName),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
}
