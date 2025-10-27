import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

typedef AuthState = UserModel?;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvide);
  return AuthNotifier(apiService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(null) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await _apiService.getToken();
    if (token != null) {
      state = UserModel(
        id: 0,
        name: 'Guest',
        email: 'loading@auth.com',
        token: token,
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final user = UserModel.fromJson(response.data);

      await _apiService.saveToken(user.token);

      state = user;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Kayıt başarısız oldu.';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final user = UserModel.fromJson(response.data);

      await _apiService.saveToken(user.token);

      state = user;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Giriş başarısız oldu.';
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
    state = null;
  }
}
