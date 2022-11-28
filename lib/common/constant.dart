import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// firebase
final FirebaseFirestore databaseReference = FirebaseFirestore.instance;
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

// hive
const String userBoxName = 'USER';

// Provider logo (PNG)
const String orangeLogo = 'assets/images/Orange-Money.png';
const String mtnLogo = 'assets/images/Mtn-MoMo.png';
