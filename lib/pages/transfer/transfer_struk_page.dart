import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vpay_app2/models/local_file.dart';
import 'package:vpay_app2/pages/homepage.dart';

class TransferStrukPage extends StatelessWidget {
  final String name;
  final String accountNumber;
  final int amount;

  const TransferStrukPage({
    super.key,
    required this.name,
    required this.accountNumber,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final dateNow = DateFormat(
      'dd MMM yyyy HH:mm:ss',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF338AE7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Image.asset("$localImage/V-Pay Blue.png", height: 30),
                    const Divider(thickness: 1),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Berhasil!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Nominal"),
                    const SizedBox(height: 4),
                    Text(
                      "Rp${NumberFormat('#,###', 'id_ID').format(amount)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 10),
                    RowText(title: "Tipe Transaksi", value: "Transfer"),
                    RowText(title: "Ke", value: name),
                    RowText(title: "Nama Bank", value: "V-Pay"),
                    RowText(title: "Nomor Rekening", value: accountNumber),
                    RowText(title: "Tanggal", value: "$dateNow WIB"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage()),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("~~~Terimakasih telah menggunakan V-Pay~~~"),
            ],
          ),
        ),
      ),
    );
  }
}

class RowText extends StatelessWidget {
  final String title;
  final String value;

  const RowText({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
