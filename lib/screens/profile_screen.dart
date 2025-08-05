// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project/screens/reciept_screen.dart';
import 'checkout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Enhanced color scheme
  final Color customPrimaryColor = const Color(0xFFB71C1C);
  final Color customAccentColor = const Color(0xFFFF5722);
  final Color pageBackgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color subtextColor = const Color(0xFF6B7280);
  final Color textColor = const Color(0xFF1F2937);

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
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_off_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Please log in to view your profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [customPrimaryColor, customAccentColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: customPrimaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print("Navigate to login page");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header
              _buildHeader(),

              // User info section
              _buildUserInfoSection(),

              // Orders section
              _buildOrdersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: customPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: customPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  customPrimaryColor.withOpacity(0.1),
                  customAccentColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: customPrimaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child:
                currentUser?.photoURL != null
                    ? ClipOval(
                      child: Image.network(
                        currentUser!.photoURL!,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Icon(
                      Icons.person_outline,
                      size: 36,
                      color: customPrimaryColor,
                    ),
          ),
          const SizedBox(height: 16),
          Text(
            firestoreName ?? 'Loading...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 12,
              color: subtextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Orders',
                  '12',
                  Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Favorites', '8', Icons.favorite_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: pageBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: customPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 16, color: customPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: subtextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  color: customPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildOrderHistoryList(),
      ],
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
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: customPrimaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 12, color: subtextColor),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 24,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Place your first order to see it here',
                  style: TextStyle(fontSize: 11, color: subtextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var orderDoc = snapshot.data!.docs[index];
            var orderData = orderDoc.data() as Map<String, dynamic>;

            String orderId = orderDoc.id;
            Timestamp? timestamp = orderData['timestamp'] as Timestamp?;
            String orderDate =
                timestamp != null
                    ? DateFormat('MMM d, hh:mm a').format(timestamp.toDate())
                    : 'N/A';
            double finalTotal =
                (orderData['finalTotal'] as num?)?.toDouble() ?? 0.0;
            String orderStatus = orderData['orderStatus'] ?? 'Unknown';
            List<dynamic> items = orderData['items'] ?? [];
            String restaurantName =
                orderData['restaurantName'] ?? 'Your Restaurant';

            String itemsSummary =
                items.isNotEmpty
                    ? items.take(2).map((item) => item['title']).join(', ')
                    : 'No items';
            if (items.length > 2) {
              itemsSummary += ' +${items.length - 2} more';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReceiptPage(orderDetails: orderData),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: customPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.restaurant_outlined,
                              size: 20,
                              color: customPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  orderDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                orderStatus,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              orderStatus,
                              style: TextStyle(
                                color: _getStatusColor(orderStatus),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        itemsSummary,
                        style: TextStyle(fontSize: 12, color: subtextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs ${finalTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: customAccentColor,
                            ),
                          ),
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _handleReorder(orderData),
                              icon: const Icon(
                                Icons.refresh,
                                size: 14,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Reorder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF11A00A);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Processing':
        return const Color(0xFF3B82F6);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      case 'Payment Confirmed':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _handleReorder(Map<String, dynamic> previousOrderData) {
    List<QueryDocumentSnapshot> reorderCartItems = [];

    for (var item in previousOrderData['items']) {
      reorderCartItems.add(
        QueryDocumentSnapshotMock(
          id: item['productId'] ?? UniqueKey().toString(),
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
      SnackBar(
        content: const Text(
          'Items added to cart for reorder!',
          style: TextStyle(fontSize: 12),
        ),
        backgroundColor: customPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Mock class remains the same
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

  @override
  DocumentReference<Object?> get reference => throw UnimplementedError();

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic get(Object field) {
    if (_data.containsKey(field)) {
      return _data[field];
    }
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
    throw UnimplementedError();
  }
}
