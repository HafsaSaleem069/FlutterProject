import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/backend/routes/cutomer_route.dart';
import 'package:project/database/insertion.dart';
import 'package:project/firebase_options.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(
    'Firebase initialized for: ${DefaultFirebaseOptions.currentPlatform.projectId}',
  );

  // await uploadMealsToFirestore();
  // await addDetailFieldToAllProducts();
  runApp(
    // You wrapped your app with a ChangeNotifierProvider (from the provider package).
    // It provides your ThemeProvider class to the whole app, so you can use it in any widget.
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/login',
      routes: CustomerRoutes,
    );
  }
}



















/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/backend/routes/cutomer_route.dart';
import 'package:project/database/insertion.dart';
import 'package:project/firebase_options.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(
    'Firebase initialized for: ${DefaultFirebaseOptions.currentPlatform.projectId}',
  );

  // await uploadMealsToFirestore();
  // await addDetailFieldToAllProducts();
  runApp(
    // You wrapped your app with a ChangeNotifierProvider (from the provider package).
    // It provides your ThemeProvider class to the whole app, so you can use it in any widget.
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/login',
      routes: CustomerRoutes,
    );
  }
}*/
