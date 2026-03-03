import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/sign_up.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/user.dart';
import 'package:ready_ecommerce/models/eCommerce/common/common_response.dart';
import 'package:ready_ecommerce/services/common/apple_sign_in_service.dart';
import 'package:ready_ecommerce/services/common/google_sign_in_service.dart';
import 'package:ready_ecommerce/services/common/hive_service_provider.dart';
import 'package:ready_ecommerce/services/eCommerce/auth_service/auth_service.dart';
import 'package:ready_ecommerce/utils/api_client.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController(ref));

class AuthController extends StateNotifier<bool> {
  final Ref ref;
  AuthController(this.ref) : super(false);

  Future<CommonResponse> singUp({required SingUp singUpInfo}) async {
    state = true;
    final response =
        await ref.read(authServiceProvider).signUp(singUpInfo: singUpInfo);
    final String message = response.data['message'];
    if (response.statusCode == 200) {
      final userInfo = User.fromMap(response.data['data']['user']);
      final accessToken = response.data['data']['access']['token'];
      ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
      ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    }
    state = false;
    return CommonResponse(isSuccess: false, message: message);
  }

  Future<CommonResponse> sendOTP(
      {required String phone, required bool isForgot}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .sendOTP(phone: phone, isForgot: isForgot);
      final String message = response.data['message'];
      final String otp = response.data['data']['otp'].toString();
      state = false;
      return CommonResponse(isSuccess: true, message: message, data: otp);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> verifyOTP(
      {required String phone, required String otp}) async {
    try {
      state = true;
      final response =
          await ref.read(authServiceProvider).verifyOTP(phone: phone, otp: otp);
      final String message = response.data['message'];
      final String token = response.data['data']['token'];
      state = false;
      return CommonResponse(isSuccess: true, message: message, data: token);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> resetPassword({
    required String password,
    required String confrimPassword,
    required String forgotPasswordToken,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).resetPassword(
            password: password,
            confirmPassword: confrimPassword,
            forgotPasswordToken: forgotPasswordToken,
          );
      final String message = response.data['message'];

      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(
        isSuccess: false,
        message: message,
      );
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> login(
      {required String phone, required String password}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .login(phone: phone, password: password);
      final String message = response.data['message'];
      final userInfo = User.fromMap(response.data['data']['user']);
      final accessToken = response.data['data']['access']['token'];
      ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
      ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  /// Google Sign-In authentication
  /// Returns CommonResponse with success status and message
  Future<CommonResponse> googleSignIn() async {
    try {
      state = true;

      // Step 1: Trigger Google Sign-In flow
      final googleAccount =
          await ref.read(googleSignInServiceProvider).signIn();

      if (googleAccount == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Google Sign-In was cancelled',
        );
      }

      // Step 2: Get Google access token
      final accessToken = await ref
          .read(googleSignInServiceProvider)
          .getAccessToken(googleAccount);

      if (accessToken == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Failed to get Google access token',
        );
      }

      // Step 3: Send access token to backend (with FCM token automatically included)
      final response = await ref
          .read(authServiceProvider)
          .googleAuth(accessToken: accessToken);

      final String message = response.data['message'];

      // Step 4: Save user data and token (same as manual login)
      if (response.statusCode == 200) {
        final userInfo = User.fromMap(response.data['data']['user']);
        final backendToken = response.data['data']['access']['token'];

        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
        ref
            .read(hiveServiceProvider)
            .saveUserAuthToken(authToken: backendToken);
        ref.read(apiClientProvider).updateToken(token: backendToken);

        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }

      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (error) {
      state = false;
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  /// Apple Sign-In authentication
  /// Returns CommonResponse with success status and message
  Future<CommonResponse> appleSignIn() async {
    try {
      state = true;

      // Step 1: Trigger Apple Sign-In flow
      final appleAccount = await ref.read(appleSignInServiceProvider).signIn();

      if (appleAccount == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Apple Sign-In was cancelled',
        );
      }

      // Step 2: Send identity token and other details to backend
      final response = await ref.read(authServiceProvider).appleAuth(
            identityToken: appleAccount.identityToken!,
            authorizationCode: appleAccount.authorizationCode,
            givenName: appleAccount.givenName,
            familyName: appleAccount.familyName,
            email: appleAccount.email,
          );

      final String message = response.data['message'];

      // Step 3: Save user data and token (same as manual login)
      if (response.statusCode == 200) {
        final userInfo = User.fromMap(response.data['data']['user']);
        final backendToken = response.data['data']['access']['token'];

        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
        ref
            .read(hiveServiceProvider)
            .saveUserAuthToken(authToken: backendToken);
        ref.read(apiClientProvider).updateToken(token: backendToken);

        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }

      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (error) {
      state = false;
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword,
          );
      final String message = response.data['message'];
      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      } else {
        state = false;
        return CommonResponse(isSuccess: false, message: message);
      }
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> updateProfile(
      {required User userInfo, required File? file}) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).updateProfile(
            userInfo: userInfo,
            file: file,
          );
      final String message = response.data['message'];

      // Check if data and user exist to avoid null error on validation failures
      if (response.data['data'] != null &&
          response.data['data']['user'] != null) {
        final User userData = User.fromMap(response.data['data']['user']);
        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userData);
      }

      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());

      // Extract validation error message if available
      String errorMessage = error.toString();
      if (error is DioException && error.response?.data != null) {
        final responseData = error.response!.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }
      }

      return CommonResponse(isSuccess: false, message: errorMessage);
    }
  }

  Future<CommonResponse> logout() async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).logout();
      final String message = response.data['message'];
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }
}
