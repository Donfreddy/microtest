import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:microtest/api/api_service.dart';
import 'package:microtest/common/constant.dart';

class FirestoreProvider {
  //FirebaseFirestore instance
  final FirebaseFirestore db;

  //Constructor to initialize the FirebaseAuth instance
  FirestoreProvider(this.db);

  // REQUEST MONEY METHOD
  Future<void> requestMoney(BuildContext context,
      {required String userId,
      required int amount,
      required int phone,
      required String provider}) async {
    const maxAmount = 10000;

    // get current balance
    var currentBalance = await getBalance(userId);

    if (amount < maxAmount) {
      if (amount < currentBalance) {
        // request money
        var data = {
          "amount": "$amount",
          "to": "237$phone",
          "description": "Test",
          "external_reference": DateTime.now().toIso8601String()
        };
        var withdrawResponse = await ApiService.withdraw(data);

        print("########################## withdrawResponse");
        print(withdrawResponse);
        print(withdrawResponse['reference']);

        if (withdrawResponse['reference'] != null) {
          final newBalance = currentBalance - amount;
          // process transaction and update user balance
          await updateBalance(userId, newBalance);

          await addTransaction(userId, {
            'amount': amount,
            'phone': phone,
            'provider': provider,
            'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
            'date': DateTime.now(),
            'status': 'complete',
            'type': 'cashout',
          });
        }
      } else {
        SnackBar snackBar = const SnackBar(
          content: Text('Sorry you cannot request under 100F'),
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      await addTransaction(userId, {
        'amount': amount,
        'phone': phone,
        'provider': provider,
        'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
        'date': DateTime.now(),
        'status': 'pending',
        'type': 'cashout',
      });
    }
  }

  // DEPOSIT MONEY
  Future<void> deposit(BuildContext context,
      {required String userId, required int amount, required int phone}) async {
    // make deposit
    var data = {
      "amount": "$amount",
      "from": "237$phone",
      "currency": "XAF",
      "description": "Test",
      "external_reference": DateTime.now().toIso8601String()
    };
    var paymentResponse = await ApiService.makePayment(data);

    Timer.periodic(const Duration(seconds: 20), (timer) async {
      if (kDebugMode) {
        print('every minutes');
      }

      print("########################## statusResponse['status']");
      var statusResponse =
          await ApiService.getPaymentStatus(paymentResponse['reference']);

      if (statusResponse != null) {
        print("########################## status");
        print(statusResponse['status']);

        // get current balance
        var currentBalance = await getBalance(userId);
        // var amountDouble = statusResponse['amount'] as String;
        // var newAmount = int.parse(amountDouble.toString());
        final newBalance = currentBalance + amount;

        if (statusResponse['status'] == 'SUCCESSFUL') {
          print("########################## status SUCCESSFUL");
          await updateBalance(userId, newBalance);
          await addTransaction(userId, {
            'amount': newBalance,
            'phone': phone,
            'date': DateTime.now(),
            'status': 'complete',
            'provider': statusResponse['operator'],
            'provider_logo': '',
            'type': 'cashint',
          });
          timer.cancel();
        }

        if (statusResponse['status'] == 'FAILED') {
          print("########################## status FAILED");
          await addTransaction(userId, {
            'amount': amount,
            'phone': phone,
            'date': DateTime.now(),
            'status': 'failed',
            'provider': statusResponse['operator'],
            'provider_logo': '',
            'type': 'cashint',
          });
          timer.cancel();
        }
      }
    });

    // Check transaction status and update account
  }

  // GET ALL TRANSACTIONS METHOD
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTransactions(
      String userId) {
    return db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots();
  }

  // GET BALANCE METHOD
  Future<int> getBalance(String userId) async {
    final response = await db.collection('users').doc(userId).get();
    return int.parse(response['balance']);
  }

  // GET USER DocumentSnapshot METHOD
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String userId) {
    return db.collection('users').doc(userId).snapshots();
  }

  // ADD TRANSACTION METHOD
  Future<void> addTransaction(String userId, Map<String, dynamic> data) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add(data);
  }

  // UPDATE BALANCE METHOD
  Future<void> updateBalance(String userId, int newBalance) async {
    await db.collection('users').doc(userId).update({'balance': newBalance});
  }
}
