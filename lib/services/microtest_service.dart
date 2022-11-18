import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../common/constant.dart';

class MicroTestService {
  Future<void> requestMoney(String userId, int amount, String provider) async {
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
          'provider': provider,
          'date': DateTime.now(),
          'status': 'complete',
          'type': 'cash out',
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
        'type': 'cash out',
      });
    }
  }

  Future<DocumentSnapshot> getAllTransactions(String userId) async {
    return databaseReference
        .collection('users')
        .doc(userId)
        .collection('Transactions')
        .doc()
        .get();
  }

  Future<int> getBalance(String userId) async {
    final response = await databaseReference
        .collection('Users')
        .doc(userId)
        .get()
        .catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });

    if (kDebugMode) {
      print(response);
    }

    return response['balance'] as int;
  }

  Future<void> addTransaction(String userId, Map<String, dynamic> data) async {
    await databaseReference
        .collection('Users')
        .doc(userId)
        .collection('Transactions')
        .add(data)
        .catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  Future<void> updateBalance(String userId, int newBalance) async {
    await databaseReference.collection('Users').doc(userId).update({
      'balance': newBalance,
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }
}
