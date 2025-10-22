import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// Ekranın durumunu (Giriş mi, Kayıt mı?) yöneten bir StateProvider
final isLoginProvider = StateProvider<bool>(
  (ref) => true,
); // Başlangıçta Giriş (Login)

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giriş/Kayıt durumunu izle
    final isLogin = ref.watch(isLoginProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLogin
              ? const AuthForm(isLogin: true)
              : const AuthForm(isLogin: false),
        ),
      ),
    );
  }
}

// --- Auth Formu Widget'ı ---
class AuthForm extends ConsumerStatefulWidget {
  final bool isLogin;
  const AuthForm({super.key, required this.isLogin});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Form gönderildiğinde çalışacak metot
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    // Yükleniyor durumunu ve hata mesajını sıfırla
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isLogin) {
        // Giriş yapma işlemi
        await ref.read(authProvider.notifier).login(_email, _password);
      } else {
        // Kayıt olma işlemi
        await ref
            .read(authProvider.notifier)
            .register(_name, _email, _password);
      }

      // Başarılı olursa, main.dart yönlendirmeyi otomatik yapacaktır.
    } catch (e) {
      // AuthNotifier'dan fırlatılan hatayı yakala
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // İşlem bitince loading'i kapat
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kayıt formu için Name alanı
          if (!widget.isLogin)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Adınız'),
              keyboardType: TextInputType.text,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Lütfen adınızı girin.' : null,
              onSaved: (val) => _name = val!,
            ),

          // Email alanı
          TextFormField(
            decoration: const InputDecoration(labelText: 'E-posta'),
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val == null || !val.contains('@')
                ? 'Geçerli bir e-posta adresi girin.'
                : null,
            onSaved: (val) => _email = val!,
          ),

          // Şifre alanı
          TextFormField(
            decoration: const InputDecoration(labelText: 'Şifre'),
            obscureText: true,
            validator: (val) => val == null || val.length < 6
                ? 'Şifre en az 6 karakter olmalıdır.'
                : null,
            onSaved: (val) => _password = val!,
          ),

          const SizedBox(height: 20),

          // Hata mesajı gösterimi
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Gönderme Butonu
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
            ),

          const SizedBox(height: 10),

          // Giriş/Kayıt geçiş butonu
          TextButton(
            onPressed: () {
              // Diğer duruma geçmek için StateProvider'ı güncelle
              ref.read(isLoginProvider.notifier).state = !widget.isLogin;
            },
            child: Text(
              widget.isLogin
                  ? 'Hesabınız yok mu? Kayıt Ol'
                  : 'Zaten hesabım var. Giriş Yap',
            ),
          ),
        ],
      ),
    );
  }
}
