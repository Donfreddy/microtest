import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AuthenticationProvider {
  final FirebaseAuth firebaseAuth;

  //FirebaseAuth instance
  AuthenticationProvider(this.firebaseAuth);

  //Constructor to initialize the FirebaseAuth instance

  //Using Stream to listen to Authentication State
  Stream<User?> get authState => firebaseAuth.idTokenChanges();

  //SIGN IN METHOD
  Future<void> signIn(BuildContext context,
      {required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      context.loaderOverlay.hide();
    } on FirebaseAuthException catch (e) {
      context.loaderOverlay.hide();
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: e.message ?? e.code,
          textStyle: const TextStyle().copyWith(fontSize: 12),
          messagePadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      );
    }
  }

  //SIGN OUT METHOD
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
