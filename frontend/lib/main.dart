import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'screens/auth_screen.dart'; // Yeni ekran
import 'screens/notes_screen.dart'; // Yeni ekran

void main() {
  // Riverpod için ana widget'ımızı ProviderScope ile sarmalamalıyız.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // Artık ConsumerWidget kullanıyoruz
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authProvider'ı izle
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Notix App',
      debugShowCheckedModeBanner: false, // Debug bandını kaldıralım
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      // Uygulama şimdilik Giriş/Kayıt ekranına yönlendirilecek
      home: user == null
          ? const AuthScreen() // user null ise: Giriş/Kayıt ekranı
          : const NotesScreen(), // user varsa: Notlar ekranı
    );
  }
}
