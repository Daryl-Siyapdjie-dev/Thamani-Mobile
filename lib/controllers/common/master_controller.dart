import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/models/common/master_model.dart';
import 'package:ready_ecommerce/services/common/master_service_provider.dart';

class MasterController extends StateNotifier<bool> {
  final Ref ref;

  MasterController(this.ref) : super(false) {
    _masterModel = MasterModel.empty();
  }

  late MasterModel _masterModel;
  MasterModel get materModel => _masterModel;

  Future<MasterModel?> getMasterData() async {
    try {
      final response =
          await ref.read(masterServiceProvider).getMasterSettings();
      
      // Check if response.data is a Map before parsing
      if (response.data is! Map<String, dynamic>) {
        debugPrint('Error: Expected JSON but received ${response.data.runtimeType}');
        return null;
      }
      
      _masterModel = MasterModel.fromJson(response.data as Map<String, dynamic>);

      ref
          .read(currencyProvider.notifier)
          .updateCurrency(_masterModel.data.currency);
      return _masterModel;
    } catch (error, stackTrace) {
      debugPrint('Error in getMasterData: $error');
      debugPrint('Stack trace: $stackTrace');
    }
    return null;
  }
}

final masterControllerProvider = StateNotifierProvider<MasterController, bool>(
    (ref) => MasterController(ref));

class CurrencyStateNotifier extends StateNotifier<Currency> {
  CurrencyStateNotifier() : super(Currency.empty());

  void updateCurrency(Currency currency) {
    state = currency;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyStateNotifier, Currency>(
    (ref) => CurrencyStateNotifier());
