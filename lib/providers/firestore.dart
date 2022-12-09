import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:microtest/api/api_service.dart';
import 'package:microtest/common/constant.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class FirestoreProvider {
  //FirebaseFirestore instance
  final FirebaseFirestore db;

  //Constructor to initialize the FirebaseAuth instance
  FirestoreProvider(this.db);

  // REQUEST MONEY METHOD
  Future<void> requestMoney(
    BuildContext context, {
    required String userId,
    required int amount,
    required int phone,
    required String provider,
  }) async {
    const maxAmount = 101;

    // get current balance
    var currentBalance = await getBalance(userId);

    if (amount < currentBalance) {
      if (amount < maxAmount) {
        var withdrawResponse = await ApiService.withdraw({
          "amount": "$amount",
          "to": "237$phone",
          "description": "Test",
          "external_reference": DateTime.now().toIso8601String()
        });

        if (withdrawResponse['reference'] != null) {
          await addTransaction(userId, {
            'amount': amount,
            'phone': phone,
            'provider': provider,
            'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
            'date': Timestamp.now(),
            'status': 'success',
            'manual_confirm': false,
            'type': 'cashout',
            'userId': userId,
          });
          final newBalance = currentBalance - amount;
          await updateBalance(userId, newBalance);
          showTopSnackBar(
            context,
            CustomSnackBar.success(
              message: 'Transaction réussie',
              textStyle:
                  const TextStyle().copyWith(fontSize: 12, color: Colors.white),
              messagePadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );
        }
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message:
                'Oops, quelque chose s\'est mal passé. Veuillez réessayer plus tard',
            textStyle:
                const TextStyle().copyWith(fontSize: 12, color: Colors.white),
            messagePadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      } else {
        await addTransaction(userId, {
          'amount': amount,
          'phone': phone,
          'provider': provider,
          'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
          'date': Timestamp.now(),
          'status': 'pending',
          'manual_confirm': true,
          'type': 'cashout',
          'userId': userId,
        });
        showTopSnackBar(
          context,
          CustomSnackBar.info(
            message:
                'votre transaction a été initiée et devrait être acceptée dans les plus brefs délais',
            textStyle:
                const TextStyle().copyWith(fontSize: 12, color: Colors.white),
            messagePadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      }
    } else {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message:
              'Votre solde est insuffisant pour effectuer cette transaction',
          textStyle:
              const TextStyle().copyWith(fontSize: 12, color: Colors.white),
          messagePadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }
  }

  // DEPOSIT MONEY
  Future<void> deposit(BuildContext context,
      {required String userId, required int amount, required int phone}) async {
    // https: //stackoverflow.com/questions/54617432/looking-up-a-deactivated-widgets-ancestor-is-unsafe
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
        .collection('transactions')
        .orderBy('date', descending: true)
        .where('userId', isEqualTo: userId)
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
