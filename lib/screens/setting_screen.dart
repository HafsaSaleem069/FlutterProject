// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// Your theme files
import '../themes/theme_provider.dart';
import '../themes/lightmode.dart'; // Import your lightMode
import '../themes/darkmode.dart';  // Import your darkMode


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Custom Colors (consistent with your app's theme)
  final Color customPrimaryColor = Colors.red.shade900;

  // Notification Toggles (Example states)
  bool _orderUpdatesEnabled = true;
  bool _promotionsEnabled = true;
  bool _reviewsEnabled = true;
  bool _appNewsEnabled = true;
  bool _specialOffersEnabled = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // --- Helper Widgets for UI Consistency ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0), // More padding top
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: customPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 4, // Soft shadow
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      color: Theme.of(context).cardColor, // Use theme's card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  // --- Account Settings Actions ---
  Future<void> _updateEmail() async {
    if (currentUser == null) return;

    try {
      await currentUser!.verifyBeforeUpdateEmail(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent to ${_emailController.text.trim()}. Please check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update email: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (currentUser == null) return;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: _currentPasswordController.text.trim(),
      );
      await currentUser!.reauthenticateWithCredential(credential);

      await currentUser!.updatePassword(_newPasswordController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (currentUser == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Optional: Delete user data from Firestore first if stored under userId
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).delete();
        await currentUser!.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
        // Navigate to login/splash screen
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login'); // Adjust your route
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.message}. Please re-authenticate if prompted.')),
        );
        if (e.code == 'requires-recent-login') {
          print('User needs to re-authenticate before account deletion.');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      // Navigate to login/splash screen
      if (!mounted) return;
      // Replace with your actual initial route or login page route name
      Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  // --- Legal & About Actions ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  // --- Feedback/Support Actions ---
  void _sendFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@bookitup.com', // Replace with your support email
      queryParameters: {
        'subject': 'Feedback for BookItUp App - v1.0.0', // dynamic app version
        'body': 'Dear Support Team,\n\n[Your feedback here]\n\n---'
      },
    );
    if (!await launchUrl(emailLaunchUri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app. Please send feedback to support@bookitup.com')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get ThemeProvider instance
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // I. Account Settings
            _buildSectionTitle('Account Settings'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blueGrey),
                    title: const Text('Update Email Address'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Update Email'),
                            content: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'New Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _updateEmail();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: customPrimaryColor),
                                child: const Text('Update', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.orange),
                    title: const Text('Password Management'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Change Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _currentPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Current Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'New Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _changePassword();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: customPrimaryColor),
                                child: const Text('Change', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.blue), // Logout icon
                    title: const Text('Log Out'),
                    onTap: _signOut, // Call the new sign-out function
                  ),
                  const Divider(), // Add a divider if you want it visually separated
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account'),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),

            // II. Notification Settings
            _buildSectionTitle('Notification Settings'),
            _buildCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('All Push Notifications'),
                    secondary: const Icon(Icons.notifications_active, color: Colors.green),
                    value: _orderUpdatesEnabled && _promotionsEnabled && _reviewsEnabled && _appNewsEnabled && _specialOffersEnabled, // Combine toggles
                    onChanged: (bool value) {
                      setState(() {
                        _orderUpdatesEnabled = value;
                        _promotionsEnabled = value;
                        _reviewsEnabled = value;
                        _appNewsEnabled = value;
                        _specialOffersEnabled = value;
                      });
                      // Save preference to Firestore/SharedPreferences
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Order Updates'),
                    secondary: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                    value: _orderUpdatesEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _orderUpdatesEnabled = value;
                      });
                      // Save preference
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Promotions'),
                    secondary: const Icon(Icons.local_offer, color: Colors.pink),
                    value: _promotionsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _promotionsEnabled = value;
                      });
                      // Save preference
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Reviews & Ratings'),
                    secondary: const Icon(Icons.star, color: Colors.amber),
                    value: _reviewsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _reviewsEnabled = value;
                      });
                      // Save preference
                    },
                  ),
                  SwitchListTile(
                    title: const Text('App News'),
                    secondary: const Icon(Icons.newspaper, color: Colors.lightBlue),
                    value: _appNewsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _appNewsEnabled = value;
                      });
                      // Save preference
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Special Offers'),
                    secondary: const Icon(Icons.wallet_giftcard, color: Colors.teal),
                    value: _specialOffersEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _specialOffersEnabled = value;
                      });
                      // Save preference
                    },
                  ),
                ],
              ),
            ),

            // III. Theme
            _buildSectionTitle('Theme'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.brightness_4, color: Theme.of(context).brightness == Brightness.light ? Colors.amber : Colors.grey),
                    title: const Text('Light Mode'),
                    trailing: Radio<ThemeData>(
                      value: lightMode,
                      groupValue: themeProvider.themeData,
                      onChanged: (ThemeData? value) {
                        if (value != null && themeProvider.themeData != lightMode) {
                          themeProvider.toggleTheme();
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.brightness_2, color: Theme.of(context).brightness == Brightness.dark ? Colors.deepPurple : Colors.grey),
                    title: const Text('Dark Mode'),
                    trailing: Radio<ThemeData>(
                      value: darkMode,
                      groupValue: themeProvider.themeData,
                      onChanged: (ThemeData? value) {
                        if (value != null && themeProvider.themeData != darkMode) {
                          themeProvider.toggleTheme();
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.blueGrey),
                    title: const Text('System Default (Requires ThemeProvider modification)'),
                    trailing: Radio<ThemeData>(
                      value: ThemeData(), // Placeholder
                      groupValue: themeProvider.themeData,
                      onChanged: null, // Disabled
                    ),
                  ),
                ],
              ),
            ),

            // IV. Legal & About
            _buildSectionTitle('Legal & About'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.grey),
                    title: const Text('Terms of Service/Use'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchURL('https://www.bookitup.com/terms'), // Replace with actual URL
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.grey),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchURL('https://www.bookitup.com/privacy'), // Replace with actual URL
                  ),
                  ListTile(
                    leading: const Icon(Icons.article, color: Colors.grey),
                    title: const Text('Licenses/Open Source Attributions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'BookItUp',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 BookItUp. All rights reserved.',
                        children: [
                          const Text('This app uses various open-source libraries. For full details, please refer to the pubspec.yaml file and individual library licenses.'),
                        ],
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.grey),
                    title: const Text('About Us'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'BookItUp',
                        applicationVersion: '1.0.0', // Hardcoded for example
                        applicationLegalese: 'Your go-to app for ordering delicious meals and more.',
                        children: [
                          Text('App Version: 1.0.0', style: Theme.of(context).textTheme.bodySmall),
                          Text('Website: www.bookitup.com', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // V. Feedback & Support
            _buildSectionTitle('Feedback & Support'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.feedback, color: Colors.blue),
                    title: const Text('Send Feedback'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _sendFeedback,
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.cyan),
                    title: const Text('Help Center / FAQs'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchURL('https://www.bookitup.com/help'), // Replace with actual URL
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.purple),
                    title: const Text('Contact Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchURL('tel:+1234567890'), // Replace with actual support number
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Extra space at the bottom
          ],
        ),
      ),
    );
  }
}