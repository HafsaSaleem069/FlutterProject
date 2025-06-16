import 'package:flutter/material.dart';

import 'admin_user.dart';
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1F1D2B), // Consistent dark background
        child: ListView(
          children: [
            const DrawerHeader(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Adjust padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🍽️ Dataflow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Slightly larger font for header
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1), // Separator below header
            ...[
              {"title": "Dashboard", "icon": Icons.dashboard, "route": "/admin_dashboard"},
              {"title": "Orders", "icon": Icons.shopping_cart, "route": "/admin_orders"},
              {"title": "Menu", "icon": Icons.restaurant_menu, "route": "/admin_menu"},
              {"title": "Customers", "icon": Icons.people, "route": "/admin_customers"},
              {"title": "Reservations", "icon": Icons.event, "route": "/admin_reservations"},
              {"title": "Inventory", "icon": Icons.inventory, "route": "/admin_inventory"},
              {"title": "Finance", "icon": Icons.currency_rupee, "route": "/admin_finance"}, // Using rupee icon
              {"title": "Reviews", "icon": Icons.reviews, "route": "/admin_reviews"},
              {"title": "Staff", "icon": Icons.group, "route": "/admin_staff"},
              {"title": "Settings", "icon": Icons.settings, "route": "/admin_settings"},
            ].map(
                  (item) => ListTile(
                leading: Icon(
                  item["icon"] as IconData, // Use specific icon for each item
                  color: Colors.orangeAccent,
                  size: 20, // Adjust icon size
                ),
                title: Text(item["title"] as String, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer first

                  // Navigate based on the route
                  if (item["route"] == "/admin_customers") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerManagementPage(),
                      ),
                    );
                  } else {
                    // Placeholder for other navigations
                    print("Navigating to ${item["title"]} (${item["route"]})");
                    // You would typically use named routes here:
                    // Navigator.pushNamed(context, item["route"] as String);
                    // For example:
                    // if (item["route"] == "/admin_dashboard") {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboardPage()));
                    // } else if (item["route"] == "/admin_orders") {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => AdminOrdersPage()));
                    // }
                    // ...and so on for each page.
                  }
                },
              ),
            ),
            const Divider(color: Colors.white12, height: 1), // Separator
            // You can add a logout button here if needed
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.white70, fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Implement Firebase Logout here
                // FirebaseAuth.instance.signOut();
                // Navigator.pushReplacementNamed(context, '/login');
                print("Logging out...");
              },
            ),
          ],
        ),
      ),
    );
  }
}