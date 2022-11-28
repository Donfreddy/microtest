import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
      SnackBar snackBar = SnackBar(
        content: Text(e.message ?? e.code),
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //SIGN OUT METHOD
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
