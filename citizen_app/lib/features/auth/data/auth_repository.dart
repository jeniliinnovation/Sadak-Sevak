import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final user = User.fromJson(response.data);
      if (user.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', user.token!);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', user.role);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String name, String email, String password, {String role = 'citizen'}) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      final user = User.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      final user = User.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}
