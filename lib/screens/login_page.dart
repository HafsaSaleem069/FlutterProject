import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/components/my_button.dart';
import 'package:project/components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              prefixIcon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _showCustomToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.1),
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ready for delicious food? 🍕",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 50),

                      // Email Field
                      _buildEnhancedTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildEnhancedTextField(
                        controller: passwordController,
                        hintText: "Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;

                                    if (email.isEmpty || password.isEmpty) {
                                      _showCustomToast(
                                        "Please fill in all fields",
                                        isError: true,
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    try {
                                      final UserCredential userCredential =
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                email: email,
                                                password: password,
                                              );

                                      print(
                                        "✅ Logged in as: ${userCredential.user!.email}",
                                      );

                                      // Show welcome notification
                                      _showCustomToast(
                                        "Welcome to Creative Delights! 🎉",
                                      );

                                      // Navigate to home page
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      print(
                                        "❌ FirebaseAuthException: ${e.code}",
                                      );
                                      String message = '';
                                      switch (e.code) {
                                        case 'user-not-found':
                                          message =
                                              'No user found for that email.';
                                          break;
                                        case 'wrong-password':
                                          message = 'Incorrect password.';
                                          break;
                                        case 'invalid-email':
                                          message = 'Invalid email address.';
                                          break;
                                        default:
                                          message =
                                              'Something went wrong. Please try again.';
                                      }
                                      _showCustomToast(message, isError: true);
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          // Add forgot password functionality
                          _showCustomToast(
                            "Forgot password feature coming soon!",
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Register Link
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not a member? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Register now",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:project/components/my_button.dart';
// import 'package:project/components/my_textfield.dart';
//
// class LoginPage extends StatefulWidget {
//   final void Function()? onTap;
//
//   LoginPage({super.key, required this.onTap});
//
//   @override
//   State<LoginPage> createState() => _LoginPage();
// }
//
// class _LoginPage extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   bool _isPasswordVisible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.lock_open_rounded,
//                 size: 100,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 25),
//               Text(
//                 "Welcome back, foodie!",
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 25),
//               MyTextField(
//                 controller: emailController,
//                 hintText: "Email",
//                 obscureText: false,
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: passwordController,
//                 obscureText: !_isPasswordVisible,
//                 decoration: InputDecoration(
//                   hintText: "Password",
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               MyButton(
//                 text: "Sign In",
//                 onTap: () async {
//                   final email = emailController.text.trim();
//                   final password = passwordController.text;
//
//                   if (email.isEmpty || password.isEmpty) {
//                     Fluttertoast.showToast(msg: "Please fill in all fields");
//                     return;
//                   }
//
//                   try {
//                     final UserCredential userCredential = await FirebaseAuth
//                         .instance
//                         .signInWithEmailAndPassword(
//                       email: email,
//                       password: password,
//                     );
//
//                     print("✅ Logged in as: ${userCredential.user!.email}");
//
//                     // Show welcome notification
//                     Fluttertoast.showToast(
//                       msg: "Welcome to Creative Delights!",
//                       toastLength: Toast.LENGTH_LONG,
//                       gravity: ToastGravity.CENTER,
//                       timeInSecForIosWeb: 3,
//                       backgroundColor: Colors.green,
//                       textColor: Colors.white,
//                       fontSize: 16.0,
//                     );
//
//                     // Navigate to home page
//                     Navigator.pushReplacementNamed(context, '/home');
//                   } on FirebaseAuthException catch (e) {
//                     print("❌ FirebaseAuthException: ${e.code}");
//
//                     String message = '';
//                     switch (e.code) {
//                       case 'user-not-found':
//                         message = 'No user found for that email.';
//                         break;
//                       case 'wrong-password':
//                         message = 'Incorrect password.';
//                         break;
//                       case 'invalid-email':
//                         message = 'Invalid email address.';
//                         break;
//                       default:
//                         message = 'Something went wrong. Please try again.';
//                     }
//
//                     Fluttertoast.showToast(msg: message);
//                   }
//                 },
//               ),
//               const SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Not a member?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/register');
//                     },
//                     child: Text(
//                       "Register now",
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
