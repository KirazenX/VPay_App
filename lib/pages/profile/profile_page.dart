import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vpay_app2/models/local_file.dart';
import 'package:vpay_app2/pages/auth/login_page.dart';
import 'package:vpay_app2/pages/profile/account_info_page.dart';
import 'package:vpay_app2/pages/profile/report_problem_page.dart';
import 'package:vpay_app2/pages/profile/security_page.dart';
import 'about_vpay_page.dart';
import 'help_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = snapshot.data();
    setState(() {
      name = data?['name'] ?? 'User';
      photoUrl = data?['photoUrl'];
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi Logout"),
            content: const Text(
              "Apakah Anda yakin ingin keluar dari akun ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Keluar"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context, 'updated'),
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      photoUrl != null
                          ? NetworkImage(photoUrl!)
                          : const AssetImage('$localImage/Profil.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    Icons.person_outline,
                    'Account Info',
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountInfoPage(),
                        ),
                      );

                      if (result == 'updated') {
                        _loadProfile();
                      }
                    },
                  ),

                  _buildMenuTile(Icons.lock_outline, 'Security', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityPage()),
                    );
                  }),
                  _buildMenuTile(
                    Icons.report_gmailerrorred_outlined,
                    'Report Problem',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportProblemPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(Icons.help_outline, 'Help Center', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                    );
                  }),
                  _buildMenuTile(
                    Icons.info_outline,
                    'About V-Pay',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutVPayPage()),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, color: Colors.black),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (showDivider) const Divider(thickness: 1.2, height: 10, color: Colors.black26,),
      ],
    );
  }
}
