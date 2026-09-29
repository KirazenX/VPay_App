import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vpay_app2/pages/profile/profile_page.dart';
import 'package:vpay_app2/pages/transfer/transfer_pilih_page.dart';
import '../models/local_file.dart';
import 'bayar/scan_qr_page.dart';
import 'isi_saldo/pilih_merchant_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int? _balance;
  String? _name;
  bool _isLoading = true;
  late String _accountNumber;

  String formatRekening(String noRekening) {
    return noRekening.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();
        if (data != null) {
          setState(() {
            _balance = data['balance'];
            _name = data['name'];
            _isLoading = false;
            _accountNumber = data['accountNumber'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text.replaceAll(" ", "")));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nomor rekening disalin ke clipboard')),
    );
  }

  Widget _buildActionButton(Widget iconWidget, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
          child: iconWidget,
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.indigo)),
      ],
    );
  }

  Widget _buildTransactionCard({
    required Widget icon,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
    required Color cardColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: Image.asset(
          "$localImage/V-Pay White.png",
          width: 100,
          height: 40,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                if (result == 'updated') {
                  _loadProfile();
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('$localImage/Profil.png'),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Selamat Datang\n",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _name ?? "User",
                                    style: TextStyle(
                                      color: Colors.indigo[900],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Saldo",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatCurrency(_balance ?? 0),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[900],
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _copyToClipboard(_accountNumber),
                              child: Row(
                                children: [
                                  Text(
                                    "No. Rekening ${formatRekening(_accountNumber)}",
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.copy, size: 16),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScanQRPage(),
                                      ),
                                    );
                                  },
                                  child: _buildActionButton(
                                    Image.asset(
                                      '$localImage/bayar.png',
                                      width: 48,
                                      height: 48,
                                    ),
                                    "Bayar",
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PilihMerchantPage(),
                                      ),
                                    );
                                  },
                                  child: _buildActionButton(
                                    Image.asset(
                                      '$localImage/isiVpay.png',
                                      width: 48,
                                      height: 48,
                                    ),
                                    "Isi V-Pay",
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => TransferPilihPage(),
                                      ),
                                    );
                                  },
                                  child: _buildActionButton(
                                    Image.asset(
                                      '$localImage/transfer.png',
                                      width: 48,
                                      height: 48,
                                    ),
                                    "Transfer",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      Text(
                        "Riwayat Transaksi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildTransactionCard(
                        icon: Image.asset(
                          '$localImage/google_play.png',
                          width: 30,
                        ),
                        title: "Pembayaran Google Play",
                        date: "25 Desember 2024",
                        amount: "-Rp1.500.000",
                        amountColor: Colors.red,
                        cardColor: Colors.grey[100]!,
                      ),
                      _buildTransactionCard(
                        icon: Image.asset('$localImage/indosat.png', width: 30),
                        title: "Pembayaran Pulsa",
                        date: "10 Desember 2024",
                        amount: "-Rp100.000",
                        amountColor: Colors.red,
                        cardColor: Colors.grey[100]!,
                      ),
                      _buildTransactionCard(
                        icon: Image.asset(
                          '$localImage/tfDiterima.png',
                          width: 30,
                        ),
                        title: "Transfer Diterima\nDari Goddokira",
                        date: "18 November 2024",
                        amount: "+Rp2.000.000",
                        amountColor: Colors.green,
                        cardColor: Colors.grey[100]!,
                      ),
                      _buildTransactionCard(
                        icon: Image.asset(
                          '$localImage/tfDikirim.png',
                          width: 30,
                        ),
                        title: "Transfer Dikirim\nKepada Yuzaa",
                        date: "1 November 2024",
                        amount: "-Rp500.000",
                        amountColor: Colors.red,
                        cardColor: Colors.grey[100]!,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
