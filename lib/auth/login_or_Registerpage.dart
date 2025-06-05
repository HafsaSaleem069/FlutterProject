import 'package:flutter/material.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/screens/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // Track whether user is on login or register view
  bool showLoginPage = true;

  // Toggle between login and register pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages, // pass toggle function to login page
      );
    } else {
      return RegisterPage(
        onTap: togglePages, // pass toggle function to register page
      );
    }
  }
}
