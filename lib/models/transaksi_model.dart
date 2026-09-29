import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String type;
  final int amount;
  final DateTime date;
  final String description;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  factory TransactionModel.fromFirestore(Map<String, dynamic> map) {
    return TransactionModel(
      type: map['type'] ?? '',
      amount: map['amount'] ?? 0,
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
    );
  }
}
