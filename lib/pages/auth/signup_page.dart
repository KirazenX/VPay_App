import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpay_app2/models/local_file.dart';
import 'package:vpay_app2/pages/auth/login_page.dart';
import 'package:vpay_app2/pages/bottom_nav.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  final TextEditingController _etName = TextEditingController();
  final TextEditingController _etPhone = TextEditingController();
  final TextEditingController _etEmail = TextEditingController();
  final TextEditingController _etPassword = TextEditingController();
  final TextEditingController _etConfirmPassword = TextEditingController();

  Future<void> signUp(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.length < 8) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lengkapi semua data dan buat password minimal 8 karakter!")),
      );
      return;
    }

    if (password != _etConfirmPassword.text) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Konfirmasi Password tidak cocok!")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;
      String accountNumber = generateAccountNumber();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'balance': 0,
        'accountNumber': accountNumber,
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
            'jenisTransaksi': 'pemasukan',
            'merchant': 'System',
            'produk': 'Saldo Awal',
            'nominal': 0,
            'biayaAdmin': 0,
            'total': 0,
            'timestamp': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selamat datang, $name! Akunmu berhasil dibuat 🚀"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal daftar: ${e.message}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String generateAccountNumber() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(
      1000000000000,
    );
    return random.toString().padLeft(12, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF338AE7),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('$localImage/V-Pay White.png', width: 150),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: _etName,
                      label: "Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _etPhone,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _etEmail,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _etPassword,
                      obscureText: !_showPassword,
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
                            _showPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _etConfirmPassword,
                      obscureText: !_showConfirmPassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: "Konfirmasi Password",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins",
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Masuk disini',
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
                    signUp(
                      _etName.text,
                      _etPhone.text,
                      _etEmail.text,
                      _etPassword.text,
                    );
                  },
                  child: _isLoading
                      ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.blue))
                      : const Text(
                    "Daftar",
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
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
