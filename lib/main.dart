import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:microtest/pages/loading_page.dart';
import 'package:microtest/routes/route.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microtest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: LoadingPage.routeName,
      onGenerateRoute: generateRoute,
    );
  }
}
