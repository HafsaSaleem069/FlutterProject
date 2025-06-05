import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const RestaurantAdminApp());

class RestaurantAdminApp extends StatelessWidget {
  const RestaurantAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1D2B),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        cardColor: const Color(0xFF2A2D3E),
        primaryColor: Colors.orangeAccent,
      ),
      home: const RestaurantDashboard(),
    );
  }
}
class RestaurantDashboard extends StatelessWidget {
  const RestaurantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminSidebar(),
      appBar: AppBar(
        title: const Text("🍽️ Dataflow Restaurant Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                dashboardCard(
                  context,
                  "Total Orders",
                  "2,802",
                  Icons.receipt_long,
                  Colors.orange,
                ),
                dashboardCard(
                  context,
                  "Total Revenue",
                  "\$334,945",
                  Icons.attach_money,
                  Colors.greenAccent,
                ),
                dashboardCard(
                  context,
                  "Customers",
                  "4,945",
                  Icons.people_alt,
                  Colors.lightBlueAccent,
                ),
                dashboardCard(
                  context,
                  "My Balance",
                  "\$10,000",
                  Icons.account_balance_wallet,
                  Colors.purpleAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Revenue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 200, child: Placeholder()),
                            // Replace with chart widget
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Recent Orders",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 200, child: Placeholder()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Promotional Sales",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 200, child: Placeholder()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "User Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 200, child: Placeholder()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1F1D2B),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                "🍽️ Dataflow",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ...[
              "Home 01",
              "Orders",
              "Menu",
              "Customers",
              "Reservations",
              "Inventory",
              "Finance",
              "Reviews",
              "Staff",
              "Settings",
            ].map(
              (e) => ListTile(
                leading: const Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.orangeAccent,
                ),
                title: Text(e, style: const TextStyle(color: Colors.white70)),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
