import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vpay_app2/pages/bayar/struk_page.dart';

class DetailTransaksiPage extends StatelessWidget {
  final Map<String, dynamic> dataQR;

  String formatRekening(String noRekening) {
    return noRekening.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
  }

  DetailTransaksiPage({super.key, required this.dataQR});

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> getUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<void> prosesPembayaran(BuildContext context) async {
    int nominal = dataQR['nominal'];
    int biayaAdmin = dataQR['biayaAdmin'];
    int totalBayar = nominal + biayaAdmin;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userNotifRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();
    final userTransactionRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc();

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) throw Exception("User tidak ditemukan!");

        int saldoSekarang = snapshot.get('balance');
        if (saldoSekarang < totalBayar) {
          throw Exception('Saldo tidak mencukupi');
        }

        transaction.update(userDoc, {'balance': saldoSekarang - totalBayar});

        Map<String, dynamic> transaksiData = {
          'uid': userId,
          'merchant': dataQR['merchant'],
          'produk': dataQR['produk'],
          'jenisTransaksi': dataQR['jenisTransaksi'],
          'nominal': nominal,
          'biayaAdmin': biayaAdmin,
          'total': totalBayar,
          'timestamp': FieldValue.serverTimestamp(),
        };

        transaction.set(userTransactionRef, transaksiData);
        transaction.set(userTransactionRef, {...transaksiData, 'type': 'out'});

        transaction.set(userNotifRef, {
          'uid': userId,
          'type': 'selesai',
          'title': 'Pembayaran Berhasil',
          'message':
              'Kamu telah membayar ke ${dataQR['merchant']} sebesar Rp ${NumberFormat("#,##0", "id_ID").format(totalBayar)}',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => StrukPage(dataTransaksi: {...dataQR, 'total': totalBayar}),
        ),
      );
    } catch (e) {
      debugPrint('Gagal proses pembayaran: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nominal = dataQR['nominal'];
    final biayaAdmin = dataQR['biayaAdmin'];
    final total = nominal + biayaAdmin;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          'Konfirmasi Pembayaran',
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
      body: Container(
        color: Color(0xFF338AE7),
        child: Column(
          children: [
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userData = snapshot.data ?? {};
                    final accountNumber = userData['accountNumber'] ?? 'Tidak tersedia';
                    final rekeningFormatted = formatRekening(accountNumber);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Jenis Transaksi", dataQR['jenisTransaksi']),
                        _buildRow("Merchant", dataQR['merchant']),
                        _buildRow("Produk", dataQR['produk']),
                        _buildRow("Sumber Dana", "Rekening\n$rekeningFormatted"),
                        _buildRow("Nominal", formatRupiah(nominal)),
                        _buildRow("Biaya Admin", formatRupiah(biayaAdmin)),
                        Divider(),
                        _buildRow("Total Bayar", formatRupiah(total), isBold: true),
                      ],
                    );
                  },
                )
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                ),
                onPressed: () => prosesPembayaran(context),
                child: Text(
                  "Bayar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatRupiah(int nominal) {
    return 'Rp ${NumberFormat("#,##0", "id_ID").format(nominal)}';
  }
}
