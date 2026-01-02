import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/models/eCommerce/dashboard/dashboard.dart';
import 'package:ready_ecommerce/services/eCommerce/dashboard_service/dashboard_service.dart';
import 'package:ready_ecommerce/utils/request_handler.dart';

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, AsyncValue<Dashboard>>((ref) {
  final controller = DashboardController(ref);
  controller.getDashboardData();
  return controller;
});

class DashboardController extends StateNotifier<AsyncValue<Dashboard>> {
  final Ref ref;
  DashboardController(this.ref) : super(const AsyncLoading());

  Future<void> getDashboardData() async {
    try {
      final response =
          await ref.read(dashboardServiceProvider).getDashboardData();
      
      // Check if response.data is a Map before parsing
      if (response.data is! Map<String, dynamic>) {
        debugPrint('Error: Expected JSON but received ${response.data.runtimeType}');
        state = AsyncError(
          'Invalid response format: Expected JSON but received ${response.data.runtimeType}',
          StackTrace.current,
        );
        return;
      }
      
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];
      if (data != null && data is Map) {
        state = AsyncData(Dashboard.fromMap(data as Map<String, dynamic>));
      } else {
        state = AsyncError(
          'Invalid response: data field is missing or invalid',
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Error in getDashboardData: $error');
      debugPrint('Stack trace: $stackTrace');

      state = AsyncError(
        error is DioException ? ApiInterceptors.handleError(error) : error,
        stackTrace,
      );
    }
  }
}
