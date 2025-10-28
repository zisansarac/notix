import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

final isLoginProvider = StateProvider<bool>((ref) => true);

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = ref.watch(isLoginProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Uygulama logosu/başlığı
                    Text(
                      isLogin ? 'Hoş Geldiniz!' : 'Yeni Hesap Oluştur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLogin
                        ? const AuthForm(isLogin: true)
                        : const AuthForm(isLogin: false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isLogin) {
        await ref.read(authProvider.notifier).login(_email, _password);
      } else {
        await ref
            .read(authProvider.notifier)
            .register(_name, _email, _password);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
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
          if (!widget.isLogin)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Adınız'),
              keyboardType: TextInputType.text,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Lütfen adınızı girin.' : null,
              onSaved: (val) => _name = val!,
            ),

          TextFormField(
            decoration: const InputDecoration(labelText: 'E-posta'),
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val == null || !val.contains('@')
                ? 'Geçerli bir e-posta adresi girin.'
                : null,
            onSaved: (val) => _email = val!,
          ),

          TextFormField(
            decoration: const InputDecoration(labelText: 'Şifre'),
            obscureText: true,
            validator: (val) => val == null || val.length < 6
                ? 'Şifre en az 6 karakter olmalıdır.'
                : null,
            onSaved: (val) => _password = val!,
          ),

          const SizedBox(height: 20),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
            ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: () {
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
