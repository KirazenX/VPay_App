import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpay_app2/models/local_file.dart';
import 'package:vpay_app2/pages/auth/signup_page.dart';
import 'package:vpay_app2/pages/bottom_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPW = false;
  bool _isLoading = false;


  final TextEditingController _etEmail = TextEditingController();
  final TextEditingController _etPassword = TextEditingController();

  void showPW() {
    setState(() {
      _showPW = !_showPW;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF338AE7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('$localImage/V-Pay White.png', width: 150),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _etEmail,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: "Email Address",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _etPassword,
                    obscureText: !_showPW,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      login(_etEmail.text, _etPassword.text);
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPW
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill,
                          color: Colors.grey,
                        ),
                        onPressed: showPW,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Daftar Disini!",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF344ABA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  login(_etEmail.text, _etPassword.text);
                },
                child: _isLoading
                    ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.blue))
                    : const Text(
                  "Masuk",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login(String email, String password) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (email.isEmpty || password.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan Password tidak boleh kosong!")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      final userName = data?['name'] ?? 'User';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selamat datang kembali, $userName!")),
      );

      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Pengguna tidak ditemukan. Silakan daftar.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah. Coba lagi.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }

      _etEmail.clear();
      _etPassword.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
    finally {
      setState(() => _isLoading = false);
    }
  }
}
