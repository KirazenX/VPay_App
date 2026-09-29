import 'package:flutter/material.dart';

import 'konfirmasi_pengisian_page.dart';

class TopupNominalPage extends StatefulWidget {
  final String merchant;

  const TopupNominalPage({super.key, required this.merchant});

  @override
  State<TopupNominalPage> createState() => _TopupNominalPageState();
}

class _TopupNominalPageState extends State<TopupNominalPage> {
  final _ctrl = TextEditingController();

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
        title: Text(
          widget.merchant,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E4E4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah Isi Saldo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFD9F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Text(
                            'Rp. ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan Nominal',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _ctrl.clear(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Cara isi Saldo V-Pay di ${widget.merchant}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStep(1, 'Tentukan jumlah isi saldo'),
                    _buildStep(2, 'Tunjukkan kode bayar ke kasir'),
                    _buildStep(3, 'Saldo akan diterima setelah pembayaran'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final v = int.tryParse(_ctrl.text);
                  if (v != null && v > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => KonfirmasiPengisianPage(
                              merchant: widget.merchant,
                              nominal: v,
                            ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFD9F9),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Text(
              step.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
