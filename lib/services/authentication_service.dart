import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../common/constant.dart';

class AuthenticationService {
  User? user;

  Future<User?> loginWithEmail(
      {required String email, required String password}) async {
    try {
      var userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      if (kDebugMode) {
        print(userCredential);
        print(user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
      }
    }
    return user;
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }
}
