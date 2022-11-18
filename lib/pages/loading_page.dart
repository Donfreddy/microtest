import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:microtest/pages/home.dart';

import '../common/constant.dart';
import 'login_page.dart';

class LoadingPage extends StatefulWidget {
  static const routeName = '/';

  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = Hive.box(userBoxName).get('userId', defaultValue: null);
    startLoadingTimer();
  }

  startLoadingTimer() async {
    Duration duration = const Duration(seconds: 1);
    return Timer(
      duration,
      () {
        Navigator.pushReplacementNamed(
          context,
          userId != null ? Home.routeName : LoginPage.routeName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
