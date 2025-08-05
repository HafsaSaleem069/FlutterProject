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
          SnackBar(
            content: const Text(
              'Please select a payment method',
              style: TextStyle(fontSize: 13),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
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
              builder:
                  (context) =>
                      ReceiptPage(orderDetails: orderDetailsForReceipt),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Order placed successfully! 🎉',
                style: TextStyle(fontSize: 13),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BankingDetailsPage(
                    orderId: docRef.id,
                    finalTotal: finalTotal,
                  ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Proceeding to payment...',
                style: TextStyle(fontSize: 13),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }
      } catch (e) {
        print("Error placing order: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to place order: $e",
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Checkout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please log in to place an order',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📋 Billing Details'),
            const SizedBox(height: 8),
            _buildBillingForm(),
            const SizedBox(height: 20),
            _buildSectionTitle('🛍️ Order Summary'),
            const SizedBox(height: 8),
            _buildOrderSummaryTable(),
            const SizedBox(height: 20),
            _buildSectionTitle('💳 Payment Method'),
            const SizedBox(height: 8),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 24),
            _buildFinalTotalAndCheckoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBillingForm() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(
                _nameController,
                'Full Name',
                Icons.person_outline,
              ),
              _buildTextFormField(
                _addressController,
                'Delivery Address',
                Icons.location_on_outlined,
              ),
              _buildTextFormField(
                _phoneController,
                'Phone Number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildTextFormField(
                _emailController,
                'Email',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isLast: true,
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
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummaryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cartItems.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(0.2),
                  ),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            data['image'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary.withOpacity(0.6),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'N/A',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Rs ${itemPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Qty: $quantity',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${itemTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    'Subtotal:',
                    'Rs ${widget.subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 4),
                  _buildPriceRow(
                    'Delivery Fee:',
                    'Rs ${deliveryFee.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildPaymentOption(
              'COD',
              '💵',
              'Cash on Delivery',
              'Pay when your order arrives',
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              'Card',
              '💳',
              'Credit/Debit Card',
              'Pay securely with your card',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String emoji,
    String title,
    String subtitle,
  ) {
    bool isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.inversePrimary,
                  width: 2,
                ),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalTotalAndCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Text(
                  'Rs ${finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.solidCreditCard,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color:
                isTotal
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color:
                isTotal
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}
