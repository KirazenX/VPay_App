import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vpay_app2/models/local_file.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = snapshot.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      setState(() {
        photoUrl = data['photoUrl'];
      });
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));

    Navigator.pop(context, 'updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Account Info',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  photoUrl != null
                      ? NetworkImage(photoUrl!)
                      : const AssetImage('$localImage/Profil.png'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Change Profile',
                style: TextStyle(
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildField('Name', _nameController),
            const SizedBox(height: 16),
            _buildField('Phone Number', _phoneController),
            const SizedBox(height: 16),
            _buildField('Email', _emailController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1867B3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.edit),
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
