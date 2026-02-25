import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ready_ecommerce/config/app_color.dart';

AppColors colors(context) => Theme.of(context).extension<AppColors>()!;
ThemeData getAppTheme(
    {required BuildContext context, required bool isDarkTheme}) {
  AppColor appColor = AppColorManager.getColorClass(serviceName: 'serviceName');
  return ThemeData(
    useMaterial3: true,
    extensions: <ThemeExtension<AppColors>>[
      AppColors(
        primaryColor: appColor.primaryColor,
        accentColor:
            isDarkTheme ? const Color(0xFF2D2D2D) : appColor.accentColor,
        secondaryColor: appColor.secondaryColor,
        buttonColor: appColor.buttonColor,
        bodyTextColor: isDarkTheme ? appColor.light : appColor.dark,
        light: appColor.light,
        dark: appColor.dark,
        bodyTextSmallColor:
            isDarkTheme ? appColor.accentColor : appColor.bodyTextSmallColor,
        headingColor: isDarkTheme ? appColor.light : appColor.dark,
        hintTextColor: appColor.hintTextColor,
        errorColor: appColor.errorColor,
      ),
    ],
    fontFamily: 'Mulish',
    unselectedWidgetColor: appColor.accentColor,
    scaffoldBackgroundColor:
        isDarkTheme ? const Color(0xFF121212) : appColor.light,
    appBarTheme: AppBarTheme(
      // toolbarHeight: 80.h,
      backgroundColor:
          isDarkTheme ? const Color(0xFF121212) : appColor.light,
      titleTextStyle: TextStyle(
        color: isDarkTheme ? appColor.light : appColor.dark,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
      centerTitle: false,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDarkTheme ? appColor.light : appColor.dark,
      ),
    ),
    colorScheme: ColorScheme(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      primary: appColor.primaryColor,
      onPrimary: appColor.accentColor,
      secondary: appColor.secondaryColor,
      onSecondary: appColor.secondaryColor,
      error: appColor.errorColor,
      onError: appColor.errorColor,
      surface: isDarkTheme ? const Color(0xFF121212) : appColor.light,
      onSurface: isDarkTheme ? appColor.light : appColor.dark,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      modalBarrierColor: isDarkTheme
          ? const Color(0xFF2D2D2D).withOpacity(0.8)
          : appColor.accentColor.withOpacity(0.8),
      backgroundColor:
          isDarkTheme ? const Color(0xFF1E1E1E) : EcommerceAppColor.white,
      modalBackgroundColor:
          isDarkTheme ? const Color(0xFF1E1E1E) : EcommerceAppColor.white,
      surfaceTintColor:
          isDarkTheme ? const Color(0xFF1E1E1E) : EcommerceAppColor.white,
    ),
  );
}
