import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:microtest/pages/home.dart';
import 'package:microtest/pages/login_page.dart';
import 'package:microtest/services/authentication.dart';
import 'package:provider/provider.dart';

import 'common/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize FireBase
  await Firebase.initializeApp();

  //Initialize Hive
  await Hive.initFlutter();

  //Open Hive Box for user
  await Hive.openBox(userBoxName);

  // Only portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationProvider>().authState,
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: 'Microtest',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Authenticate(),
      ),
    );
  }
}

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    return firebaseUser != null ? const Home() : const LoginPage();
  }
}
