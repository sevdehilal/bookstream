import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart'; // Register sayfasını import ediyoruz
import '../models/login.dart'; // LoginModel'i import ediyoruz
import '../services/service.dart'; // loginUser fonksiyonunu içeren servis dosyasını import ediyoruz
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(); // Kullanıcı adı
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    print('Kullanıcı adı: "$username"');
    print('Şifre: "$password"');

    setState(() {
      _isLoading = true;
    });

    try {
      LoginModel? user = await ApiService.loginUser(username, password);

      if (user != null) {
        String token = user.token;
        print("Token: $token");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // Token'ı sakla

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(initialIndex: 2)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Geçersiz kullanıcı adı veya şifre")),
        );
      }
    } catch (e) {
      String errorMessage = 'Giriş işlemi başarısız';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/logo.png',
                    height: 100,
                  ),
                  SizedBox(height: 32),
                  // Kullanıcı adı alanı
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Şifre alanı
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Giriş yap butonu
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 38, 97, 94),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 16),
                  // Kayıt Ol bağlantısı
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Hesabınız yok mu? Kayıt Ol',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 97, 94),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
