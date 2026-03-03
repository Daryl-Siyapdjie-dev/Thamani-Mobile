import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/models/eCommerce/product/product.dart';
import 'package:ready_ecommerce/utils/api_client.dart';

final productsOnSaleControllerProvider =
    StateNotifierProvider<ProductsOnSaleController, bool>((ref) {
  final controller = ProductsOnSaleController(ref);
  controller.getProductsOnSale();
  return controller;
});

class ProductsOnSaleController extends StateNotifier<bool> {
  final Ref ref;
  ProductsOnSaleController(this.ref) : super(false);

  List<Product> _products = [];
  List<Product> get products => _products;

  int _total = 0;
  int get total => _total;

  Future<void> getProductsOnSale({int page = 1, int perPage = 12}) async {
    try {
      state = true;
      final response = await ref.read(apiClientProvider).get(
        AppConstants.getProductsOnSale,
        query: {'page': page, 'per_page': perPage},
      );

      if (response.data is! Map<String, dynamic>) {
        debugPrint(
            'Error: Expected JSON but received ${response.data.runtimeType}');
        _products = [];
        state = false;
        return;
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];
      if (data != null && data is Map) {
        final total = data['total'];
        _total = total is int ? total : 0;
        final productsList = data['products'];
        if (productsList != null && productsList is List) {
          _products = productsList
              .map((p) => Product.fromMap(p as Map<String, dynamic>))
              .toList();
        } else {
          _products = [];
        }
      } else {
        _products = [];
      }

      state = false;
    } catch (e, stk) {
      state = false;
      debugPrint('Error in getProductsOnSale: $e');
      debugPrint('Stack trace: $stk');
    }
  }
}
