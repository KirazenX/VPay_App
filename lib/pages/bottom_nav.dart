import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/local_file.dart';
import 'homepage.dart';
import 'keuangan_page.dart';
import 'notifikasi_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      const Homepage(),
      KeuanganPage(),
      const NotifikasiPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                '$localImage/beranda.png',
                width: 20,
                height: 20,
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                '$localImage/keuangan.png',
                width: 20,
                height: 20,
              ),
              label: 'Keuangan',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                '$localImage/notifikasi.png',
                width: 20,
                height: 20,
              ),
              label: 'Notifikasi',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
