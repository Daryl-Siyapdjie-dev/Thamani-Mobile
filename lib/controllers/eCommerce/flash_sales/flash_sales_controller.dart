import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/models/eCommerce/flash_sales_list_model/running_flash_sale.dart';
import 'package:ready_ecommerce/models/eCommerce/product/product.dart';
import 'package:ready_ecommerce/services/eCommerce/flash_sales/flash_sales_service.dart';

final flashSalesListControllerProvider =
    StateNotifierProvider<FlashSalesListController, bool>((ref) {
  return FlashSalesListController(ref);
});

class FlashSalesListController extends StateNotifier<bool> {
  final Ref ref;
  FlashSalesListController(this.ref) : super(false) {
    getFlashSalesList();
  }
  RunningFlashSale? runningFlashSale;
  Future<void> getFlashSalesList() async {
    try {
      state = true;
      final response =
          await ref.read(flashSalesServiceProvider).getFlashSalesList();
      
      // Check if response.data is a Map before parsing
      if (response.data is! Map<String, dynamic>) {
        debugPrint('Error: Expected JSON but received ${response.data.runtimeType}');
        runningFlashSale = null;
        state = false;
        return;
      }
      
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data']?["running_flash_sale"];
      if (data != null && data is Map) {
        runningFlashSale = RunningFlashSale.fromMap(data as Map<String, dynamic>);
      } else {
        runningFlashSale = null;
      }

      state = false;
    } catch (e, stk) {
      state = false;
      debugPrint('Error in getFlashSalesList: $e');
      debugPrint('Stack trace: $stk');
    }
  }
}

final flashSaleDetailsControllerProvider =
    StateNotifierProvider<FlashSalesDetailsController, bool>((ref) {
  return FlashSalesDetailsController(ref);
});

class FlashSalesDetailsController extends StateNotifier<bool> {
  final Ref ref;
  FlashSalesDetailsController(this.ref) : super(false);
  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> getFlashSalesDetails({required int id}) async {
    try {
      state = true;
      final response =
          await ref.read(flashSalesServiceProvider).getFlashSalesDetail(id: id);
      
      // Check if response.data is a Map before parsing
      if (response.data is! Map<String, dynamic>) {
        debugPrint('Error: Expected JSON but received ${response.data.runtimeType}');
        _products = [];
        state = false;
        return;
      }
      
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data']?["products"];
      if (data != null && data is List) {
        _products = (data as List<dynamic>)
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
      } else {
        _products = [];
      }
      state = false;
    } catch (e, stk) {
      state = false;
      debugPrint('Error in getFlashSalesDetails: $e');
      debugPrint('Stack trace: $stk');
    }
  }
}
