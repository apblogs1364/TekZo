import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';

/// Product listing screen with category tabs and product grid.
class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> categories = ['Laptops', 'Phones', 'Tablets'];

  final List<Product> products = [
    Product(
      name: 'MacBook Air M2',
      price: '₹1,099',
      imagePath: 'assets/images/macbook.jpg',
    ),
    Product(
      name: 'Pro Max 15',
      price: '₹999',
      imagePath: 'assets/images/pro_max.jpg',
    ),
    Product(
      name: 'Studio Headphones',
      price: '₹549',
      imagePath: 'assets/images/headphones.jpg',
    ),
    Product(
      name: 'Active Watch 4',
      price: '₹199',
      imagePath: 'assets/images/watch.jpg',
    ),
    Product(
      name: 'Razer Blade 14',
      price: '₹1,899',
      imagePath: 'assets/images/razer_blade.jpg',
    ),
    Product(
      name: 'Pad Pro 12.9',
      price: '₹1,199',
      imagePath: 'assets/images/ipad_pro.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search laptops, phones, gear...',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                  suffixIcon: Icon(Icons.tune, color: AppColors.grey400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
            ),
            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  categories.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          categories[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedCategoryIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedCategoryIndex == index
                                ? AppColors.black
                                : AppColors.grey600,
                          ),
                        ),
                        if (_selectedCategoryIndex == index)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 40,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Products Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/product-detail');
                      },
                      child: ProductCard(product: products[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          setState(() {});

          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              // Already on Products
              break;
            case 2:
              Navigator.pushNamed(context, '/wishlist');
              break;
            case 3:
              Navigator.pushNamed(context, '/orders');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: AppColors.primaryDark,
                          size: 18,
                        ),
                        onPressed: () {},
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String price;
  final String imagePath;

  Product({required this.name, required this.price, required this.imagePath});
}
