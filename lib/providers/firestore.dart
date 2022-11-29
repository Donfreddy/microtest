import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
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
  Future<void> requestMoney(BuildContext context, String userId, int amount,
      int phone, String provider) async {
    const maxAmount = 10000;

    // get current balance
    var currentBalance = await getBalance(userId);

    if (amount < maxAmount) {
      if (amount < currentBalance) {
        final newBalance = currentBalance - amount;

        // process transaction and update user balance
        // await updateBalance(userId, newBalance);
        //
        // await addTransaction(userId, {
        //   'amount': amount,
        //   'phone': phone,
        //   'provider': provider,
        //   'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
        //   'date': DateTime.now(),
        //   'status': 'complete',
        //   'type': 'cashout',
        // });
      } else {
        //
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
    var cron = Cron();

    // make payment
    var data = {
      "amount": "$amount",
      "from": "237$phone",
      "currency": "XAF",
      "description": "Test",
      "external_reference": DateTime.now().toIso8601String()
    };
    var paymentResponse = await ApiService.makePayment(context, data);

    // Check transaction status and update account
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      if (kDebugMode) {
        print('every minutes');
      }

      print("########################## statusResponse['status']");
      var statusResponse =
          await ApiService.getPaymentStatus(paymentResponse['reference']);
      print("########################## statusResponse");
      print(statusResponse);

      print("########################## status");
      print(statusResponse['status']);

      // get current balance
      var currentBalance = await getBalance(userId);
      var newAmount = int.parse(statusResponse['amount']);
      final newBalance = currentBalance + newAmount;

      if (statusResponse['status'] == 'SUCCESSFUL') {
        print("########################## status SUCCESSFUL");
        await updateBalance(userId, newBalance);
        await addTransaction(userId, {
          'amount': newAmount,
          'phone': phone,
          'date': DateTime.now(),
          'status': 'complete',
          'provider': statusResponse['operator'],
          'provider_logo': '',
          'type': 'cashint',
        });
        cron.close();
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
        await cron.close();
      }
    });
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
    return response['balance'] as int;
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
