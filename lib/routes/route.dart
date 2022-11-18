import 'package:flutter/material.dart';
import 'package:microtest/pages/home.dart';
import 'package:microtest/pages/login_page.dart';

import '../pages/loading_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  String? routeName = settings.name;

  switch (routeName) {
    case LoadingPage.routeName:
      return MaterialPageRoute<Widget>(builder: (_) => const LoadingPage());
    case LoginPage.routeName:
      return MaterialPageRoute<Widget>(builder: (_) => const LoginPage());
    case Home.routeName:
      return MaterialPageRoute<Widget>(builder: (_) => const Home());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Route for $routeName is not defined'),
          ),
        ),
      );
  }
}
