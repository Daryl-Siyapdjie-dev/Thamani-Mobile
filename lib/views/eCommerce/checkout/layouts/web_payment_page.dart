// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_dialog.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/eCommerce/order/order_controller.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';

class WebPayementScreen extends ConsumerStatefulWidget {
  final WebPaymentScreenArg webPaymentScreenAr;
  const WebPayementScreen({
    super.key,
    required this.webPaymentScreenAr,
  });

  @override
  ConsumerState<WebPayementScreen> createState() => _WebPayementScreenState();
}

class _WebPayementScreenState extends ConsumerState<WebPayementScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String _currentUrl = '';
  bool _hasShownSuccessDialog = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors(context).accentColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colors(context).primaryColor,
          leading: IconButton(
            onPressed: () {
              _buildRouting();
              _buildPaymentFailedDialog();
            },
            icon: Icon(
              Icons.arrow_back,
              color: EcommerceAppColor.white,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: EcommerceAppColor.white,
                size: 20.sp,
              ),
              Gap(8.w),
              Text(
                S.of(context).pyment,
                style: AppTextStyle(context).appBarText.copyWith(
                  color: EcommerceAppColor.white,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.h),
            child: _loadingProgress < 1.0
                ? LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: colors(context).primaryColor?.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      EcommerceAppColor.white,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: Column(
          children: [
            // Security Badge
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: EcommerceAppColor.green.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: EcommerceAppColor.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: EcommerceAppColor.green,
                    size: 20.sp,
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Text(
                      'Paiement Sécurisé - Vos données sont protégées',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: EcommerceAppColor.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // WebView Container
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: colors(context).dark?.withValues(alpha: 0.1) ?? Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(widget.webPaymentScreenAr.paymentUrl),
                        ),
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          String onLoadUrl = url.toString();
                          debugPrint('🔍 onLoadStart URL: $onLoadUrl');

                          setState(() {
                            _currentUrl = onLoadUrl;
                            _isLoading = true;
                          });

                          if (onLoadUrl.trim().contains('/payment/success') && !_hasShownSuccessDialog) {
                            debugPrint('✅ Payment success detected! Showing dialog...');
                            _hasShownSuccessDialog = true;
                            // Use Future.delayed to ensure the dialog shows after frame is built
                            Future.delayed(Duration.zero, () {
                              if (mounted) {
                                debugPrint('📱 Calling _buildPaymentDoneDialog()');
                                _buildPaymentDoneDialog();
                              }
                            });
                          } else if (onLoadUrl.contains('payment/fail')) {
                            debugPrint('❌ Payment failed detected');
                            _buildRouting();
                            _buildPaymentFailedDialog();
                          } else if (onLoadUrl.contains('payment/cancel')) {
                            debugPrint('🚫 Payment cancelled detected');
                            _buildRouting();
                            _buildPaymentFailedDialog();
                          }
                        },
                        onProgressChanged: (controller, progress) {
                          setState(() {
                            _loadingProgress = progress / 100;
                          });
                        },
                        onLoadStop: (controller, url) {
                          setState(() {
                            _isLoading = false;
                            _loadingProgress = 1.0;
                          });
                        },
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          domStorageEnabled: true,
                          databaseEnabled: true,
                          allowFileAccess: true,
                          allowContentAccess: true,
                          useHybridComposition: false,
                          useShouldOverrideUrlLoading: false,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          cacheEnabled: true,
                          clearCache: false,
                          thirdPartyCookiesEnabled: true,
                          supportZoom: true,
                          builtInZoomControls: false,
                          displayZoomControls: false,
                          transparentBackground: false,
                        ),
                      ),
                      if (_isLoading && _loadingProgress < 0.5)
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colors(context).primaryColor ?? EcommerceAppColor.primary,
                                  ),
                                ),
                                Gap(20.h),
                                Text(
                                  'Chargement sécurisé...',
                                  style: AppTextStyle(context).bodyText.copyWith(
                                    color: colors(context).bodyTextSmallColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Info Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: colors(context).bodyTextSmallColor?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: colors(context).bodyTextSmallColor,
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      'Ne partagez jamais vos informations de paiement',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildRouting() {
    if (widget.webPaymentScreenAr.orderId != null) {
      final data = ref.refresh(
          orderDetailsControllerProvider(widget.webPaymentScreenAr.orderId!));
      debugPrint(data.toString());
      context.nav.pop();
    } else {
      context.nav.pushNamedAndRemoveUntil(
          Routes.getCoreRouteName(AppConstants.appServiceName),
          (route) => false);
    }
  }

  _buildPaymentDoneDialog() {
    debugPrint('🎉 _buildPaymentDoneDialog() called');
    debugPrint('🔧 ContextLess.context: ${ContextLess.context}');
    debugPrint('🔧 mounted: $mounted');

    return showDialog(
      barrierDismissible: false,
      context: ContextLess.context,
      builder: (_) {
        debugPrint('🏗️ Building payment success dialog...');
        return Dialog(
          backgroundColor: Theme.of(ContextLess.context).scaffoldBackgroundColor,
          surfaceTintColor: colors(ContextLess.context).light,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 40.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Payment Success Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    Assets.png.paymentSuccesfull.path,
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                ),
                Gap(24.h),
                Text(
                  S.of(context).paymentSuccess,
                  style: AppTextStyle(context).title.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: EcommerceAppColor.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(16.h),
                Text(
                  S.of(context).paymentSuccessDes,
                  textAlign: TextAlign.center,
                  style: AppTextStyle(context).bodyText.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                Gap(32.h),
                CustomButton(
                  buttonText: S.of(context).close,
                  buttonColor: colors(context).primaryColor,
                  onPressed: () {
                    ContextLess.context.nav.pop(); // Close dialog
                    _buildRouting(); // Then redirect to dashboard
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildPaymentFailedDialog() {
    return showDialog(
      context: ContextLess.context,
      builder: (_) => CustomDialog(
        title: S.of(context).paymentFailed,
        des: S.of(context).paymentFailedDes,
        assetName: Assets.svg.cancelIcon,
        buttonText: S.of(context).close,
        callback: () {
          ContextLess.context.nav.pop();
        },
      ),
    );
  }
}

class WebPaymentScreenArg {
  final int? orderId;
  final String paymentUrl;
  WebPaymentScreenArg({
    this.orderId,
    required this.paymentUrl,
  });
}
