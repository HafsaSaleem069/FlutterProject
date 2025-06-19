// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Date formatting ke liye
import 'package:project/screens/reciept_screen.dart';

import 'checkout.dart'; // ReceiptPage ke liye

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Custom Colors (consistent with your app's theme)
  final Color customPrimaryColor = Colors.red.shade900;
  final Color customAccentColor = Colors.deepOrange;
  final Color pageBackgroundColor =
      Colors.grey[50]!; // Lighter background for settings/profile
  final Color cardColor = Colors.white;
  String? firestoreName;

  @override
  void initState() {
    super.initState();
    _fetchUserNameFromFirestore();
  }

  Future<void> _fetchUserNameFromFirestore() async {
    if (currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          firestoreName = doc.data()!['name'] ?? 'User Name';
        });
      } else {
        setState(() {
          firestoreName = 'User Name';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: pageBackgroundColor,
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'Please log in to view your profile.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Login/Auth page
                  // You might need to replace this with your actual login route
                  print("Navigate to login page");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Transparent AppBar
        foregroundColor: Colors.black, // Dark icons/text on light background
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            _buildUserInfoCard(),
            const SizedBox(height: 20),

            // Order History Section Title
            _buildSectionTitle('My Orders'),
            const SizedBox(height: 10),

            // Order History List (StreamBuilder for real-time updates)
            _buildOrderHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 6,
      // Soft shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Rounded corners
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: customPrimaryColor.withOpacity(0.1),
              backgroundImage:
                  currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
              child:
                  currentUser?.photoURL == null
                      ? Icon(Icons.person, size: 50, color: customPrimaryColor)
                      : null,
            ),
            const SizedBox(height: 15),
            Text(
              firestoreName ?? 'Loading...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 5),
            Text(
              currentUser?.email ?? 'user@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: customPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildOrderHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: customPrimaryColor),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    'No orders yet. Place your first order!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Scroll handled by SingleChildScrollView
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var orderDoc = snapshot.data!.docs[index];
            var orderData = orderDoc.data() as Map<String, dynamic>;

            // Extracting data safely
            String orderId = orderDoc.id; // Document ID is the Order ID
            Timestamp? timestamp = orderData['timestamp'] as Timestamp?;
            String orderDate =
                timestamp != null
                    ? DateFormat(
                      'MMM d, yyyy - hh:mm a',
                    ).format(timestamp.toDate())
                    : 'N/A';
            double finalTotal =
                (orderData['finalTotal'] as num?)?.toDouble() ?? 0.0;
            String orderStatus = orderData['orderStatus'] ?? 'Unknown';
            List<dynamic> items = orderData['items'] ?? [];
            String restaurantName =
                orderData['restaurantName'] ??
                'Your Restaurant'; // Agar restaurant name save kiya hai

            // Display up to 2 items for summary
            String itemsSummary =
                items.isNotEmpty
                    ? items.take(2).map((item) => item['title']).join(', ')
                    : 'No items';
            if (items.length > 2) {
              itemsSummary += ' and ${items.length - 2} more';
            }

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: cardColor,
              child: InkWell(
                // For ripple effect on tap
                onTap: () {
                  // Navigate to ReceiptPage with full order details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReceiptPage(orderDetails: orderData),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row with Order ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Tooltip(
                            message: orderId,
                            child: Text(
                              'Order ID: ${orderId.length > 8 ? orderId.substring(0, 8) + '...' : orderId}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(orderStatus),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              orderStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Restaurant Name
                      Text(
                        restaurantName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),

                      const SizedBox(height: 4),

                      // Date
                      Text(
                        orderDate,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),

                      const Divider(height: 20, thickness: 0.5),

                      // Items Summary & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              itemsSummary,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rs ${finalTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: customAccentColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Reorder Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleReorder(orderData),
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Reorder',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function for status colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      case 'Payment Confirmed': // Add this status for banking
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Reorder Logic - Same as discussed previously
  void _handleReorder(Map<String, dynamic> previousOrderData) {
    List<QueryDocumentSnapshot> reorderCartItems = [];

    // Assuming 'items' in orderData has 'productId', 'title', 'image', 'price', 'quantity'
    // This part might need adjustment based on how your CheckoutPage constructor expects items
    for (var item in previousOrderData['items']) {
      // Create a mock QueryDocumentSnapshot. In a real app,
      // consider refactoring CheckoutPage to accept List<Map<String, dynamic>>
      // directly or fetch product details from your 'products' collection.
      reorderCartItems.add(
        QueryDocumentSnapshotMock(
          id: item['productId'] ?? UniqueKey().toString(),
          // Use actual product ID or a mock
          data: item,
        ),
      );
    }

    double reorderSubtotal = (previousOrderData['items'] as List).fold(
      0.0,
      (sum, item) =>
          sum +
          ((item['price'] as num? ?? 0.0) * (item['quantity'] as num? ?? 0.0)),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutPage(
              cartItems: reorderCartItems,
              subtotal: reorderSubtotal,
            ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items added to cart for reorder!')),
    );
  }
}

// Dummy class to mimic QueryDocumentSnapshot for illustration
// (As discussed, consider refactoring CheckoutPage to avoid this mock)
class QueryDocumentSnapshotMock implements QueryDocumentSnapshot {
  @override
  final String id;
  final Map<String, dynamic> _data;

  QueryDocumentSnapshotMock({
    required this.id,
    required Map<String, dynamic> data,
  }) : _data = data;

  @override
  Map<String, dynamic> data() => _data;

  // Implement other abstract methods as needed, or leave as UnimplementedError
  @override
  DocumentReference<Object?> get reference => throw UnimplementedError();

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  // CORRECTED: Return type changed to dynamic
  dynamic get(Object field) {
    if (_data.containsKey(field)) {
      return _data[field]; // Directly return the value, no need for 'as T' here
    }
    // Return null if the field is not found, as per Firestore's dynamic get behavior
    return null;
  }

  @override
  bool get isEqual => throw UnimplementedError();

  @override
  List<DocumentChange<Object?>> get docChanges => throw UnimplementedError();

  @override
  List<QueryDocumentSnapshot<Object?>> get docs => throw UnimplementedError();

  @override
  int get size => throw UnimplementedError();

  @override
  Timestamp get readTime => throw UnimplementedError();

  @override
  operator [](Object field) {
    // TODO: implement []
    throw UnimplementedError();
  }
}
