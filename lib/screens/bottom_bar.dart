import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/setting_screen.dart';
import 'package:project/screens/wishlist_screen.dart';
import 'cart_page.dart';
import 'homepage.dart';
import 'mainLayout.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => MainLayout(child: const CartPage(), selectedIndex: 0),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    MainLayout(child: const WishlistPage(), selectedIndex: 1),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => MainLayout(child: const HomePage(), selectedIndex: 2),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainLayout(child: ProfilePage(), selectedIndex: 3),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainLayout(child: SettingsPage(), selectedIndex: 4),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox(); // Return empty if not logged in

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onBottomNavTapped(context, index),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.red.shade50,
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      items: [
        BottomNavigationBarItem(
          icon: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('cart')
                    .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.data?.docs.length ?? 0;
              return _buildIconWithBadge(
                context,
                Icons.shopping_cart,
                0,
                selectedIndex,
                count,
              );
            },
          ),
          label: "Cart",
        ),
        BottomNavigationBarItem(
          icon: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('wishlist')
                    .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.data?.docs.length ?? 0;
              return _buildIconWithBadge(
                context,
                Icons.favorite,
                1,
                selectedIndex,
                count,
              );
            },
          ),
          label: "Wishlist",
        ),
        _buildItem(Icons.home_filled, "Food", 2, selectedIndex, context),
        _buildItem(Icons.person, "Profile", 3, selectedIndex, context),
        _buildItem(Icons.settings, "Settings", 4, selectedIndex, context),
      ],
    );
  }

  BottomNavigationBarItem _buildItem(
    IconData icon,
    String label,
    int index,
    int selectedIndex,
    BuildContext context,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration:
            index == selectedIndex
                ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : null,
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: index == selectedIndex ? Colors.white : Colors.black,
        ),
      ),
      label: label,
    );
  }

  Widget _buildIconWithBadge(
    BuildContext context,
    IconData icon,
    int index,
    int selectedIndex,
    int count,
  ) {
    return Stack(
      children: [
        _buildItem(icon, "", index, selectedIndex, context).icon!,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
