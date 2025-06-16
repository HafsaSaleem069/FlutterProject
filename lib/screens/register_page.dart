import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/components/my_textfield.dart';
import 'package:project/screens/login_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  double strength = 0;
  String displayText = 'Enter a password';
  bool isLoading = false;

  // 🔐 Register user logic
  Future<void> registerUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match');
      return;
    }

    if (strength < 0.75) {
      showMessage('Please choose a stronger password');
      return;
    }

    setState(() => isLoading = true);
    try {
      print(
        'Registering user with $email and password length ${password.length}',
      );
      print("Checking Firebase apps: ${Firebase.apps}");

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'email': email, 'createdAt': Timestamp.now()});

      showMessage('Account created successfully');
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}, ${e.message}");
      print("Full Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onTap:() {}),
      ),
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void checkPassword(String value) {
    double tempStrength = 0;
    if (value.length >= 6) tempStrength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) tempStrength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) tempStrength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(value)) tempStrength += 0.25;

    setState(() {
      strength = tempStrength;
      if (strength < 0.25) {
        displayText = "Too weak";
      } else if (strength < 0.5) {
        displayText = "Weak";
      } else if (strength < 0.75) {
        displayText = "Medium";
      } else {
        displayText = "Strong 💪";
      }
    });
  }

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
                Icons.person_add_alt_1,
                size: 100,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),

              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                onChanged: checkPassword,
              ),

              // 🧠 Password strength meter
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: strength,
                backgroundColor: Colors.grey[300],
                color:
                    strength < 0.5
                        ? Colors.red
                        : strength < 0.75
                        ? Colors.orange
                        : Colors.green,
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(displayText),

              const SizedBox(height: 10),
              MyTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true,
              ),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("Register"),
                  ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Already have an account?",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text("Login"),
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
