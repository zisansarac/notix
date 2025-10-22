import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Riverpod için ana widget'ımızı ProviderScope ile sarmalamalıyız.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notix App',
      debugShowCheckedModeBanner: false, // Debug bandını kaldıralım
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      // Uygulama şimdilik Giriş/Kayıt ekranına yönlendirilecek
      home: const Text('Giriş Ekranı Gelecek'), // placeholder
    );
  }
}
