import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vpay_app2/pages/bottom_nav.dart';

class KonfirmasiPengisianPage extends StatelessWidget {
  final String merchant;
  final int nominal;

  const KonfirmasiPengisianPage({
    super.key,
    required this.merchant,
    required this.nominal,
  });

  String _genKode() {
    final rnd = Random();
    return List.generate(12, (_) => rnd.nextInt(10)).join();
  }

  Future<void> _simpan(BuildContext ctx, String code) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final timestamp = Timestamp.now();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final topupRef = await userRef.collection('topups').add({
      'merchant': merchant,
      'nominal': nominal,
      'status': 'pending',
      'timestamp': timestamp,
      'kodePembayaran': code,
    });

    await userRef.collection('notifications').add({
      'type': 'aktivitas',
      'title': 'Top-up diproses',
      'message': 'Permintaan top-up Rp $nominal ke $merchant sedang diproses',
      'timestamp': timestamp,
      'topupId': topupRef.id,
      'nominal': nominal,
    });

    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Permintaan terkirim')));
    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (context) => BottomNav()));
  }

  @override
  Widget build(BuildContext context) {
    final code = _genKode();
    return Scaffold(
      backgroundColor: const Color(0xFF338AE7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E4E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tunjukkan kode ini ke kasir',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFD9F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Center(
                        child: SelectableText(
                          code.replaceAllMapped(
                            RegExp(r".{4}"),
                            (m) => "${m.group(0)} ",
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cara isi Saldo V-Pay di $merchant',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),
                    _buildStep(1, 'Tunjukkan kode bayar ke kasir $merchant'),
                    _buildStep(2, 'Bayar jumlah isi saldo dengan uang tunai'),
                    _buildStep(
                      3,
                      'Setelah pembayaran berhasil, saldomu akan masuk',
                    ),
                    _buildStep(
                      4,
                      'Mohon simpan bukti pembayaran sebagai jaminan jika diperlukan',
                    ),
                    const SizedBox(height: 4),
                    _buildStep(
                      5,
                      'Hindari isi saldo pada pukul 23:55–00:10 WIB karena $merchant sedang tidak aktif pada waktu tersebut',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _simpan(context, code),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFD9F9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  'Konfirmasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
