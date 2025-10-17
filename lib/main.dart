import 'package:flutter/material.dart';
import 'package:flowershop/pages/login_page.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await Token.getToken();

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
