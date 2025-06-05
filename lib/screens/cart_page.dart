import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> removeFromCart(String docId) async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cart')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from Cart')),
    );
  }

  Future<void> updateQuantity(String docId, int quantity, Map<String, dynamic> data) async {
    if (user == null) return;
    if (quantity < 1) return; // Minimum quantity = 1
    data['quantity'] = quantity;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cart')
        .doc(docId)
        .set(data);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final quantity = (data['quantity'] ?? 1) as int;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data['image'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Rs ${data['price']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Decrement button
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          if (quantity > 1) {
                                            updateQuantity(doc.id, quantity - 1, data);
                                          }
                                        },
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      // Increment button
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          updateQuantity(doc.id, quantity + 1, data);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => removeFromCart(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Rs ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement your checkout logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout pressed')),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.creditCard),
                      label: const Text('Checkout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
