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

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  double strength = 0;
  String displayText = 'Enter a password';
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill all fields', isError: true);
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match', isError: true);
      return;
    }

    if (strength < 0.75) {
      showMessage('Please choose a stronger password', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      showMessage('Account created successfully! 🎉', isError: false);

      // Navigate after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
        );
      });
    } on FirebaseAuthException catch (e) {
      showMessage("Error: ${e.message}", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
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
        displayText = "Too weak 😟";
      } else if (strength < 0.5) {
        displayText = "Weak 😐";
      } else if (strength < 0.75) {
        displayText = "Medium 🙂";
      } else {
        displayText = "Strong 💪";
      }
    });
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
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
        onChanged: onChanged,
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
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.purple.shade50,
            ],
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.1),
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join our delicious community!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Form Fields
                      _buildEnhancedTextField(
                        controller: nameController,
                        hintText: "Full Name",
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      _buildEnhancedTextField(
                        controller: phoneController,
                        hintText: "Phone Number",
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),

                      _buildEnhancedTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Password field with strength indicator
                      _buildEnhancedTextField(
                        controller: passwordController,
                        hintText: "Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        onChanged: checkPassword,
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
                      const SizedBox(height: 12),

                      // Password Strength Indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Password Strength",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  displayText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: strength < 0.5
                                        ? Colors.red
                                        : strength < 0.75
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: strength,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  strength < 0.5
                                      ? Colors.red
                                      : strength < 0.75
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildEnhancedTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerUser,
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
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Create Account",
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
                      const SizedBox(height: 24),

                      // Login Link
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
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: Text(
                                "Login",
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
                      const SizedBox(height: 20),
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

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/components/my_textfield.dart';
// import 'package:project/screens/login_page.dart';
//
// class RegisterPage extends StatefulWidget {
//   final void Function()? onTap;
//
//   const RegisterPage({super.key, required this.onTap});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//
//   double strength = 0;
//   String displayText = 'Enter a password';
//   bool isLoading = false;
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//
//   Future<void> registerUser() async {
//     String name = nameController.text.trim();
//     String phone = phoneController.text.trim();
//     String email = emailController.text.trim();
//     String password = passwordController.text;
//     String confirmPassword = confirmPasswordController.text;
//
//     if (name.isEmpty ||
//         phone.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       showMessage('Please fill all fields');
//       return;
//     }
//
//     if (password != confirmPassword) {
//       showMessage('Passwords do not match');
//       return;
//     }
//
//     if (strength < 0.75) {
//       showMessage('Please choose a stronger password');
//       return;
//     }
//
//     setState(() => isLoading = true);
//     try {
//       final userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//             'name': name,
//             'phone': phone,
//             'email': email,
//             'createdAt': Timestamp.now(),
//           });
//
//       showMessage('Account created successfully');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
//       );
//     } on FirebaseAuthException catch (e) {
//       showMessage("Error: ${e.message}");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   void checkPassword(String value) {
//     double tempStrength = 0;
//     if (value.length >= 6) tempStrength += 0.25;
//     if (RegExp(r'[A-Z]').hasMatch(value)) tempStrength += 0.25;
//     if (RegExp(r'[0-9]').hasMatch(value)) tempStrength += 0.25;
//     if (RegExp(r'[!@#\$&*~]').hasMatch(value)) tempStrength += 0.25;
//
//     setState(() {
//       strength = tempStrength;
//       if (strength < 0.25) {
//         displayText = "Too weak";
//       } else if (strength < 0.5) {
//         displayText = "Weak";
//       } else if (strength < 0.75) {
//         displayText = "Medium";
//       } else {
//         displayText = "Strong 💪";
//       }
//     });
//   }
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
//                 Icons.person_add_alt_1,
//                 size: 100,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 25),
//               Text(
//                 "Create Account",
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 25),
//
//               MyTextField(
//                 controller: nameController,
//                 hintText: "Full Name",
//                 obscureText: false,
//               ),
//               const SizedBox(height: 10),
//               MyTextField(
//                 controller: phoneController,
//                 hintText: "Phone Number",
//                 obscureText: false,
//               ),
//               const SizedBox(height: 10),
//               MyTextField(
//                 controller: emailController,
//                 hintText: "Email",
//                 obscureText: false,
//               ),
//               const SizedBox(height: 10),
//
//               // Password field with visibility toggle
//               TextField(
//                 controller: passwordController,
//                 obscureText: !_isPasswordVisible,
//                 onChanged: checkPassword,
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
//
//               const SizedBox(height: 8),
//               LinearProgressIndicator(
//                 value: strength,
//                 backgroundColor: Colors.grey[300],
//                 color:
//                     strength < 0.5
//                         ? Colors.red
//                         : strength < 0.75
//                         ? Colors.orange
//                         : Colors.green,
//                 minHeight: 8,
//               ),
//               const SizedBox(height: 4),
//               Text(displayText),
//
//               const SizedBox(height: 10),
//
//               // Confirm password field with visibility toggle
//               TextField(
//                 controller: confirmPasswordController,
//                 obscureText: !_isConfirmPasswordVisible,
//                 decoration: InputDecoration(
//                   hintText: "Confirm Password",
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isConfirmPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                     onPressed: registerUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       foregroundColor: Theme.of(context).colorScheme.surface,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 50,
//                         vertical: 15,
//                       ),
//                     ),
//                     child: const Text("Register"),
//                   ),
//
//               const SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "Already have an account?",
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pushNamed(context, '/login'),
//                     child: const Text("Login"),
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
