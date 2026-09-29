import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

Future<void> updateTopupToDone(
  String topupId,
  Map<String, dynamic> topupData,
) async {
  final uid = topupData['uid'];
  final nominal = topupData['nominal'];
  final timestamp = Timestamp.now();

  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final topupRef = userRef.collection('topups').doc(topupId);

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw Exception('User tidak ditemukan');

      int saldoSekarang = userSnap.get('balance') ?? 0;
      num saldoBaru = saldoSekarang + nominal;

      transaction.update(userRef, {'balance': saldoBaru});

      transaction.update(topupRef, {
        'status': 'selesai',
        'completedAt': timestamp,
      });

      final transaksiRef = userRef.collection('transactions').doc();
      transaction.set(transaksiRef, {
        'jenisTransaksi': 'topup',
        'total': nominal,
        'timestamp': timestamp,
        'deskripsi': 'Top-up saldo',
        'type': 'in',
      });

      final notifQuery =
          await userRef
              .collection('notifications')
              .where('type', isEqualTo: 'aktivitas')
              .where('topupId', isEqualTo: topupId)
              .limit(1)
              .get();

      if (notifQuery.docs.isNotEmpty) {
        transaction.update(notifQuery.docs.first.reference, {
          'type': 'selesai',
          'title': 'Top-up berhasil',
          'message': 'Saldo sebesar Rp $nominal telah masuk.',
          'timestamp': timestamp,
        });
      } else {
        final notifRef = userRef.collection('notifications').doc();
        transaction.set(notifRef, {
          'type': 'selesai',
          'title': 'Top-up berhasil',
          'message': 'Saldo sebesar Rp $nominal telah masuk.',
          'timestamp': timestamp,
        });
      }
    });

    debugPrint("op-up [$topupId] berhasil diproses dan saldo ditambahkan.");
  } catch (e) {
    debugPrint("Gagal update topup [$topupId]: $e");
  }
}
