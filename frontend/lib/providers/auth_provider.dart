import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

// 1. Durum (State) Modeli: Bu Provider'ın ne tür veriyi yöneteceğini tanımlarız.
// UserModel? -> Oturum açıksa kullanıcı bilgileri, kapalıysa null.

typedef AuthState = UserModel?;

// 2. Auth Provider Tanımı
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // ApiService'i kullanarak bağımlılığı inject ediyoruz.
  final apiService = ref.watch(apiServiceProvide);
  return AuthNotifier(apiService);
});

// 3. Auth Notifier: Durum yönetimini sağlayan sınıf
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(null) {
    // Uygulama başlar başlamaz token kontrolü yap (Önemli detay!)
    _checkInitialAuth();
  }

  // Uygulama ilk açıldığında token kontrolü yapar.
  Future<void> _checkInitialAuth() async {
    // secure_storage'da token olup olmadığını kontrol et.
    // Basit olması için şimdilik sadece varlığını kontrol ediyoruz.
    // Gerçekte, token'ı alıp backend'de /me rotasıyla doğrulamak gerekir.
    final token = await _apiService.getToken();
    if (token != null) {
      // Varsayımsal olarak token'ı bulduk, kullanıcıyı 'giriş yapmış' kabul edebiliriz
      // Daha sonra buradan id ve email'i de storage'a kaydederek daha dolu bir model oluşturabiliriz.
      // Şimdilik sadece uygulamanın UI'ını açmasını sağlamak için state'i null olmayan bir şey yapalım.
      state = UserModel(
        id: 0,
        name: 'Guest',
        email: 'loading@auth.com',
        token: token,
      );
    }
  }

  // Kayıt Fonksiyonu
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      // API'den gelen kullanıcı ve token verisini al.
      final user = UserModel.fromJson(response.data);

      //Token'ı güvenli depolamaya kaydet
      await _apiService.saveToken(user.token);

      // Durumu güncelle
      state = user;
    } on DioException catch (e) {
      // Hata durumunu yakala ve UI'a yansıtmak için hata fırlat
      // Backend'den gelen hata mesajını kullan (400, 401 hataları)
      throw e.response?.data['message'] ?? 'Kayıt başarısız oldu.';
    }
  }

  // Giriş Fonksiyonu
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // API'den gelen kullanıcı ve token verisini al.
      final user = UserModel.fromJson(response.data);

      //Token'ı güvenli depolamaya kaydet
      await _apiService.saveToken(user.token);

      // Durumu güncelle
      state = user;
    } on DioException catch (e) {
      // Hata durumunu yakala ve UI'a yansıtmak için hata fırlat
      throw e.response?.data['message'] ?? 'Giriş başarısız oldu.';
    }
  }

  // Çıkış Fonskiyonu

  Future<void> logout() async {
    //Güvenli depolamadan token'ı sil
    await _apiService.deleteToken();

    //Durumu null yap
    state = null;
  }
}
