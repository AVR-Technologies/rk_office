import 'package:flutter/material.dart';
import 'package:rk_office/constants/routes.dart';
import 'package:rk_office/pages/anthem_page.dart';
import 'package:rk_office/pages/home_page.dart';
import 'package:rk_office/pages/irrigation_page.dart';
import 'package:rk_office/pages/shutter_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        Routes.homePage : (_) => const HomePage(),
      },
      initialRoute: Routes.homePage,
      onGenerateRoute: Routes.routesWithAddress,
    );
  }
}
