// lib/screens/receipt_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/homepage.dart';
import 'mainLayout.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  ReceiptPage({super.key, required this.orderDetails});

  final Color customPrimaryColor = Colors.red.shade900;
  final Color customAccentColor = Colors.deepOrange;
  final Color pageBackgroundColor = Colors.grey[100]!;

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

  Widget _buildReceiptDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPriceRow(
    String label,
    String value, {
    bool isGrandTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 18 : 16,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
              color: isGrandTotal ? Colors.black : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 18 : 16,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              color: isGrandTotal ? customPrimaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String orderId = orderDetails['orderId'] ?? 'N/A';
    final String customerName = orderDetails['customerName'] ?? 'N/A';
    final String deliveryAddress = orderDetails['deliveryAddress'] ?? 'N/A';
    final String phoneNumber = orderDetails['phoneNumber'] ?? 'N/A';
    final String email = orderDetails['email'] ?? 'N/A';
    final String paymentMethod = orderDetails['paymentMethod'] ?? 'N/A';
    final List<dynamic> items = orderDetails['items'] ?? [];
    final double subtotal =
        (orderDetails['subtotal'] as num?)?.toDouble() ?? 0.0;
    final double deliveryFee =
        (orderDetails['deliveryFee'] as num?)?.toDouble() ?? 0.0;
    final double finalTotal =
        (orderDetails['finalTotal'] as num?)?.toDouble() ?? 0.0;
    final Timestamp? timestamp = orderDetails['timestamp'] as Timestamp?;
    final String orderDate =
        timestamp != null
            ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute}'
            : 'N/A';

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Receipt'),
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
            _buildSectionTitle('Order Confirmation'),
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
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade700,
                            size: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Thank You for Your Order!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Your order has been placed successfully.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          _buildReceiptDetailRow('Order ID:', orderId),
                          _buildReceiptDetailRow('Order Date:', orderDate),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 30,
                      thickness: 1.0,
                      color: Colors.grey,
                    ),
                    _buildReceiptDetailRow('Customer Name:', customerName),
                    _buildReceiptDetailRow(
                      'Delivery Address:',
                      deliveryAddress,
                    ),
                    _buildReceiptDetailRow('Phone Number:', phoneNumber),
                    _buildReceiptDetailRow('Email:', email),
                    _buildReceiptDetailRow('Payment Method:', paymentMethod),
                    const SizedBox(height: 20),
                    Text(
                      'Ordered Items:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(0.8),
                        2: FlexColumnWidth(0.5),
                        3: FlexColumnWidth(1.0),
                      },
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Qty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
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
                        ...items.map((item) {
                          final String title = item['title'] ?? 'N/A';
                          final double price =
                              (item['price'] as num?)?.toDouble() ?? 0.0;
                          final int quantity =
                              (item['quantity'] as num?)?.toInt() ?? 0;
                          final double totalItemPrice =
                              (item['total_item_price'] as num?)?.toDouble() ??
                              0.0;

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Rs ${price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Rs ${totalItemPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),

                    if (paymentMethod == 'Card') ...[
                      const SizedBox(height: 20),
                      _buildSectionTitle('Banking Information'),
                      _buildReceiptDetailRow(
                        'Bank Name:',
                        'Habib Bank Limited',
                      ),
                      _buildReceiptDetailRow(
                        'Account Title:',
                        'Coffee Shop Pvt Ltd',
                      ),
                      _buildReceiptDetailRow(
                        'IBAN:',
                        'PK36 HABB 0000 1234 5678 9101',
                      ),
                      _buildReceiptDetailRow(
                        'Transaction Ref:',
                        'Auto Generated',
                      ),
                    ],

                    const Divider(
                      height: 30,
                      thickness: 1.0,
                      color: Colors.grey,
                    ),

                    _buildReceiptPriceRow(
                      'Subtotal:',
                      'Rs ${subtotal.toStringAsFixed(2)}',
                    ),
                    _buildReceiptPriceRow(
                      'Delivery Fee:',
                      'Rs ${deliveryFee.toStringAsFixed(2)}',
                    ),
                    _buildReceiptPriceRow(
                      'Grand Total:',
                      'Rs ${finalTotal.toStringAsFixed(2)}',
                      isGrandTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MainLayout(
                            child: const HomePage(),
                            selectedIndex: 0,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Back to Home',
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
