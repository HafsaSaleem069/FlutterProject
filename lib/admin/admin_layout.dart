// lib/screens/admin/admin_layout.dart
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_slider.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title; // To dynamically set the AppBar title

  const AdminLayout({Key? key, required this.child, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Use theme's background
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality common to all admin pages, or remove if specific
              print('Search tapped on $title page');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Implement notifications common to all admin pages
              print('Notifications tapped on $title page');
            },
          ),
          // You might want to pass user info or get it via Provider for the avatar
          const CircleAvatar(
            // backgroundImage: AssetImage('assets/images/pizza.png'),
            // Ensure this asset exists
            backgroundColor: Colors.grey, // Fallback background
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AdminSidebar(), // Your modular Admin Sidebar
      body: child, // The content of the specific admin page
    );
  }
}
