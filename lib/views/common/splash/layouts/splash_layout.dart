import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ready_ecommerce/components/ecommerce/offline.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/services/common/hive_service_provider.dart';
import 'package:ready_ecommerce/utils/api_client.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/common/onboarding/onboarding_view.dart';

class SplashLayout extends ConsumerStatefulWidget {
  const SplashLayout({super.key});

  @override
  ConsumerState<SplashLayout> createState() => _SplashLayoutState();
}

class _SplashLayoutState extends ConsumerState<SplashLayout> {
  late StreamSubscription<ConnectivityStatus> _connectivitySubscription;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint("SplashLayout initState called");

    _connectivitySubscription =
        ConnectivityWrapper.instance.onStatusChange.listen((event) {
      debugPrint("Connectivity status changed: $event");
      _initiateNavigation(event);
    });

    // Check current status immediately
    ConnectivityWrapper.instance.isConnected.then((connected) {
      if (!mounted) return;
      debugPrint("Initial connectivity check: $connected");
      _initiateNavigation(connected
          ? ConnectivityStatus.CONNECTED
          : ConnectivityStatus.DISCONNECTED);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _initiateNavigation(ConnectivityStatus event) {
    if (_hasNavigated || event != ConnectivityStatus.CONNECTED) return;
    _hasNavigated = true;

    debugPrint("Initiating navigation for status: $event");

    // Step 1: Get master data
    ref
        .read(masterControllerProvider.notifier)
        .getMasterData()
        .then((response) {
      if (!mounted) return;

      if (response?.data.themeColors.primaryColor != null) {
        ref
            .read(hiveServiceProvider)
            .setPrimaryColor(color: response!.data.themeColors.primaryColor);
      }
      if (response?.data.appLogo != null) {
        ref.read(hiveServiceProvider).setAppLogo(logo: response!.data.appLogo);
      }
      if (response?.data.appName != null) {
        ref.read(hiveServiceProvider).setAppName(name: response!.data.appName);
      }
      if (response?.data.splashLogo != null) {
        ref
            .read(hiveServiceProvider)
            .setSplashLogo(splashLogo: response!.data.splashLogo);
      }
    });

    // Step 2: Load token and user, then navigate
    ref.read(hiveServiceProvider).loadTokenAndUser().then((data) {
      if (!mounted || data == null) return;

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        debugPrint("Delayed navigation starting...");

        if (data[0] == true && (data[1] == null || data[2] == null)) {
          context.nav.pushNamedAndRemoveUntil(
            Routes.getCoreRouteName(AppConstants.appServiceName),
            (route) => false,
          );
        } else if ((data[1] != null) && (data[2] != null)) {
          ref.read(apiClientProvider).updateToken(token: data[1]);
          context.nav.pushNamedAndRemoveUntil(
            Routes.getCoreRouteName(AppConstants.appServiceName),
            (route) => false,
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: ((context, animation, secondaryAnimation) =>
                  const OnboardingView()),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var offsetAnimation = animation.drive(
                    Tween(begin: const Offset(0.0, 1.0), end: Offset.zero));
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      offlineWidget: const OfflineScreen(),
      child: Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      height: 100.r,
                      width: 100.r,
                      color: GlobalFunction.getContainerColor(),
                    )
                        .animate(delay: 3.seconds)
                        .moveX(duration: 500.ms, begin: 0.0, end: -200.0)
                  ],
                ),
              ),
              Gap(12.w),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: Hive.box(AppConstants.appSettingsBox)
                              .listenable(),
                          builder: (context, settingsBox, _) {
                            final String? splashLogo = settingsBox.get(
                              AppConstants.splashLogo,
                            );
                            if (splashLogo != null) {
                              return CachedNetworkImage(
                                imageUrl: splashLogo,
                                height: 100.h,
                                width: 200.w,
                              );
                            }
                            return Assets.png.splashLogo
                                .image(height: 100.h, width: 200.w);
                          })
                    ],
                  ),
                  Container(
                    color: GlobalFunction.getContainerColor(),
                    height: 100.r,
                    width: 280.r,
                  )
                      .animate(delay: 2.seconds)
                      .moveX(duration: 500.ms, begin: 0.0, end: 280.0)
                      .callback(callback: (value) {})
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
