import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/screens/admin_dashboard.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/screens/product_page.dart';
import 'package:project/screens/register_page.dart';
import '../../screens/login_page.dart';

Map<String, WidgetBuilder> CustomerRoutes = {
  '/': (context) => HomePage() ,// default route
  '/register': (context) => RegisterPage(onTap: () {}),
  '/login': (context) => LoginPage(onTap:() {}),
  '/home': (context) => HomePage(),
};
