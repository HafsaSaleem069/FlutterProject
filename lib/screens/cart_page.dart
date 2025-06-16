import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/screens/checkout.dart';

import 'mainLayout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  // Backend logic for removeFromCart, updateQuantity, calculateTotal remains unchanged
  Future<void> removeFromCart(String docId) async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cart')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Removed from Cart')));
  }

  Future<void> updateQuantity(
    String docId,
    int quantity,
    Map<String, dynamic> data,
  ) async {
    if (user == null) return;
    if (quantity < 1) return;
    final Map<String, dynamic> updatedData = Map.from(data);
    updatedData['quantity'] = quantity;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cart')
        .doc(docId)
        .set(updatedData);
  }

  double calculateTotal(List<QueryDocumentSnapshot> docs) {
    double total = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['price'] as num).toDouble();
      final quantity = (data['quantity'] ?? 1) as int;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your cart.')),
      );
    }

    // Define custom primary color based on the reference image
    final Color customPrimaryColor = Colors.red.shade900; // Deep red/maroon
    final Color customAccentColor = Colors.deepOrange; // For highlights

    return Scaffold(
      // --- BACKGROUND COLOR FOR THE ENTIRE PAGE ---
      backgroundColor: Colors.white,
      // Thoda off-white/light grey background, jaisa image mein hai
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        elevation: 0,
        // AppBar ki shadow hatayi
        backgroundColor: Colors.transparent,
        // AppBar background transparent rakha
        foregroundColor: Colors.black,
        // Title aur icons ka color black
        // Toolbar ke neeche koi border nahi chahiye
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.transparent, // No visible line below appbar
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection('cart')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartDocs = snapshot.data?.docs ?? [];

          if (cartDocs.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final totalPrice = calculateTotal(cartDocs);

          return Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: customPrimaryColor,
                  // Header ka background red.shade900 jaisa
                  // No bottom border, because we want it to blend with the cards
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ), // Thode rounded corners
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 80 + 16), // Image width + spacing
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Menu Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ), // Text color white
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Price',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ), // Text color white
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ), // Text color white
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ), // Text color white
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(width: 48), // For Remove button icon size
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // Horizontal padding for list items
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final quantity = (data['quantity'] ?? 1) as int;
                    final itemPrice = (data['price'] as num).toDouble();
                    final itemTotal = itemPrice * quantity;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12, top: 5),
                      // Added small top margin for spacing from header
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(blue: 0.1),
                            // Decent, subtle shadow
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Menu Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              // Image ke corners thode rounded
                              child: Image.network(
                                data['image'] ??
                                    'https://via.placeholder.com/80',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Menu Name (Expanded)
                            Expanded(
                              flex: 3,
                              child: Text(
                                data['title'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color:
                                      Colors.black87, // Slightly softer black
                                ),
                              ),
                            ),
                            // Price
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Rs ${itemPrice.toStringAsFixed(0)}",
                                // Rs sign with price
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Quantity Controls
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (quantity > 1) {
                                        updateQuantity(
                                          doc.id,
                                          quantity - 1,
                                          data,
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        // Quantity buttons background
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: customPrimaryColor,
                                      ), // Icon color
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      updateQuantity(
                                        doc.id,
                                        quantity + 1,
                                        data,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        // Quantity buttons background
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: customPrimaryColor,
                                      ), // Icon color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Item Total
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Rs ${itemTotal.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      customAccentColor, // Highlight total with accent color
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            // Remove Button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 24,
                              ), // Red color for delete
                              onPressed: () => removeFromCart(doc.id),
                              tooltip: 'Remove item',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Grand Total and Checkout Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      // Consistent shadow
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Rs ${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 30,
                      thickness: 1.5,
                      color: Colors.grey,
                    ),
                    // Divider color
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Rs ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                customPrimaryColor, // Total color using primary
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MainLayout(
                                    child: CheckoutPage(
                                      cartItems: cartDocs,
                                      subtotal: totalPrice,
                                    ),
                                    selectedIndex: 0,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(
                          FontAwesomeIcons.creditCard,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPrimaryColor,
                          // Checkout button ka color primary
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
