import 'package:flutter/material.dart';
import 'package:vpay_app2/models/local_file.dart';
import 'package:vpay_app2/pages/isi_saldo/topup_nominal_page.dart';

class PilihMerchantPage extends StatelessWidget {
  const PilihMerchantPage({super.key});

  void _pilihMerchant(BuildContext ctx, String merchant) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => TopupNominalPage(merchant: merchant)),
    );
  }

  Widget _buildMerchantCard(BuildContext ctx, String merchant, String asset) {
    return GestureDetector(
      onTap: () => _pilihMerchant(ctx, merchant),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFBFD9F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(asset, width: 50),
            const SizedBox(width: 16),
            Text(
              merchant,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF338AE7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          'Isi Saldo V-Pay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E4E4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih metode untuk mengisi\nsaldo V-Pay anda:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildMerchantCard(
                context,
                'Indomaret',
                '$localImage/indomaret.png',
              ),
              _buildMerchantCard(
                context,
                'Alfamart',
                '$localImage/alfamart.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
