import 'package:flutter/material.dart';
import 'package:project/admin/admin_panel.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/screens/register_page.dart';
import '../../screens/login_page.dart';
import '../../screens/mainLayout.dart';

Map<String, WidgetBuilder> CustomerRoutes = {
  '/register': (context) => RegisterPage(onTap: () {}),
  '/login': (context) => LoginPage(onTap: () {}),
  '/home': (context) => MainLayout(child: const HomePage(), selectedIndex: 2),

  '/admin':
      (context) => const AdminPanel(),
};

