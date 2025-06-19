import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/reciept_screen.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedStatus = 'All';

  Future<void> toggleStatus(String orderId, String currentStatus, String userId) async {
    String newStatus = currentStatus == 'Pending' ? 'Delivered' : 'Pending';

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': newStatus,
    });

    if (newStatus == 'Delivered') {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final token = userDoc['deviceToken'];

      if (token != null && token.toString().isNotEmpty) {
        print("Send push notification to $token");
      }
    }
  }

  Stream<QuerySnapshot> getOrdersStream() {
    final collection = FirebaseFirestore.instance.collection('orders');
    if (selectedStatus == 'All') {
      return collection.orderBy('timestamp', descending: true).snapshots();
    } else {
      return collection
          .where('orderStatus', isEqualTo: selectedStatus)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  Color getStatusColor(BuildContext context, String status) {
    return status == 'Delivered'
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Order Panel'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Dropdown Filter
            Row(
              children: [
                Text("Filter:",
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      style: theme.textTheme.bodyMedium,
                      items: ['All', 'Pending', 'Delivered'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Table
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getOrdersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final orders = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(colorScheme.surface.withOpacity(0.1)),
                      columnSpacing: 20,
                      dataRowMinHeight: 50,
                      dataRowMaxHeight: 65,
                      columns: const [
                        DataColumn(label: Text('Order ID')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Method')),
                        DataColumn(label: Text('Total')),
                      ],
                      rows: orders.map((order) {
                        final data = order.data() as Map<String, dynamic>;
                        final status = data['orderStatus'] ?? 'Pending';
                        final payment = data['paymentMethod'] ?? 'N/A';
                        final total = (data['finalTotal'] as num?)?.toStringAsFixed(2) ?? '0.00';
                        final userId = data['userId'] ?? '';

                        return DataRow(
                          cells: [
                            DataCell(
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptPage(orderDetails: data),
                                    ),
                                  );
                                },
                                child: Text(
                                  order.id.substring(0, 6),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.inversePrimary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              InkWell(
                                onTap: () => toggleStatus(order.id, status, userId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(context, status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: getStatusColor(context, status)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: getStatusColor(context, status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(payment, style: const TextStyle(fontSize: 12))),
                            DataCell(Text("Rs. $total", style: const TextStyle(fontSize: 12))),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
