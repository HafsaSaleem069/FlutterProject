// admin_panel.dart
//Fatima
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/admin/products_page.dart';
import '../themes/theme_provider.dart';
import 'customers_page.dart';
import 'orders_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't pop the route
    }
    return true; // Allow popping the route
  }

  static final List<Widget> _pages = <Widget>[

    const ProductsPage(),
    const CustomersPage(),
    OrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboardTile({
    required String title,
    required IconData icon,
    required int index,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.themeData;
    final isDarkMode = themeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: _onWillPop, // 👈 Handle back press here
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: currentTheme.colorScheme.surface,
          leading:
              Navigator.canPop(context)
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      if (_selectedIndex != 0) {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  )
                  : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
        ),
        body:
            _selectedIndex == 0
                ? ListView(
                  children: [
                    _buildDashboardTile(
                      title: 'Products',
                      icon: Icons.fastfood,
                      index: 1,
                      theme: currentTheme,
                    ),
                    _buildDashboardTile(
                      title: 'Customers',
                      icon: Icons.people,
                      index: 3,
                      theme: currentTheme,
                    ),
                    _buildDashboardTile(
                      title: 'Orders',
                      icon: Icons.shopping_cart,
                      index: 4,
                      theme: currentTheme,
                    ),
                  ],
                )
                : _pages[_selectedIndex],
      ),
    );
  }
}
