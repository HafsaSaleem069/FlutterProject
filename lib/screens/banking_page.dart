import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/reciept_screen.dart';

class BankingDetailsPage extends StatefulWidget {
  final String orderId;
  final double finalTotal;

  const BankingDetailsPage({
    Key? key,
    required this.orderId,
    required this.finalTotal,
  }) : super(key: key);

  @override
  State<BankingDetailsPage> createState() => _BankingDetailsPageState();
}

class _BankingDetailsPageState extends State<BankingDetailsPage> {
  final String accountNumber = "1234567890123456";
  final String bankName = "Example Bank Ltd.";
  final String accountTitle = "BookItUp Payments";
  final String iban = "PKXXEBANXXXXXXXXXXXXXX";
  final String swiftCode = "EXAMPLBANK";

  final Color customPrimaryColor = Colors.red.shade900;
  final Color pageBackgroundColor = Colors.white;

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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 18,
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
      try {
        final docRef = FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId);

        // 🔄 Step 1: Update payment status & details
        await docRef.update({
          'paymentDetails': {
            'transactionId': _transactionIdController.text.trim(),
            'senderAccountName': _senderAccountNameController.text.trim(),
            'senderBankName': _senderBankNameController.text.trim(),
            'confirmationTimestamp': FieldValue.serverTimestamp(),
          },
          'orderStatus': 'Payment Confirmed',
        });

        // 📦 Step 2: Fetch full updated document
        final snapshot = await docRef.get();
        final fullData = snapshot.data();

        if (fullData != null) {
          // 🧩 Step 3: Inject orderId into the data map
          fullData['orderId'] = snapshot.id;

          // 🚀 Step 4: Navigate to ReceiptPage with complete data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptPage(orderDetails: fullData),
            ),
          );
        } else {
          throw Exception('Failed to load order data after update');
        }
      } catch (e) {
        print("Error confirming payment: $e");
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
        title: const Text(
          'Banking Details for Payment',
          style: TextStyle(fontSize: 15),
        ),
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please transfer the amount to the following bank details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Bank Name:', bankName, context),
                    _buildDetailRow('Account Title:', accountTitle, context),
                    _buildDetailRow('Account Number:', accountNumber, context),
                    _buildDetailRow('IBAN:', iban, context),
                    _buildDetailRow('SWIFT Code:', swiftCode, context),
                    const Divider(
                      height: 24,
                      thickness: 1.0,
                      color: Colors.grey,
                    ),
                    Text(
                      'Total Amount to Pay:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Rs ${widget.finalTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: customPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Important: After making the transfer, please fill in the details below to confirm your payment.',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Payment Details (for confirmation):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: customPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _transactionIdController,
                        style: const TextStyle(fontSize: 14),
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
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Transaction ID.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senderAccountNameController,
                        style: const TextStyle(fontSize: 14),
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
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your account name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senderBankNameController,
                        style: const TextStyle(fontSize: 14),
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
                          fillColor: Colors.grey[100],
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Confirm Payment & Get Receipt',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
