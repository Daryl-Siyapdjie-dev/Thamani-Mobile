import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/sign_up.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/user.dart';
import 'package:ready_ecommerce/services/base/eCommerce/auth_provider_base.dart';
import 'package:ready_ecommerce/utils/api_client.dart';

final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService implements AuthProviderBase {
  final Ref ref;
  AuthService(this.ref);
  @override
  Future<Response> signUp({
    required SingUp singUpInfo,
  }) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await ref.read(apiClientProvider).post(
      AppConstants.registrationUrl,
      data: {
        ...singUpInfo.toMap(),
        'device_key': fcmToken,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      },
    );
    return response;
  }

  @override
  Future<Response> sendOTP(
      {required String phone, required bool isForgot}) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.sendOTP,
      data: {
        "phone": phone,
        "forgot_password ": isForgot == true ? 1 : 0,
      },
    );
    return response;
  }

  @override
  Future<Response> login(
      {required String phone, required String password}) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await ref.read(apiClientProvider).post(
      AppConstants.loginUrl,
      data: {
        "phone": phone,
        "password": password,
        "device_key": fcmToken,
        "device_type": Platform.isIOS ? 'ios' : 'android',
      },
    );
    return response;
  }

  @override
  Future<Response> verifyOTP(
      {required String phone, required String otp}) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.verifyOtp,
      data: {
        "phone": phone,
        "otp": otp,
      },
    );
    return response;
  }

  @override
  Future<Response> resetPassword({
    required String password,
    required String confirmPassword,
    required String forgotPasswordToken,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.resetPassword,
      data: {
        "password": password,
        "password_confirmation": confirmPassword,
        "token": forgotPasswordToken,
      },
    );
    return response;
  }

  @override
  Future<Response> logout() async {
    final response =
        await ref.read(apiClientProvider).post(AppConstants.logout);

    return response;
  }

  @override
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.changePassword,
      data: {
        "current_password": oldPassword,
        "password": newPassword,
        "password_confirmation": confirmNewPassword,
      },
    );
    return response;
  }

  @override
  Future<Response> updateProfile(
      {required User userInfo, required File? file}) async {
    // Create user map and exclude profile_photo URL to avoid sending URL instead of file
    final Map<String, dynamic> userMap = userInfo.toMap();
    userMap.remove('profile_photo'); // Remove URL from user data

    FormData formData = FormData.fromMap({
      if (file != null)
        "profile_photo": await MultipartFile.fromFile(file.path,
            filename: 'profile_photo.jpg'),
      ...userMap,
    });
    final response = await ref
        .read(apiClientProvider)
        .post(AppConstants.updateProfile, data: formData);
    return response;
  }

  @override
  Future<Response> googleAuth({required String accessToken}) async {
    // Get FCM token for push notifications (same as login/signup)
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    final response = await ref.read(apiClientProvider).post(
      AppConstants.googleAuthUrl,
      data: {
        "access_token": accessToken,
        "device_key": fcmToken,
        "device_type": Platform.isIOS ? 'ios' : 'android',
      },
    );
    return response;
  }
}
