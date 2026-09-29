import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<double> pemasukan = List.filled(7, 0.0);
  List<double> pengeluaran = List.filled(7, 0.0);
  double totalIn = 0.0;
  double totalOut = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
  }

  Future<void> fetchTransaksi() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      )
          .get();

      List<double> pemasukanTemp = List.filled(7, 0.0);
      List<double> pengeluaranTemp = List.filled(7, 0.0);
      double inSum = 0.0;
      double outSum = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        final DateTime tanggal = DateTime(timestamp.year, timestamp.month, timestamp.day);

        int selisihHari = tanggal.difference(startDate).inDays;
        if (selisihHari < 0 || selisihHari > 6) continue;

        final String jenis = (data['jenisTransaksi'] ?? '').toString().toLowerCase();
        final double total = (data['total'] ?? 0).toDouble();

        if (jenis == 'topup' || jenis == 'pemasukan') {
          pemasukanTemp[selisihHari] += total;
          inSum += total;
        } else {
          pengeluaranTemp[selisihHari] += total;
          outSum += total;
        }
      }

      setState(() {
        pemasukan = pemasukanTemp;
        pengeluaran = pengeluaranTemp;
        totalIn = inSum;
        totalOut = outSum;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil transaksi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatAngkaPendek(num value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    } else {
      return 'Rp $value';
    }
  }

  double getMaxTotal() {
    double maxIn = pemasukan.reduce((a, b) => a > b ? a : b);
    double maxOut = pengeluaran.reduce((a, b) => a > b ? a : b);
    double maxTotal = maxIn > maxOut ? maxIn : maxOut;

    return (maxTotal / 100000).ceil() * 100000;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final saldo = totalIn - totalOut;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Ringkasan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Grafik Pemasukan & Pengeluaran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                maxY: getMaxTotal(),
                                barGroups: List.generate(
                                  7,
                                  (i) => BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: pemasukan[i],
                                        color: Colors.green,
                                        width: 6,
                                      ),
                                      BarChartRodData(
                                        toY: pengeluaran[i],
                                        color: Colors.red,
                                        width: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 100000,
                                      // bisa diubah sesuai kebutuhan
                                      reservedSize: 60,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: Text(
                                            formatAngkaPendek(value),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        final now = DateTime.now();
                                        final tanggal = now.subtract(Duration(days: 6 - value.toInt()));
                                        final namaHari = DateFormat('E', 'id_ID').format(tanggal); // Contoh: 'Sen'
                                        return Text(
                                          namaHari,
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_circle_down,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Total Pemasukan = ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatter.format(totalIn),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_circle_up,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Total Pengeluaran = ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatter.format(totalOut),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Saldo saat ini = ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatter.format(saldo),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Bulanan - ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_circle_down,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Pemasukan Bulanan:',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      formatter.format(totalIn),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_circle_up,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Pengeluaran Bulanan:',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      formatter.format(totalOut),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saldo Akhir Bulan Ini:',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      formatter.format(saldo),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
