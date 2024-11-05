import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart'; // Trang đăng nhập
import 'home_page.dart'; // Trang chủ
import 'forgot_password_page.dart'; // Trang quên mật khẩu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.teal[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
      initialRoute: '/', // Đường dẫn khởi đầu
      routes: {
        '/': (context) => LoginPage(), // Đường dẫn đến trang đăng nhập
        '/home': (context) => HomePage(), // Đường dẫn đến trang chủ
        '/forgot_password': (context) => ForgotPasswordPage(), // Đường dẫn đến trang quên mật khẩu
      },
    );
  }
}
