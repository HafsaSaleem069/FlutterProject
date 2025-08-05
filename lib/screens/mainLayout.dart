import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/admin/admin_panel.dart';
import 'package:project/screens/product_screen.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/reservation.dart';
import 'package:project/screens/wishlist_screen.dart';
import 'bottom_bar.dart';
import 'cart_page.dart';
import 'homepage.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  MainLayout({super.key, required this.child, required this.selectedIndex});

  final List<Widget> _pages = [
    const HomePage(),
    const WishlistPage(),
    const CartPage(),
    ProfilePage(), // replace with actual profile screen
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      // drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        title: const Text(
          "Creative Delights",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('notifications')
                      .where('seen', isEqualTo: false)
                      .snapshots(),
              builder: (context, snapshot) {
                int unseenCount = snapshot.data?.docs.length ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      // Admin Icon
                      IconButton(
                        icon: const Icon(
                          Icons.app_registration_rounded,
                          size: 28,
                          color: Colors.black,
                        ),
                        tooltip: 'Admin Panel',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>  ReservationPage(),
                            ),
                          );
                        },
                      ),

                      // Notification Icon with Badge
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex),
    );
  }
}

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.inversePrimary,
//             ),
//             child: Align(
//               alignment: Alignment.bottomLeft,
//               child: Text(
//                 'Hello, Foodie!',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.history, color: Colors.black87),
//             title: const Text('Order History'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.location_pin, color: Colors.black87),
//             title: const Text('Saved Addresses'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.notifications_none,
//               color: Colors.black87,
//             ),
//             title: const Text('Notifications'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.payment_outlined, color: Colors.black87),
//             title: const Text('Payment Methods'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined, color: Colors.black87),
//             title: const Text('App Settings'),
//             onTap: () {},
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.redAccent),
//             title: const Text('Logout'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
