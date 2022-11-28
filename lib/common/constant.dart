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

// Cam-pay app
const String appId = 'M5IEuxoSe6-KmA9BDImlN6fiUb94aXa4XnXslnOFW6j4V5-LWzhrGTeqieiBL60Y2UW8uv5Cx16eTFyt8e2ojw';
const String appUsername = 'c_GoCtK20pkDknF89Z1eF8R2FGQseB6BLz9WDn95ySwuPzrId9ZsS-sqMiU44jOQi2d2eXrLOD5VJ4hXatr2Sg';
const String appPassword = 'UwD1Fdn_n2qMtOxnhH3GrW2opH87MUYDAYdcGRjn81FYmSL4Ziz78UtWttu_pvURBKUwBiIFJf_FhMVnSwL7CA';
const String appWebhookKey = 'rsgNqkSSA1eFGKDkTyAWZQ6VtWKpZNZ9aOW8ZSBH5YCo86MmxNExj4l1hXBvtxe6UEdUQOVqjdN51F5Qe_69Og';


const String baseUrl = 'https://demo.campay.net/api';
