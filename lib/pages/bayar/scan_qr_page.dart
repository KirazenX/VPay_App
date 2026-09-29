import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vpay_app2/pages/bayar/detail_transaksi_page.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  void _onDetect(BarcodeCapture barcodeCapture) {
    debugPrint("QR terdeteksi");

    if (_isScanned) return;

    if (barcodeCapture.barcodes.isEmpty) {
      debugPrint("Tidak ada barcode terdeteksi.");
      return;
    }

    final Barcode barcode = barcodeCapture.barcodes.first;
    final String? rawValue = barcode.rawValue;

    debugPrint("Isi QR: $rawValue");

    if (rawValue == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("QR tidak terbaca.")));
      return;
    }

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded.containsKey("jenisTransaksi") &&
          decoded.containsKey("merchant") &&
          decoded.containsKey("produk") &&
          decoded.containsKey("nominal") &&
          decoded.containsKey("biayaAdmin")) {
        setState(() {
          _isScanned = true;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR berhasil dipindai!')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => DetailTransaksiPage(
                  dataQR: Map<String, dynamic>.from(decoded),
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR tidak memiliki data yang sesuai.")),
        );
      }
    } catch (e) {
      debugPrint("QR ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR tidak valid atau tidak bisa dibaca.")),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          'Scan QR',
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
      body: MobileScanner(
        controller: cameraController,
        fit: BoxFit.contain,
        onDetect: _onDetect,
      ),
    );
  }
}
