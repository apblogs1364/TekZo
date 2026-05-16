import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/services/address_book_service.dart';
import 'package:tekzo/services/payment_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _couponController = TextEditingController();
  final PaymentService _paymentService = PaymentService();

  String? _appliedCouponCode;
  double _appliedCouponPercentage = 0;
  String? _selectedAddressId;

  static const Map<String, double> _couponOffers = {
    'SAVE10': 10,
    'SAVE15': 15,
    'SAVE20': 20,
    'WELCOME25': 25,
  };

  String? get _currentUserId =>
      AuthService.instance.loggedInUserData?['id']?.toString();

  Address? get _selectedAddress {
    if (AddressBookService.addresses.isEmpty) {
      return null;
    }

    if (_selectedAddressId != null) {
      for (final address in AddressBookService.addresses) {
        if (address.id == _selectedAddressId) {
          return address;
        }
      }
    }

    return AddressBookService.selectedAddress;
  }

  @override
  void initState() {
    super.initState();
    _selectedAddressId = AddressBookService.selectedAddress?.id;
  }

  @override
  void dispose() {
    _couponController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  double _priceFromCartData(Map<String, dynamic> data, String primaryKey) {
    final value = data[primaryKey] ?? data['price'] ?? 0;
    return (value as num).toDouble();
  }

  double _originalUnitPrice(Map<String, dynamic> data) {
    final discountedUnitPrice = _priceFromCartData(data, 'discountedPrice');
    final originalValue = data['originalPrice'];
    if (originalValue is num) {
      return originalValue.toDouble();
    }
    return _priceFromCartData(data, 'price').toDouble() > 0
        ? _priceFromCartData(data, 'price')
        : discountedUnitPrice;
  }

  double _discountedUnitPrice(Map<String, dynamic> data) {
    final discounted = data['discountedPrice'];
    if (discounted is num) {
      return discounted.toDouble();
    }
    final price = data['price'];
    if (price is num) {
      return price.toDouble();
    }
    return 0;
  }

  double _cartSubtotal(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.fold<double>(0, (sum, doc) {
      final data = doc.data();
      final quantity = (data['quantity'] as num?)?.toDouble() ?? 1;
      return sum + (_originalUnitPrice(data) * quantity);
    });
  }

  double _cartItemDiscount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.fold<double>(0, (sum, doc) {
      final data = doc.data();
      final quantity = (data['quantity'] as num?)?.toDouble() ?? 1;
      final original = _originalUnitPrice(data);
      final discounted = _discountedUnitPrice(data);
      return sum + ((original - discounted) * quantity);
    });
  }

  double _couponDiscount(double amountAfterItemDiscount) {
    if (_appliedCouponPercentage <= 0) {
      return 0;
    }
    return amountAfterItemDiscount * (_appliedCouponPercentage / 100);
  }

  void _applyCoupon() {
    final enteredCode = _couponController.text.trim().toUpperCase();
    final percentage = _couponOffers[enteredCode];

    if (percentage == null) {
      setState(() {
        _appliedCouponCode = null;
        _appliedCouponPercentage = 0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid coupon code')));
      return;
    }

    setState(() {
      _appliedCouponCode = enteredCode;
      _appliedCouponPercentage = percentage;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$enteredCode applied')));
  }

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.black87),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'STEP 2 OF 3',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5D70F5),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 44), // To balance the back button
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('SHIPPING ADDRESS'),
            _buildShippingAddressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('PAYMENT METHOD'),
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('ORDER SUMMARY'),
            _buildOrderSummaryCard(userId),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomPaymentBar(),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.grey500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    final selectedAddress = _selectedAddress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF5D70F5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedAddress?.name ?? 'Select Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddressDropdown,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5D70F5),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selectedAddress == null
                      ? 'No saved address available'
                      : selectedAddress.fullAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressDropdown() {
    if (AddressBookService.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved addresses available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: AddressBookService.addresses.length,
                    itemBuilder: (context, index) {
                      final address = AddressBookService.addresses[index];
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedAddressId = address.id;
                          });
                          Navigator.pop(context);
                        },
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                address.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (address.isDefault)
                              const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5D70F5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(address.fullAddress),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.grey200),
            ),
            child: const Icon(Icons.credit_card, color: AppColors.grey700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Visa ending in 4242',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Expires 12/26',
                  style: TextStyle(fontSize: 13, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(String? userId) {
    if (userId == null) {
      return _buildEmptySummaryCard();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('users')
          .doc(userId)
          .collection('cart')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptySummaryCard();
        }

        if (!snapshot.hasData) {
          return _buildEmptySummaryCard(showLoading: true);
        }

        final cartDocs = snapshot.data!.docs;
        final subtotal = _cartSubtotal(cartDocs);
        final itemDiscount = _cartItemDiscount(cartDocs);
        final afterItemDiscount = subtotal - itemDiscount;
        final couponDiscount = _couponDiscount(afterItemDiscount);
        final totalAmount = afterItemDiscount - couponDiscount;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (cartDocs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                    )
                  else
                    ...cartDocs.map((doc) {
                      final data = doc.data();
                      final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
                      final name = data['productName']?.toString() ?? 'Product';
                      final imagePath = data['productImage']?.toString() ?? '';
                      final originalUnitPrice = _originalUnitPrice(data);
                      final discountedUnitPrice = _discountedUnitPrice(data);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            _buildProductImageBadge(imagePath, 'x$quantity'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: $quantity',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${discountedUnitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        '₹${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discounted Amt',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        '-₹${itemDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shipping',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      const Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Coupon Discount',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        '-₹${couponDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Promo code',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _applyCoupon,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D2335),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptySummaryCard({bool showLoading = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            showLoading ? 'Loading cart items...' : 'Your cart is empty',
            style: const TextStyle(fontSize: 14, color: AppColors.grey500),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageBadge(String image, String badge) {
    final trimmed = image.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Dark background for product
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: trimmed.isEmpty
              ? const Center(
                  child: Icon(Icons.image, color: Colors.white54, size: 28),
                )
              : trimmed.startsWith('http://') || trimmed.startsWith('https://')
              ? Image.network(
                  trimmed,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, color: Colors.white54, size: 28),
                    );
                  },
                )
              : File(trimmed).existsSync()
              ? Image.file(File(trimmed), fit: BoxFit.cover)
              : Image.asset(
                  trimmed,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, color: Colors.white54, size: 28),
                    );
                  },
                ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF5D70F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPaymentBar() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _currentUserId == null
          ? null
          : _db
                .collection('users')
                .doc(_currentUserId)
                .collection('cart')
                .snapshots(),
      builder: (context, snapshot) {
        final cartDocs = snapshot.data?.docs ?? const [];
        final subtotal = _cartSubtotal(cartDocs);
        final itemDiscount = _cartItemDiscount(cartDocs);
        final afterItemDiscount = subtotal - itemDiscount;
        final couponDiscount = _couponDiscount(afterItemDiscount);
        final totalAmount = afterItemDiscount - couponDiscount;
        final cartItems = cartDocs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
        final userData = AuthService.instance.loggedInUserData ?? {};
        final userEmail = userData['email']?.toString() ?? '';
        final userPhone = userData['phone']?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PRICE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: cartDocs.isEmpty
                    ? null
                    : () async {
                        await _paymentService.openCheckout(
                          context: context,
                          amount: totalAmount.round(),
                          userId: _currentUserId ?? '',
                          userEmail: userEmail,
                          userPhone: userPhone,
                          cartItems: cartItems,
                          subTotal: subtotal,
                          discountAmount: itemDiscount + couponDiscount,
                          shippingCost: 0,
                          totalAmount: totalAmount,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA9BD),
                  disabledBackgroundColor: AppColors.grey300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
