import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:sadak_sevak_citizen/features/auth/presentation/screens/auth_screen.dart';
import 'package:sadak_sevak_citizen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle global errors like 401 Unauthorized
          if (e.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_role');
            debugPrint('401 Unauthorized: Cleared stale session.');

            // Redirect to Login
            SadakSevakApp.navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
