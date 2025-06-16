// lib/screens/checkout_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/screens/reciept_screen.dart';
import 'banking_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<QueryDocumentSnapshot>
  cartItems; // CartPage se items yahan aayengi
  final double subtotal;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedPaymentMethod; // Cash on Delivery or Card

  // Colors from previous chat's aesthetic
  final Color customPrimaryColor = Colors.red.shade900;
  final Color customAccentColor = Colors.deepOrange;
  final Color pageBackgroundColor = Colors.white;

  double deliveryFee = 250.0; // Example delivery fee
  double finalTotal = 0.0;

  @override
  void initState() {
    super.initState();
    finalTotal = widget.subtotal + deliveryFee;
    _loadUserDetails(); // Load saved user details if available
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // User details load karein (Agar pehle save kiye hain)
  Future<void> _loadUserDetails() async {
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();
        if (userDoc.exists) {
          _nameController.text = userDoc.data()?['name'] ?? '';
          _addressController.text = userDoc.data()?['address'] ?? '';
          _phoneController.text = userDoc.data()?['phone'] ?? '';
          _emailController.text = userDoc.data()?['email'] ?? user!.email ?? '';
        }
      } catch (e) {
        print("Error loading user details: $e");
      }
    }
  }

  // User details save karein
  Future<void> _saveUserDetails() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
              'name': _nameController.text.trim(),
              'address': _addressController.text.trim(),
              'phone': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
            }, SetOptions(merge: true)); // Existing data ko overwrite na karein
      } catch (e) {
        print("Error saving user details: $e");
      }
    }
  }

  // Order Place karne ka logic
  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Form fields ko save karein

      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method.')),
        );
        return;
      }

      await _saveUserDetails(); // User details save karein order se pehle

      try {
        // Order data tayyar karein
        List<Map<String, dynamic>> items = [];
        for (var itemDoc in widget.cartItems) {
          final data = itemDoc.data() as Map<String, dynamic>;
          items.add({
            'productId': itemDoc.id,
            'title': data['title'],
            'image': data['image'],
            'price': (data['price'] as num).toDouble(),
            'quantity': (data['quantity'] ?? 1) as int,
            'total_item_price':
                ((data['price'] as num).toDouble() * (data['quantity'] ?? 1)),
            // Removed 'as int' cast here, as total_item_price is a double.
          });
        }

        // 1. Order ko Firestore mein add karein
        DocumentReference
        docRef = await FirebaseFirestore.instance.collection('orders').add({
          'userId': user!.uid,
          'customerName': _nameController.text.trim(),
          'deliveryAddress': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'items': items,
          'subtotal': widget.subtotal,
          'deliveryFee': deliveryFee,
          'finalTotal': finalTotal,
          'paymentMethod': _selectedPaymentMethod,
          'orderStatus': 'Pending',
          'timestamp': FieldValue.serverTimestamp(), // Firestore will set this
        });

        // 2. Newly created document ko dobara fetch karein to get the actual server-generated timestamp
        DocumentSnapshot orderSnapshot = await docRef.get();
        Map<String, dynamic> actualOrderData =
            orderSnapshot.data() as Map<String, dynamic>;

        // Cart ko clear karein order place hone ke baad
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var itemDoc in widget.cartItems) {
          batch.delete(
            FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection('cart')
                .doc(itemDoc.id),
          );
        }
        await batch.commit();

        // 3. Order details ko ReceiptPage ko pass karne ke liye ek Map banayein
        Map<String, dynamic> orderDetailsForReceipt = {
          'orderId': docRef.id,
          // Firestore document ID
          'customerName': actualOrderData['customerName'],
          'deliveryAddress': actualOrderData['deliveryAddress'],
          'phoneNumber': actualOrderData['phoneNumber'],
          'email': actualOrderData['email'],
          'paymentMethod': actualOrderData['paymentMethod'],
          'items': actualOrderData['items'],
          'subtotal': actualOrderData['subtotal'],
          'deliveryFee': actualOrderData['deliveryFee'],
          'finalTotal': actualOrderData['finalTotal'],
          'timestamp': actualOrderData['timestamp'],
          // This will now be a proper Timestamp
        };

        // --- CORRECTED LOGIC: Conditional Navigation based on Payment Method ---
        if (_selectedPaymentMethod == 'COD') {
          // If Cash on Delivery, go directly to ReceiptPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ReceiptPage(orderDetails: orderDetailsForReceipt),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully! (Cash on Delivery)'),
            ),
          );
        } else {
          // If Card payment, navigate to BankingDetailsPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      BankingDetailsPage(orderDetails: orderDetailsForReceipt),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceeding to payment gateway...')),
          );
        }
      } catch (e) {
        print("Error placing order: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: customPrimaryColor, // Consistent color
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to place an order.')),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor, // Page ka background color
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Transparent AppBar
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Billing Information Form ---
            _buildSectionTitle('Billing Information'),
            // This requires _buildSectionTitle
            _buildBillingForm(),
            const SizedBox(height: 20),

            // --- Order Summary ---
            _buildSectionTitle('Your Order Summary'),
            // This requires _buildSectionTitle
            _buildOrderSummaryTable(),
            const SizedBox(height: 20),

            // --- Payment Method ---
            _buildSectionTitle('Payment Method'),
            // This requires _buildSectionTitle
            _buildPaymentMethodSelection(),
            const SizedBox(height: 40),

            // --- Final Total and Place Order Button ---
            _buildFinalTotalAndCheckoutButton(),
            const SizedBox(height: 20),
            // Bottom space
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for UI Sections (Re-added/Confirmed in this file) ---

  // Re-added: This method is used by the CheckoutPage's UI sections.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: customPrimaryColor, // Section titles ka color primary
        ),
      ),
    );
  }

  // Confirmed: These helper methods should also be in _CheckoutPageState
  Widget _buildBillingForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(_nameController, 'Full Name', Icons.person),
              _buildTextFormField(
                _addressController,
                'Delivery Address',
                Icons.location_on,
              ),
              _buildTextFormField(
                _phoneController,
                'Phone Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextFormField(
                _emailController,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: customPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50], // Light fill color
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOrderSummaryTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 60), // Image ke liye space
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Product Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            // Cart Items
            ListView.builder(
              shrinkWrap: true,
              // List ko Column ke andar fit karne ke liye
              physics: const NeverScrollableScrollPhysics(),
              // Apna scroll na kare
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final itemDoc = widget.cartItems[index];
                final data = itemDoc.data() as Map<String, dynamic>;
                final quantity = (data['quantity'] ?? 1) as int;
                final itemPrice = (data['price'] as num).toDouble();
                final itemTotal = itemPrice * quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['image'] ?? 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          data['title'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rs ${itemPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rs ${itemTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: customAccentColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 30, thickness: 1.0, color: Colors.grey),
            // Order summary divider
            _buildPriceRow(
              'Subtotal:',
              'Rs ${widget.subtotal.toStringAsFixed(2)}',
            ),
            _buildPriceRow(
              'Delivery Fee:',
              'Rs ${deliveryFee.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'COD',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: customPrimaryColor,
            ),
            RadioListTile<String>(
              title: const Text('Credit/Debit Card'),
              value: 'Card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: customPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalTotalAndCheckoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Total:',
            'Rs ${finalTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _placeOrder,
              icon: const Icon(
                FontAwesomeIcons.solidCreditCard,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Place Order',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: customPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 22 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? customPrimaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
