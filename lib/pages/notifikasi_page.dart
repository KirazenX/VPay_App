import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/admin_topup_done.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  int activeTabIndex = 0;

  final List<String> tabTypes = ["aktivitas", "selesai"];

  Stream<QuerySnapshot> _getNotifications(String type) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Widget _buildNotificationList(String type) {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey(type),
      stream: _getNotifications(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint("Stream error: ${snapshot.error}");
          return const Center(child: Text("Terjadi kesalahan."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint("Tidak ada data notifikasi untuk type: $type");
          return const Center(child: Text("Tidak ada notifikasi."));
        }

        final docs = snapshot.data!.docs;
        for (var doc in docs) {
          debugPrint("Notifikasi [${doc.id}]: ${doc.data()}");
        }

        return ListView(
          children:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                final title = data['title'] ?? 'Judul Tidak Ada';
                final message = data['message'] ?? 'Pesan tidak ditemukan';

                return ListTile(
                  leading: Icon(
                    _getNotificationIcon(type, title),
                    color: _getNotificationColor(type, title),
                  ),
                  title: Text(title),
                  subtitle: Text(message),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (timestamp != null)
                        Text(
                          DateFormat('dd MMM, HH:mm').format(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (type == "selesai")
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Hapus Notifikasi"),
                                content: Text("Yakin ingin menghapus notifikasi ini?"),
                                actions: [
                                  TextButton(
                                    child: Text("Batal"),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: Text("Hapus"),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('notifications')
                                  .doc(doc.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Notifikasi dihapus")),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  onTap: () async {
                    if (type == 'aktivitas' && title == 'Top-up diproses') {
                      final topupId = data['topupId'];
                      final nominal = data['nominal'];
                      final uid = userId;

                      if (topupId != null && nominal != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Konfirmasi Top-up"),
                            content: Text("Apakah Anda sudah melakukan pembayaran untuk top-up ini?"),
                            actions: [
                              TextButton(
                                child: Text("Batal"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: Text("Konfirmasi"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              content: Row(
                                children: const [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16),
                                  Text("Memproses top-up..."),
                                ],
                              ),
                            ),
                          );

                          try {
                            await updateTopupToDone(topupId, {
                              'uid': uid,
                              'nominal': nominal,
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Top-up dikonfirmasi.")),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal memproses top-up: $e")),
                            );
                          }

                          Future.delayed(const Duration(milliseconds: 300), () {
                            setState(() {});
                          });
                        }
                      }
                    }
                  },
                );

              }).toList(),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type, String title) {
    if (type == 'aktivitas') return Icons.warning_amber_rounded;

    if (title.toLowerCase().contains('top-up')) {
      return Icons.add_card_outlined;
    } else if (title.toLowerCase().contains('pembayaran')) {
      return Icons.payment;
    } else {
      return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type, String title) {
    if (type == 'aktivitas') return Colors.red;

    if (title.toLowerCase().contains('top-up')) {
      return Colors.blue;
    } else if (title.toLowerCase().contains('pembayaran')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(tabTypes.length, (index) {
          final isActive = activeTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  activeTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: EdgeInsets.only(
                  right: index == 0 ? 8 : 0,
                  left: index == 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? const Color(0xFF338AE7)
                          : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index == 0 ? "Aktivitas" : "Selesai",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(child: _buildNotificationList(tabTypes[activeTabIndex])),
        ],
      ),
    );
  }
}
