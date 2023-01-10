import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:microtest/api/api_service.dart';
import 'package:microtest/common/constant.dart';
import 'package:microtest/common/show_top_message.dart';

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
    context.loaderOverlay.show();
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

        Timer.periodic(const Duration(seconds: 10), (timer) async {
          var statusResponse =
              await ApiService.getPaymentStatus(withdrawResponse['reference']);

          if (statusResponse['status'] == 'SUCCESSFUL') {
            await addTransaction({
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
            context.loaderOverlay.hide();
            showTopMessage(
              context,
              message: 'Transaction réussie.',
              type: MessageType.success,
            );
            timer.cancel();
          } else if (statusResponse['status'] == 'FAILED') {
            await addTransaction({
              'amount': amount,
              'phone': phone,
              'provider': provider,
              'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
              'date': Timestamp.now(),
              'status': 'fail',
              'manual_confirm': false,
              'type': 'cashout',
              'userId': userId,
            });
            context.loaderOverlay.hide();
            showTopMessage(
              context,
              message:
                  'Oops, quelque chose s\'est mal passé. Veuillez réessayer plus tard',
              type: MessageType.error,
            );
            timer.cancel();
          }
        });
      } else {
        await addTransaction({
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
        context.loaderOverlay.hide();
        showTopMessage(
          context,
          message:
              'votre transaction a été initiée et devrait être acceptée dans les plus brefs délais.',
        );
      }
    } else {
      context.loaderOverlay.hide();
      showTopMessage(
        context,
        message: 'Votre solde est insuffisant pour effectuer cette transaction',
        type: MessageType.error,
      );
    }
  }

  // DEPOSIT MONEY
  Future<void> deposit(
    BuildContext context, {
    required String userId,
    required int amount,
    required int phone,
  }) async {
    context.loaderOverlay.show();
    bool result = await InternetConnectionChecker().hasConnection;
    if(result == true) {
      var paymentResponse = await ApiService.makePayment({
        "amount": "$amount",
        "from": "237$phone",
        "currency": "XAF",
        "description": "Test",
        "external_reference": DateTime.now().toIso8601String()
      });

      print("### paymentResponse");
      print(amount);
      print(paymentResponse);

      if (paymentResponse != null) {
        final provider = paymentResponse['operator'];
        final transactionId = paymentResponse['reference'];

        await addTransaction({
          'amount': amount,
          'phone': phone,
          'provider': provider,
          'provider_logo': provider == 'Orange' ? orangeLogo : mtnLogo,
          'date': Timestamp.now(),
          'status': 'pending',
          'manual_confirm': true,
          'type': 'cashout',
          'userId': userId,
        }, transactionId: transactionId);
        context.loaderOverlay.hide();
        showTopMessage(
          context,
          message:
          "Tapez sur *126# pour MTN ou #150*50# pour ORANGE pour confirmer la transaction.",
        );
        Timer.periodic(const Duration(seconds: 10), (timer) async {
          var statusResponse = await ApiService.getPaymentStatus(transactionId);

          if (statusResponse['status'] == 'SUCCESSFUL') {
            // get current balance
            var currentBalance = await getBalance(userId);
            final newBalance = currentBalance + amount;

            await updateBalance(userId, newBalance);
            await updateTransactionStatus(transactionId, 'success');
            showTopMessage(
              context,
              message: 'Transaction réussie.',
              type: MessageType.success,
            );
            timer.cancel();
          } else if (statusResponse['status'] == 'FAILED') {
            await updateTransactionStatus(transactionId, 'fail');
            showTopMessage(
              context,
              message: 'Transaction échouée.',
              type: MessageType.error,
            );
            timer.cancel();
          }
        });
      } else {
        context.loaderOverlay.hide();
        showTopMessage(
          context,
          message:
          "Il s'agit d'un système de démonstration. Le montant maximum est de 100 XAF.",
          type: MessageType.error,
        );
      }
    } else {
      context.loaderOverlay.hide();
      showTopMessage(
        context,
        message:
       "No internet connection",
        type: MessageType.error,
      );
    }
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
    return int.parse(response['balance']);
  }

  // GET USER DocumentSnapshot METHOD
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String userId) {
    return db.collection('users').doc(userId).snapshots();
  }

  // ADD TRANSACTION METHOD
  Future<void> addTransaction(Map<String, dynamic> data,
      {String? transactionId}) async {
    if (transactionId != null) {
      await db.collection('transactions').doc(transactionId).set(data);
    } else {
      await db.collection('transactions').add(data);
    }
  }

  // UPDATE BALANCE METHOD
  Future<void> updateBalance(String userId, int newBalance) async {
    await db.collection('users').doc(userId).update({'balance': "$newBalance"});
  }

  // UPDATE TRANSACTION STATUS METHOD
  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    await db
        .collection('transactions')
        .doc(transactionId)
        .update({'status': status});
  }
}
