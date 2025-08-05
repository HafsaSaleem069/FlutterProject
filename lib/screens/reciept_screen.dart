// lib/screens/receipt_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/homepage.dart';
import 'mainLayout.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  ReceiptPage({super.key, required this.orderDetails});

  final Color customPrimaryColor = const Color(0xFF8B0000);
  final Color customAccentColor = const Color(0xFFFF5722);
  final Color pageBackgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color successColor = const Color(0xFF4CAF50);

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: customPrimaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: customPrimaryColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: isGrandTotal
          ? BoxDecoration(
        color: customPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: customPrimaryColor.withOpacity(0.2)),
      )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 14 : 12,
              fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w500,
              color: isGrandTotal ? customPrimaryColor : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 14 : 12,
              fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w600,
              color: isGrandTotal ? customPrimaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
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
    final String orderDate = timestamp != null
        ? '${timestamp.toDate().day.toString().padLeft(2, '0')}/${timestamp.toDate().month.toString().padLeft(2, '0')}/${timestamp.toDate().year} ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : 'N/A';

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Order Receipt',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: customPrimaryColor,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header Card
            _buildGradientCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: successColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Order Placed Successfully!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: successColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thank you for choosing us',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: customPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: customPrimaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order ID',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                orderId,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: customPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date & Time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                orderDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Details Card
            _buildSectionTitle('Customer Details'),
            _buildGradientCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildReceiptDetailRow('Name:', customerName),
                    _buildReceiptDetailRow('Address:', deliveryAddress),
                    _buildReceiptDetailRow('Phone:', phoneNumber),
                    _buildReceiptDetailRow('Email:', email),
                    _buildReceiptDetailRow('Payment:', paymentMethod),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Card
            _buildSectionTitle('Order Items'),
            _buildGradientCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.0),
                          1: FlexColumnWidth(1.0),
                          2: FlexColumnWidth(0.8),
                          3: FlexColumnWidth(1.2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: customPrimaryColor.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Item',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: customPrimaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: customPrimaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Qty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: customPrimaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: customPrimaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          ...items.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final dynamic item = entry.value;
                            final String title = item['title'] ?? 'N/A';
                            final double price =
                                (item['price'] as num?)?.toDouble() ?? 0.0;
                            final int quantity =
                                (item['quantity'] as num?)?.toInt() ?? 0;
                            final double totalItemPrice =
                                (item['total_item_price'] as num?)?.toDouble() ??
                                    0.0;

                            return TableRow(
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[25],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rs ${price.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customAccentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: customAccentColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rs ${totalItemPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Banking Information (if Card payment)
            if (paymentMethod == 'Card') ...[
              _buildSectionTitle('Banking Information'),
              _buildGradientCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildReceiptDetailRow('Bank:', 'Habib Bank Limited'),
                            _buildReceiptDetailRow('Account:', 'Coffee Shop Pvt Ltd'),
                            _buildReceiptDetailRow('IBAN:', 'PK36 HABB 0000 1234 5678 9101'),
                            _buildReceiptDetailRow('Ref:', 'Auto Generated'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Price Breakdown Card
            _buildSectionTitle('Price Breakdown'),
            _buildGradientCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildReceiptPriceRow(
                      'Subtotal:',
                      'Rs ${subtotal.toStringAsFixed(2)}',
                    ),
                    _buildReceiptPriceRow(
                      'Delivery Fee:',
                      'Rs ${deliveryFee.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 16, thickness: 1),
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

            // Back to Home Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [customPrimaryColor, customAccentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainLayout(
                        child: const HomePage(),
                        selectedIndex: 0,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
// // lib/screens/receipt_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:project/screens/homepage.dart';
// import 'mainLayout.dart';
//
// class ReceiptPage extends StatelessWidget {
//   final Map<String, dynamic> orderDetails;
//
//   ReceiptPage({super.key, required this.orderDetails});
//
//   final Color customPrimaryColor = Colors.red.shade900;
//   final Color customAccentColor = Colors.deepOrange;
//   final Color pageBackgroundColor = Colors.grey[100]!;
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: customPrimaryColor,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReceiptDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReceiptPriceRow(
//     String label,
//     String value, {
//     bool isGrandTotal = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isGrandTotal ? 18 : 16,
//               fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
//               color: isGrandTotal ? Colors.black : Colors.grey,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isGrandTotal ? 18 : 16,
//               fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
//               color: isGrandTotal ? customPrimaryColor : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String orderId = orderDetails['orderId'] ?? 'N/A';
//     final String customerName = orderDetails['customerName'] ?? 'N/A';
//     final String deliveryAddress = orderDetails['deliveryAddress'] ?? 'N/A';
//     final String phoneNumber = orderDetails['phoneNumber'] ?? 'N/A';
//     final String email = orderDetails['email'] ?? 'N/A';
//     final String paymentMethod = orderDetails['paymentMethod'] ?? 'N/A';
//     final List<dynamic> items = orderDetails['items'] ?? [];
//     final double subtotal =
//         (orderDetails['subtotal'] as num?)?.toDouble() ?? 0.0;
//     final double deliveryFee =
//         (orderDetails['deliveryFee'] as num?)?.toDouble() ?? 0.0;
//     final double finalTotal =
//         (orderDetails['finalTotal'] as num?)?.toDouble() ?? 0.0;
//     final Timestamp? timestamp = orderDetails['timestamp'] as Timestamp?;
//     final String orderDate =
//         timestamp != null
//             ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute}'
//             : 'N/A';
//
//     return Scaffold(
//       backgroundColor: pageBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Order Receipt'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle('Order Confirmation'),
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.check_circle_outline,
//                             color: Colors.green.shade700,
//                             size: 80,
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'Thank You for Your Order!',
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green.shade700,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 5),
//                           const Text(
//                             'Your order has been placed successfully.',
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 15),
//                           _buildReceiptDetailRow('Order ID:', orderId),
//                           _buildReceiptDetailRow('Order Date:', orderDate),
//                         ],
//                       ),
//                     ),
//                     const Divider(
//                       height: 30,
//                       thickness: 1.0,
//                       color: Colors.grey,
//                     ),
//                     _buildReceiptDetailRow('Customer Name:', customerName),
//                     _buildReceiptDetailRow(
//                       'Delivery Address:',
//                       deliveryAddress,
//                     ),
//                     _buildReceiptDetailRow('Phone Number:', phoneNumber),
//                     _buildReceiptDetailRow('Email:', email),
//                     _buildReceiptDetailRow('Payment Method:', paymentMethod),
//                     const SizedBox(height: 20),
//                     Text(
//                       'Ordered Items:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: customPrimaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Table(
//                       columnWidths: const {
//                         0: FlexColumnWidth(1.5),
//                         1: FlexColumnWidth(0.8),
//                         2: FlexColumnWidth(0.5),
//                         3: FlexColumnWidth(1.0),
//                       },
//                       border: TableBorder.all(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       children: [
//                         TableRow(
//                           decoration: BoxDecoration(color: Colors.grey[200]),
//                           children: const [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Product',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Price',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Qty',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Total',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                                 textAlign: TextAlign.end,
//                               ),
//                             ),
//                           ],
//                         ),
//                         ...items.map((item) {
//                           final String title = item['title'] ?? 'N/A';
//                           final double price =
//                               (item['price'] as num?)?.toDouble() ?? 0.0;
//                           final int quantity =
//                               (item['quantity'] as num?)?.toInt() ?? 0;
//                           final double totalItemPrice =
//                               (item['total_item_price'] as num?)?.toDouble() ??
//                               0.0;
//
//                           return TableRow(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   title,
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'Rs ${price.toStringAsFixed(0)}',
//                                   style: const TextStyle(fontSize: 13),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   '$quantity',
//                                   style: const TextStyle(fontSize: 13),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'Rs ${totalItemPrice.toStringAsFixed(0)}',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.end,
//                                 ),
//                               ),
//                             ],
//                           );
//                         }).toList(),
//                       ],
//                     ),
//
//                     if (paymentMethod == 'Card') ...[
//                       const SizedBox(height: 20),
//                       _buildSectionTitle('Banking Information'),
//                       _buildReceiptDetailRow(
//                         'Bank Name:',
//                         'Habib Bank Limited',
//                       ),
//                       _buildReceiptDetailRow(
//                         'Account Title:',
//                         'Coffee Shop Pvt Ltd',
//                       ),
//                       _buildReceiptDetailRow(
//                         'IBAN:',
//                         'PK36 HABB 0000 1234 5678 9101',
//                       ),
//                       _buildReceiptDetailRow(
//                         'Transaction Ref:',
//                         'Auto Generated',
//                       ),
//                     ],
//
//                     const Divider(
//                       height: 30,
//                       thickness: 1.0,
//                       color: Colors.grey,
//                     ),
//
//                     _buildReceiptPriceRow(
//                       'Subtotal:',
//                       'Rs ${subtotal.toStringAsFixed(2)}',
//                     ),
//                     _buildReceiptPriceRow(
//                       'Delivery Fee:',
//                       'Rs ${deliveryFee.toStringAsFixed(2)}',
//                     ),
//                     _buildReceiptPriceRow(
//                       'Grand Total:',
//                       'Rs ${finalTotal.toStringAsFixed(2)}',
//                       isGrandTotal: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => MainLayout(
//                             child: const HomePage(),
//                             selectedIndex: 0,
//                           ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: customPrimaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   elevation: 8,
//                 ),
//                 child: const Text(
//                   'Back to Home',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
