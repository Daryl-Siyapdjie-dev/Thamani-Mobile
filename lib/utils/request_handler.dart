import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class ApiInterceptors {
  static void addInterceptors(Dio dio) {
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';
    _addLoggerInterceptor(dio);
    _addResponseHandlerInterceptor(dio);
  }

  static void _addLoggerInterceptor(Dio dio) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  static void _addResponseHandlerInterceptor(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) async {
        try {
          // Check if response data is a String (which means Dio tried to parse HTML as JSON and failed)
          // or if it's HTML content
          if (response.data is String) {
            final dataString = response.data as String;
            // Check if response is HTML (common indicators)
            final trimmedData = dataString.trim();
            if (trimmedData.startsWith('<!DOCTYPE') || 
                trimmedData.startsWith('<html') ||
                trimmedData.toLowerCase().startsWith('<head>') ||
                trimmedData.toLowerCase().contains('<!doctype html>') ||
                (trimmedData.startsWith('<') && trimmedData.contains('</html>'))) {
              // Server returned HTML instead of JSON (likely 404, redirect, or wrong endpoint)
              debugPrint('ERROR: Server returned HTML instead of JSON for URL: ${response.requestOptions.uri}');
              debugPrint('Response status: ${response.statusCode}');
              debugPrint('Response headers: ${response.headers}');
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: 'Server returned HTML instead of JSON. The API endpoint may be incorrect. URL: ${response.requestOptions.uri}',
                ),
              );
              return;
            }
          }
          
          // Check if response is JSON (Map or List)
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            final message = data['message'];
            switch (response.statusCode) {
              case 401:
                _handleUnauthorized();
                break;
              case 302:
              case 400:
              case 403:
              case 404:
              case 409:
              case 422:
              case 500:
                GlobalFunction.showCustomSnackbar(
                  message: message?.toString() ?? 'An error occurred',
                  isSuccess: false,
                );
                break;
              default:
                break;
            }
          }
          handler.next(response); // Forward the response
        } catch (e) {
          // If there's any error processing the response, reject it
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Error processing response: $e',
            ),
          );
        }
      },
      onError: (error, handler) {
        // Better error handling for parsing errors
        if (error.type == DioExceptionType.unknown || 
            error.type == DioExceptionType.badResponse ||
            error.type == DioExceptionType.receiveTimeout) {
          final errorMessage = error.error?.toString() ?? '';
          final stackTrace = error.stackTrace.toString();
          
          // Check for JSON parsing errors (these occur when server returns HTML instead of JSON)
          if (errorMessage.contains('is not a subtype of type') ||
              errorMessage.contains('Expected a value of type') ||
              errorMessage.contains('FormatException') ||
              errorMessage.contains('type \'String\' is not a subtype') ||
              stackTrace.contains('dio_mixin.dart') ||
              stackTrace.contains('DioMixin.fetch')) {
            
            // Try to get response data to check if it's HTML
            String? responseData;
            if (error.response?.data is String) {
              responseData = error.response!.data as String;
            } else if (error.response?.data != null) {
              responseData = error.response!.data.toString();
            }
            
            final isHtml = responseData != null && (
              responseData.trim().startsWith('<!DOCTYPE') || 
              responseData.trim().startsWith('<html') ||
              responseData.trim().toLowerCase().contains('<!doctype html>') ||
              responseData.trim().toLowerCase().contains('<head>')
            );
            
            debugPrint('═══════════════════════════════════════════════════════════');
            debugPrint('ERROR: JSON Parsing failed for URL: ${error.requestOptions.uri}');
            debugPrint('Error type: ${error.type}');
            debugPrint('Response status: ${error.response?.statusCode}');
            debugPrint('Is HTML response: $isHtml');
            debugPrint('═══════════════════════════════════════════════════════════');
            
            // This is a JSON parsing error, likely because server returned HTML
            final dioError = DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: isHtml 
                ? 'Server returned HTML instead of JSON. The API endpoint URL may be incorrect: ${error.requestOptions.uri}'
                : 'Server returned an invalid response format. Please verify the API endpoint URL: ${error.requestOptions.uri}',
            );
            handleError(dioError);
            handler.reject(dioError);
            return;
          }
        }
        
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        } else {
          handleError(error);
        }
        handler.reject(error); // Forward the error
      },
    ));
  }

  static String handleError(DioException exception) {
    String errorMessage;
    switch (exception.type) {
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive time out!';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send time out!';
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            'Bad response! Error code: ${exception.response?.statusCode}';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad Certificate response!';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled!';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error! Please check your internet.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'An unknown error occurred';
        break;
      default:
        errorMessage = 'An unexpected error occurred';
    }
    GlobalFunction.showCustomSnackbar(
      message: errorMessage,
      isSuccess: false,
    );
    return errorMessage;
  }

  static void _handleUnauthorized() {
    GlobalFunction.showCustomSnackbar(
      message: 'Unauthorized',
      isSuccess: false,
    );
    Box authBox = Hive.box(AppConstants.authBox);
    authBox.delete(AppConstants.authToken);
    GlobalFunction.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }
}
