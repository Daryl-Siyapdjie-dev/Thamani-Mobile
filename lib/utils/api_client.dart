import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/utils/request_handler.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    ApiInterceptors.addInterceptors(_dio);
  }

  Map<String, dynamic> defaultHeaders = {
    HttpHeaders.authorizationHeader: null,
  };

  Future<Response> get(String url, {Map<String, dynamic>? query}) async {
    // Normalize URL to remove double slashes (but keep http:// or https://)
    // This regex replaces sequences of 2+ slashes with a single slash, 
    // except after the colon in http:// or https://
    url = url.replaceAll(RegExp(r'(?<!https?:)/(/)+'), '/');
    
    // Handle case where URL starts with // (should become http://)
    if (url.startsWith('//')) {
      url = 'http:$url';
    }
    
    return _dio.get(
      url,
      queryParameters: query,
      options: Options(
        headers: defaultHeaders,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    // Normalize URL to remove double slashes (but keep http:// or https://)
    url = url.replaceAll(RegExp(r'(?<!https?:)/(/)+'), '/');
    if (url.startsWith('//')) {
      url = 'http:$url';
    }
    
    return _dio.post(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: ((status) {
          return status != null && status <= 500;
        }),
      ),
    );
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    // Normalize URL to remove double slashes (but keep http:// or https://)
    url = url.replaceAll(RegExp(r'(?<!https?:)/(/)+'), '/');
    if (url.startsWith('//')) {
      url = 'http:$url';
    }
    
    return _dio.put(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: ((status) {
          return status != null && status <= 500;
        }),
      ),
    );
  }

  Future<Response> delete(String url,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? query}) async {
    // Normalize URL to remove double slashes (but keep http:// or https://)
    url = url.replaceAll(RegExp(r'(?<!https?:)/(/)+'), '/');
    if (url.startsWith('//')) {
      url = 'http:$url';
    }
    
    return _dio.delete(
      url,
      data: data,
      queryParameters: query,
      options: Options(
        headers: headers ?? defaultHeaders,
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: ((status) {
          return status != null && status <= 500;
        }),
      ),
    );
  }

  void updateToken({required String token}) {
    defaultHeaders[HttpHeaders.authorizationHeader] = 'Bearer $token';
    debugPrint(
        'Update Token:${defaultHeaders[HttpHeaders.authorizationHeader]}');
  }
}

final apiClientProvider = Provider((ref) => ApiClient());
