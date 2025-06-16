import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/screens/reciept_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const BankingDetailsPage({Key? key, required this.orderDetails})
    : super(key: key);

  @override
  State<BankingDetailsPage> createState() => _BankingDetailsPageState();
}

class _BankingDetailsPageState extends State<BankingDetailsPage> {
  // Example banking details (replace with your actual details)
  final String accountNumber = "1234567890123456";
  final String bankName = "Example Bank Ltd.";
  final String accountTitle = "BookItUp Payments";
  final String iban = "PKXXEBANXXXXXXXXXXXXXX";
  final String swiftCode = "EXAMPLBANK";

  final Color customPrimaryColor = Colors.red.shade900;
  final Color pageBackgroundColor = Colors.white;

  // Controllers for user input banking details
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _senderAccountNameController =
      TextEditingController();
  final TextEditingController _senderBankNameController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _transactionIdController.dispose();
    _senderAccountNameController.dispose();
    _senderBankNameController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Retrieve order ID
      final String? orderId = widget.orderDetails['orderId'];

      if (orderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Order ID not found. Cannot confirm payment.'),
          ),
        );
        return;
      }

      try {
        // Update order in Firestore with banking details and status
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
              'paymentDetails': {
                'transactionId': _transactionIdController.text.trim(),
                'senderAccountName': _senderAccountNameController.text.trim(),
                'senderBankName': _senderBankNameController.text.trim(),
                'confirmationTimestamp': FieldValue.serverTimestamp(),
                // When user confirmed payment
              },
              'orderStatus': 'Payment Confirmed', // Or 'Awaiting Verification'
            });

        // Create a copy of orderDetails and add the new paymentDetails
        final Map<String, dynamic> updatedOrderDetails = Map.from(
          widget.orderDetails,
        );
        updatedOrderDetails['paymentDetails'] = {
          'transactionId': _transactionIdController.text.trim(),
          'senderAccountName': _senderAccountNameController.text.trim(),
          'senderBankName': _senderBankNameController.text.trim(),
            };
        updatedOrderDetails['orderStatus'] = 'Payment Confirmed';

        // Navigate to the ReceiptPage, passing the updated order details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptPage(orderDetails: updatedOrderDetails),
          ),
        );
      } catch (e) {
        print("Error confirming payment and updating order: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to confirm payment: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Banking Details for Payment'),
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please transfer the amount to the following bank details:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Bank Name:', bankName, context),
                    _buildDetailRow('Account Title:', accountTitle, context),
                    _buildDetailRow('Account Number:', accountNumber, context),
                    _buildDetailRow('IBAN:', iban, context),
                    _buildDetailRow('SWIFT Code:', swiftCode, context),
                    const Divider(
                      height: 30,
                      thickness: 1.0,
                      color: Colors.grey,
                    ),
                    Text(
                      'Total Amount to Pay:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Rs ${widget.orderDetails['finalTotal']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: customPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Important: After making the transfer, please fill in the details below to confirm your payment.',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // User input for banking details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Payment Details (for confirmation):',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _transactionIdController,
                        decoration: InputDecoration(
                          labelText: 'Transaction ID / Reference No.',
                          hintText:
                              'e.g., Bank transaction ID, ATM receipt no.',
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: customPrimaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Transaction ID.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _senderAccountNameController,
                        decoration: InputDecoration(
                          labelText: 'Your Account Name',
                          hintText: 'e.g., John Doe (as per your bank account)',
                          prefixIcon: Icon(
                            Icons.person,
                            color: customPrimaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your account name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _senderBankNameController,
                        decoration: InputDecoration(
                          labelText: 'Your Bank Name',
                          hintText: 'e.g., ABC Bank',
                          prefixIcon: Icon(
                            Icons.account_balance,
                            color: customPrimaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your bank name.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                // Call the new confirm payment method
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Confirm Payment & Get Receipt',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
