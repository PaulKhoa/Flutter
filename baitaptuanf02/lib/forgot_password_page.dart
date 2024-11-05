import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String otp = '';
  bool otpSent = false;

  // Hàm tạo OTP 6 số
  String generateOTP() {
    int randomNum = Random().nextInt(900000) + 100000; // Tạo số ngẫu nhiên từ 100000 đến 999999
    return randomNum.toString();
  }

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
      _otpController.clear(); // Xóa trường nhập OTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP đã được gửi đến email của bạn!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi OTP')),
      );
    }
  }

  // Hàm xử lý gửi yêu cầu đặt lại mật khẩu
  Future<void> _resetPassword() async {
    if (_otpController.text == otp) { // Sửa tên biến ở đây
      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email đặt lại mật khẩu đã được gửi')),
        );
        Navigator.pop(context); // Quay lại trang trước đó
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mã OTP không chính xác.')),
      );
      _otpController.clear(); // Xóa trường nhập OTP để người dùng nhập lại
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quên Mật Khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reset your password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.teal),
              ),
            ),
            SizedBox(height: 20),
            if (otpSent) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Nhập OTP',
                  prefixIcon: Icon(Icons.lock, color: Colors.teal),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Xác nhận OTP', style: TextStyle(fontSize: 18)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  sendOtp(_emailController.text); // Gửi OTP
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Gửi OTP', style: TextStyle(fontSize: 18)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
