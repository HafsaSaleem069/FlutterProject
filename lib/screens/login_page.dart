import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/components/my_button.dart';
import 'package:project/components/my_textfield.dart';

@override
class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPage();
}

@override
class _LoginPage extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_open_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 25),
              Text(
                "Welcome back, foodie!",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              // MyTextField(
              //   controller: passwordController,
              //   hintText: "Password",
              //   obscureText: true,
              // ),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              MyButton(
                text: "Sign In",
                onTap: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text;

                  if (email.isEmpty || password.isEmpty) {
                    Fluttertoast.showToast(msg: "Please fill in all fields");
                    return;
                  }


                  try {
                    final UserCredential userCredential = await FirebaseAuth
                        .instance
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                    print("✅ Logged in as: ${userCredential.user!.email}");

                    Navigator.pushReplacementNamed(context, '/home');
                  } on FirebaseAuthException catch (e) {
                    print("❌ FirebaseAuthException: ${e.code}");

                    String message = '';
                    switch (e.code) {
                      case 'user-not-found':
                        message = 'No user found for that email.';
                        break;
                      case 'wrong-password':
                        message = 'Incorrect password.';
                        break;
                      case 'invalid-email':
                        message = 'Invalid email address.';
                        break;
                      default:
                        message = 'Something went wrong. Please try again.';
                    }

                    Fluttertoast.showToast(msg: message);
                  }
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
