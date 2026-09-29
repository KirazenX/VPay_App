import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/transaksi_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc.data()))
              .toList();
        });
  }

  int calculateBalance(List<TransactionModel> transactions) {
    int balance = 0;
    for (var tx in transactions) {
      if (tx.type == 'masuk') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }
}
