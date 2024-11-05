import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // Thêm thư viện math
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String otp = '';
  bool otpSent = false;

  // Hàm gửi OTP đến email
  Future<void> sendOtp(String email) async {
    otp = generateOTP(); // Tạo OTP mới trước khi gửi

    final response = await http.post(
      Uri.parse('https://api.mailjet.com/v3.1/send'), // Sử dụng API Mailjet
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Basic ${base64Encode(utf8.encode('1332a41efd1adde94b1ed80ad1db1792:62f8ba1b90b003bee6a850603f9e9a19'))}', // Thay YOUR_API_KEY và YOUR_API_SECRET
      },
      body: jsonEncode({
        'Messages': [
          {
            'From': {
              'Email': 'locvbn13@gmail.com', // Thay bằng email của bạn
              'Name': 'KhaiHoan',
            },
            'To': [
              {
                'Email': email,
                'Name': 'Recipient Name',
              },
            ],
            'Subject': 'Your OTP Code',
            'TextPart': 'Your OTP code is $otp',
            'HTMLPart': '<h3>Your OTP code is <strong>$otp</strong></h3>',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        otpSent = true; // Đánh dấu rằng OTP đã được gửi
      });
      otpController.clear(); // Xóa trường nhập OTP
      FocusScope.of(context).requestFocus(FocusNode()); // Đặt con trỏ vào trường OTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP đã được gửi thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi OTP')),
      );
    }
  }

  Future<void> register() async {
    if (otpController.text == otp) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Lưu thông tin người dùng vào Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': emailController.text.trim(),
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công!')),
        );

        // Đăng ký thành công, chuyển đến trang chủ
        Navigator.pushReplacementNamed(context, '/home'); // Đảm bảo đường dẫn này đúng
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi trong quá trình đăng ký. Vui lòng thử lại!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mã OTP không chính xác. Vui lòng nhập lại!')),
      );
      otpController.clear(); // Xóa trường nhập OTP để người dùng nhập lại
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (otpSent) ...[
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'Nhập OTP'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Đăng Ký'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  sendOtp(emailController.text);
                },
                child: Text('Gửi OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm tạo OTP 6 số
  String generateOTP() {
    // Sử dụng Random từ thư viện math
    int randomNum = Random().nextInt(900000) + 100000; // Tạo số ngẫu nhiên từ 100000 đến 999999
    return randomNum.toString();
  }
}