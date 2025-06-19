// lib/screens/checkout_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/screens/reciept_screen.dart';
import 'banking_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedPaymentMethod;

  final Color customPrimaryColor = Colors.red.shade900;
  final Color customAccentColor = Colors.deepOrange;
  final Color pageBackgroundColor = Colors.white;

  double deliveryFee = 250.0;
  double finalTotal = 0.0;

  @override
  void initState() {
    super.initState();
    finalTotal = widget.subtotal + deliveryFee;
    _loadUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
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
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving user details: $e");
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method.')),
        );
        return;
      }

      await _saveUserDetails();

      try {
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
          });
        }

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('orders')
            .add({
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
          'timestamp': FieldValue.serverTimestamp(),
        });

        DocumentSnapshot orderSnapshot = await docRef.get();
        Map<String, dynamic> actualOrderData =
        orderSnapshot.data() as Map<String, dynamic>;

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

        Map<String, dynamic> orderDetailsForReceipt = {
          'orderId': docRef.id,
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
        };

        if (_selectedPaymentMethod == 'COD') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReceiptPage(orderDetails: orderDetailsForReceipt),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully! (Cash on Delivery)'),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BankingDetailsPage(
                orderId: docRef.id,
                finalTotal: finalTotal,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceeding to payment gateway...')),
          );
        }
      } catch (e) {
        print("Error placing order: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to place an order.')),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Billing Information'),
            _buildBillingForm(),
            const SizedBox(height: 20),
            _buildSectionTitle('Your Order Summary'),
            _buildOrderSummaryTable(),
            const SizedBox(height: 20),
            _buildSectionTitle('Payment Method'),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 40),
            _buildFinalTotalAndCheckoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
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
                  _addressController, 'Delivery Address', Icons.location_on),
              _buildTextFormField(_phoneController, 'Phone Number', Icons.phone,
                  keyboardType: TextInputType.phone),
              _buildTextFormField(_emailController, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
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
          fillColor: Colors.grey[50],
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
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 60),
                  const Expanded(flex: 3, child: Text('Product Name')),
                  const Expanded(flex: 1, child: Text('Price', textAlign: TextAlign.center)),
                  const Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center)),
                  const Expanded(flex: 1, child: Text('Total', textAlign: TextAlign.end)),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                          data['image'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: Text(data['title'] ?? 'N/A')),
                      Expanded(flex: 1, child: Text('Rs ${itemPrice.toStringAsFixed(0)}', textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('$quantity', textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('Rs ${itemTotal.toStringAsFixed(0)}', textAlign: TextAlign.end, style: TextStyle(color: customAccentColor, fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 30),
            _buildPriceRow('Subtotal:', 'Rs ${widget.subtotal.toStringAsFixed(2)}'),
            _buildPriceRow('Delivery Fee:', 'Rs ${deliveryFee.toStringAsFixed(2)}'),
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
          _buildPriceRow('Total:', 'Rs ${finalTotal.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _placeOrder,
              icon: const Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
              label: const Text('Place Order', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: customPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
