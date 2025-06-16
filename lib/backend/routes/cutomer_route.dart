import 'package:flutter/material.dart';
import 'package:project/admin/admin_layout.dart';
import 'package:project/main.dart';
import 'package:project/admin/admin_dashboard.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/screens/register_page.dart';
import '../../admin/admin_order.dart';
import '../../admin/admin_user.dart';
import '../../screens/login_page.dart';
import '../../screens/mainLayout.dart';

Map<String, WidgetBuilder> CustomerRoutes = {
  '/register': (context) => RegisterPage(onTap: () {}),
  '/login': (context) => LoginPage(onTap: () {}),
  '/home': (context) => MainLayout(child: const HomePage(), selectedIndex: 2),

  '/admin':
      (context) =>
          const AdminLayout(title: "Dashboard", child: RestaurantDashboard()),
  '/admin_orders':
      (context) => const AdminLayout(
        title: "Orders",
        child: OrdersPage(), // Use your actual OrdersPage here
      ),
  '/admin_menu':
      (context) => const AdminLayout(
        title: "Menu",
        child: MenuPage(), // Use your actual MenuPage here
      ),
  '/admin_customers':
      (context) => const AdminLayout(
        title: "Customer Management",
        child: CustomerManagementPage(), // Your Customer Management Page
      ),
  // Add all other admin routes similarly
  '/admin_reservations':
      (context) => const AdminLayout(
        title: "Reservations",
        child: Center(
          child: Text(
            "Reservations Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
  '/admin_inventory':
      (context) => const AdminLayout(
        title: "Inventory",
        child: Center(
          child: Text(
            "Inventory Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
  '/admin_finance':
      (context) => const AdminLayout(
        title: "Finance",
        child: Center(
          child: Text(
            "Finance Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
  '/admin_reviews':
      (context) => const AdminLayout(
        title: "Reviews",
        child: Center(
          child: Text(
            "Reviews Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
  '/admin_staff':
      (context) => const AdminLayout(
        title: "Staff",
        child: Center(
          child: Text(
            "Staff Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
  '/admin_settings':
      (context) => const AdminLayout(
        title: "Settings",
        child: Center(
          child: Text(
            "Settings Page Content",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
};
