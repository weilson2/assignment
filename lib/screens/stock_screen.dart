import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/stock_service.dart';
import '../models/product_model.dart';
import '../screens/product_detail.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final StockService _stockService = StockService();

  List<Category> categories = [];
  List<Product> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final categoriesData = await _stockService.getCategories();
      final productsData = await _stockService.getAllProducts();

      setState(() {
        categories = categoriesData;
        allProducts = productsData;

        // Initialize tab controller with categories + "All" tab
        _tabController = TabController(
          length: categories.length + 1,
          vsync: this,
        );

        isLoading = false;
      });
    } catch (error) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stock data: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductDetailScreen(),
                settings: RouteSettings(arguments: product),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: product.imageUrl != null
                        ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                        : _buildPlaceholderImage(),
                  ),
                ),

                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${product.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock: ${product.quantityInStock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.quantityInStock < 50
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'view details',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.inventory_2,
        size: 32,
        color: Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Stock'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const BottomNav(currentIndex: 1),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'All'),
            ...categories.map((category) => Tab(text: category.name)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          categories.length + 1,
              (tabIndex) {
            List<Product> productsForTab;

            if (tabIndex == 0) {
              // "All" tab
              productsForTab = List.from(allProducts)
                ..sort((a, b) => a.name.compareTo(b.name));
            } else {
              // Category tab
              final selectedCategory = categories[tabIndex - 1];
              productsForTab = allProducts
                  .where((product) => product.categoryId == selectedCategory.id)
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: productsForTab.isEmpty
                  ? const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: productsForTab.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(productsForTab[index]);
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
