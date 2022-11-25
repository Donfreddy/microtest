import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreProvider {
  //FirebaseFirestore instance
  final FirebaseFirestore db;

  //Constructor to initialize the FirebaseAuth instance
  FirestoreProvider(this.db);

  // REQUEST MONEY METHOD
  Future<void> requestMoney(
      String userId, int amount, int phone, String provider) async {
    const maxAmount = 10000;

    // get current balance
    var currentBalance = await getBalance(userId);

    if (amount < maxAmount) {
      if (amount < currentBalance) {
        final newBalance = currentBalance - amount;

        // process transaction and update user balance
        await updateBalance(userId, newBalance);

        await addTransaction(userId, {
          'amount': newBalance,
          'phone': phone,
          'provider': provider,
          'date': DateTime.now(),
          'status': 'complete',
          'type': 'cashout',
        });
      } else {
        //
      }
    } else {
      await addTransaction(userId, {
        'amount': amount,
        'provider': provider,
        'date': DateTime.now(),
        'status': 'pending',
        'type': 'cashout',
      });
    }
  }

  // DEPOSIT MONEY
  Future<void> deposit(String userId, int amount, int phone) async {
    // get current balance
    var currentBalance = await getBalance(userId);

    final newBalance = currentBalance + amount;

    await db.collection('Users').doc(userId).update({
      'balance': newBalance,
    });

    await addTransaction(userId, {
      'amount': amount,
      'date': DateTime.now(),
      'status': 'complete',
      'type': 'cashint',
    });
  }

  // GET ALL TRANSACTIONS METHOD
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTransactions(
      String userId) {
    return db
        .collection('users')
        .doc(userId)
        .collection('Transactions')
        .snapshots();
  }

  // GET BALANCE METHOD
  Future<int> getBalance(String userId) async {
    final response = await db.collection('users').doc(userId).get();

    if (kDebugMode) {
      print(response);
    }

    return response['balance'] as int;
  }

  // GET USER DocumentSnapshot METHOD
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String userId) {
    return db.collection('users').doc(userId).snapshots();
  }

  // ADD TRANSACTION METHOD
  Future<void> addTransaction(String userId, Map<String, dynamic> data) async {
    await db
        .collection('Users')
        .doc(userId)
        .collection('Transactions')
        .add(data);
  }

  // UPDATE BALANCE METHOD
  Future<void> updateBalance(String userId, int newBalance) async {
    await db.collection('Users').doc(userId).update({
      'balance': newBalance,
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }
}
