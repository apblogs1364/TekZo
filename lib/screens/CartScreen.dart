import 'package:flutter/material.dart';
import 'package:tekzo/services/auth_service.dart';
import '../theme/app_colors.dart';
import 'CheckoutScreen.dart';

/// Shopping cart screen showing selected items and order summary.
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [
    CartItem(
      name: 'AirPods Pro',
      variant: 'White',
      price: 249.00,
      quantity: 1,
      imagePath: 'assets/images/airpods_pro.jpg',
    ),
    CartItem(
      name: 'Wireless Earbuds',
      variant: 'Black',
      price: 79.99,
      quantity: 1,
      imagePath: 'assets/images/wireless_earbuds.jpg',
    ),
    CartItem(
      name: 'USB-C Cable',
      variant: '2m',
      price: 12.99,
      quantity: 2,
      imagePath: 'assets/images/usb_cable.jpg',
    ),
  ];

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get total {
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: isLoggedIn
            ? Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Your Cart',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(color: AppColors.grey300, height: 1),
                  // Cart Items
                  Expanded(
                    child: cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: AppColors.grey400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your cart is empty',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              return _CartItemCard(
                                item: cartItems[index],
                                onQuantityChanged: (newQuantity) {
                                  setState(() {
                                    if (newQuantity > 0) {
                                      cartItems[index].quantity = newQuantity;
                                    }
                                  });
                                },
                                onRemove: () {
                                  setState(() {
                                    cartItems.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  // Divider
                  Divider(color: AppColors.grey300, height: 1),
                  // Summary Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              '₹${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Shipping Fee (can be added later)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Divider
                        Divider(color: AppColors.grey300, height: 1),
                        const SizedBox(height: 12),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Proceed to Checkout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cartItems.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CheckoutScreen(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              disabledBackgroundColor: AppColors.grey300,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cartItems.isEmpty
                                    ? AppColors.grey600
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please login to view your cart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.grey600,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Variant
                Text(
                  item.variant,
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Actions (Quantity and Remove)
          Column(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.remove,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onQuantityChanged(item.quantity + 1);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Remove Button
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String name;
  final String variant;
  final double price;
  int quantity;
  final String imagePath;

  CartItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });
}
