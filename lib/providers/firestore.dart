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
              message: 'Oops, Something went wrong. please try again later',
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
              'Your transaction has been initiated and should be accepted as soon as possible.',
        );
      }
    } else {
      context.loaderOverlay.hide();
      showTopMessage(
        context,
        message: 'Your balance is insufficient to complete this transaction',
        type: MessageType.error,
      );
    }
  }

  // SEND MONEY
  Future<void> send(
    BuildContext context, {
    required String userId,
    required int amount,
    required String accountNumber,
  }) async {
    context.loaderOverlay.show();
    bool result = await InternetConnectionChecker().hasConnection;

    if (result == true) {
      var currentBalance = await getBalance(userId);
      if (amount < currentBalance) {
        // get and update beneficial user
        final data = await getUserByAccountNumber(accountNumber);
        if (data.size == 0) {
          context.loaderOverlay.hide();
          showTopMessage(
            context,
            message: "No account was found!",
            type: MessageType.error,
          );
        } else {
          final newBalance = currentBalance - amount;
          await updateBalance(userId, newBalance);

          final userBalance = int.parse(data.docs[0].data()['balance']);
          final newBalance2 = userBalance + amount;
          await updateBalance(data.docs[0].id, newBalance2);

          await addTransaction({
            'amount': amount,
            'phone': data.docs[0].data()['phone_number'],
            'provider': 'N/A',
            'provider_logo': '',
            'date': Timestamp.now(),
            'status': 'success',
            'manual_confirm': false,
            'type': 'cashout',
            'userId': userId,
          });

          context.loaderOverlay.hide();
          showTopMessage(
            context,
            message: 'Transaction successful.',
            type: MessageType.success,
          );
        }
      } else {
        context.loaderOverlay.hide();
        showTopMessage(
          context,
          message: 'Your balance is insufficient to complete this transaction',
          type: MessageType.error,
        );
      }
    } else {
      context.loaderOverlay.hide();
      showTopMessage(
        context,
        message: "No internet connection",
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
    if (result == true) {
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
              "Type *126# for MTN or #150*50# for ORANGE to confirm the transaction.",
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
              message: 'Transaction successful.',
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
          message: "This is a demo system. The maximum amount is 100 XAF.",
          type: MessageType.error,
        );
      }
    } else {
      context.loaderOverlay.hide();
      showTopMessage(
        context,
        message: "No internet connection",
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

  // GET USER BY ACCOUNT NUMBER
  Future<QuerySnapshot<Map<String, dynamic>>> getUserByAccountNumber(
      String accountNumber) async {
    return db
        .collection('users')
        .where('account_number', isEqualTo: accountNumber)
        .limit(1)
        .get();
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
