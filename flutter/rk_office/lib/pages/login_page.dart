import 'package:flutter/material.dart';
import 'package:rk_office/constants/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/rk_logo.png'),
        title: const Text('RK Associates - Smart Office'),
      ),
      body: Column(
        children: [
          AppBar(
            // automaticallyImplyLeading: false,
            leading: Container(),
            title: const Text('Login'),
            shape: const Border(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter Password',
                contentPadding: EdgeInsets.all(40),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
              ),
              onChanged: (value) {
                if (value == 'rk2022') {
                  Navigator.of(context).pushReplacementNamed(Routes.homePage);
                }
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
