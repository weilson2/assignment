import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/product_model.dart';

class StockService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  // Get all products with category information
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories (
              name
            )
          ''')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories (
              name
            )
          ''')
          .eq('category_id', categoryId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch products by category: $error');
    }
  }

  // Get single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories (
              name
            )
          ''')
          .eq('id', productId)
          .maybeSingle();

      if (response == null) return null;

      return Product.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch product: $error');
    }
  }

  // Search products by name
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories (
              name
            )
          ''')
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search products: $error');
    }
  }

  // Update product stock quantity
  Future<bool> updateProductStock(String productId, int newQuantity) async {
    try {
      await _supabase
          .from('products')
          .update({
        'quantity_in_stock': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', productId);

      return true;
    } catch (error) {
      throw Exception('Failed to update stock: $error');
    }
  }
}