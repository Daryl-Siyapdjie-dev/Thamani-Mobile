import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/app_logo.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_text_field.dart';
import 'package:ready_ecommerce/components/ecommerce/apple_sign_in_button.dart';
import 'package:ready_ecommerce/components/ecommerce/google_sign_in_button.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/eCommerce/address/address_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/authentication/authentication_controller.dart';
import 'package:ready_ecommerce/controllers/misc/misc_controller.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/services/common/hive_service_provider.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class LoginLayout extends StatefulWidget {
  const LoginLayout({super.key});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final List<FocusNode> fNodes = [FocusNode(), FocusNode()];

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    phoneController.text = '';
    passwordController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Show congratulations dialog after successful login
  void _showCongratulationsDialog(BuildContext ctx, WidgetRef ref) {
    debugPrint('🎉 Showing congratulations dialog');

    // Load addresses first
    ref.read(addressControllerProvider.notifier).getAddress();

    // Show dialog immediately - simpler and more stable
    showDialog(
      barrierDismissible: false,
      context: ctx,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
          surfaceTintColor: colors(ctx).light,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 40.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Congratulations Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    Assets.png.congratilation.path,
                    height: 180.h,
                    fit: BoxFit.contain,
                  ),
                ),
                Gap(24.h),
                Text(
                  S.of(ctx).congratulations,
                  style: AppTextStyle(ctx).title.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: colors(ctx).primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                Gap(16.h),
                Text(
                  S.of(ctx).loginSuccessMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyle(ctx).bodyText.copyWith(
                        fontSize: 16.sp,
                      ),
                ),
                Gap(32.h),
                CustomButton(
                  buttonText: S.of(ctx).startShopping,
                  buttonColor: colors(ctx).primaryColor,
                  onPressed: () {
                    debugPrint('✅ User clicked start shopping');
                    Navigator.of(dialogContext).pop(); // Close dialog
                    // Navigate to dashboard
                    ctx.nav.pushNamedAndRemoveUntil(
                      Routes.getCoreRouteName(AppConstants.appServiceName),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: SizedBox(
          height: 60.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).dontHaveAccount,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Gap(5.w),
                GestureDetector(
                  onTap: () => context.nav.pushNamed(Routes.singUp),
                  child: Text(
                    S.of(context).signUp,
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors(context).primaryColor,
                        ),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(context),
                buildBody(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: colors(context).accentColor ?? EcommerceAppColor.offWhite,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(
              0,
              2,
            ),
          )
        ],
      ),
      child: const Center(
        child: AppLogo(
          isAnimation: true,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w)
          .copyWith(bottom: 20.h, top: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).welcomeBack,
            style: AppTextStyle(context)
                .title
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Gap(20.h),
          CustomTextFormField(
            name: S.of(context).emailOrPhone,
            hintText: S.of(context).emailOrPhone,
            textInputType: TextInputType.text,
            controller: phoneController,
            focusNode: fNodes[0],
            textInputAction: TextInputAction.next,
            validator: (value) => GlobalFunction.commonValidator(
              value: value!,
              hintText: S.of(context).emailOrPhone,
              context: context,
            ),
          ),
          Gap(20.h),
          Consumer(builder: (context, ref, _) {
            return CustomTextFormField(
              name: S.of(context).password,
              hintText: S.of(context).password,
              textInputType: TextInputType.text,
              focusNode: fNodes[1],
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: ref.watch(obscureText1),
              widget: IconButton(
                splashColor: Colors.transparent,
                onPressed: () {
                  ref.read(obscureText1.notifier).state =
                      !ref.read(obscureText1);
                },
                icon: Icon(
                  !ref.watch(obscureText1)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: colors(context).hintTextColor,
                ),
              ),
              validator: (value) => GlobalFunction.passwordValidator(
                value: value!,
                hintText: S.of(context).password,
                context: context,
              ),
            );
          }),
          Gap(20.h),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => context.nav.pushNamed(
                Routes.recoverPassword,
                arguments: true,
              ),
              child: Text(
                S.of(context).forgotPassword,
                style: AppTextStyle(context).bodyText,
              ),
            ),
          ),
          Gap(30.h),
          Consumer(builder: (context, ref, _) {
            return ref.watch(authControllerProvider)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CustomButton(
                    buttonText: S.of(context).login,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState!.validate()) {
                        ref
                            .read(authControllerProvider.notifier)
                            .login(
                              phone: phoneController.text,
                              password: passwordController.text,
                            )
                            .then((response) {
                          if (response.isSuccess) {
                            // Show congratulations dialog
                            _showCongratulationsDialog(context, ref);
                          }
                        });
                      }
                    },
                  );
          }),
          // Divider with "OR" text
          Gap(24.h),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colors(context).hintTextColor,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'OR',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: colors(context).hintTextColor,
                      ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colors(context).hintTextColor,
                  thickness: 1,
                ),
              ),
            ],
          ),
          Gap(24.h),
          // Google Sign-In Button
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(authControllerProvider);
              return GoogleSignInButton(
                isLoading: isLoading,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  ref
                      .read(authControllerProvider.notifier)
                      .googleSignIn()
                      .then((response) {
                    if (response.isSuccess) {
                      // Show congratulations dialog
                      _showCongratulationsDialog(context, ref);
                    } else {
                      // Show error via snackbar
                      GlobalFunction.showCustomSnackbar(
                        message: response.message,
                        isSuccess: false,
                      );
                    }
                  });
                },
              );
            },
          ),
          Gap(16.h),
          // Apple Sign-In Button
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(authControllerProvider);
              return AppleSignInButton(
                isLoading: isLoading,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  ref
                      .read(authControllerProvider.notifier)
                      .appleSignIn()
                      .then((response) {
                    if (response.isSuccess) {
                      // Show congratulations dialog
                      _showCongratulationsDialog(context, ref);
                    } else {
                      // Show error via snackbar
                      if (response.message != 'Apple Sign-In was cancelled') {
                        GlobalFunction.showCustomSnackbar(
                          message: response.message,
                          isSuccess: false,
                        );
                      }
                    }
                  });
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              return Align(
                alignment: Alignment.center,
                child: Visibility(
                  visible: !ref.read(hiveServiceProvider).userIsLoggedIn(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: TextButton(
                      onPressed: () {
                        context.nav.pushNamed(
                          Routes.getCoreRouteName(AppConstants.appServiceName),
                        );
                      },
                      child: Text(
                        S.of(context).skip,
                        style: AppTextStyle(context).buttonText,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
