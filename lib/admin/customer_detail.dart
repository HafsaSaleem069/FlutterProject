// lib/screens/admin/customer_detail_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/customer_model.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Customer _currentCustomer; // Mutable copy for status changes
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
  }

  // --- Helper Widgets for UI Consistency ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color, // Use theme text color
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // --- Admin Actions ---
  Future<void> _updateCustomerStatus(String newStatus) async {
    try {
      await _firestore.collection('users').doc(_currentCustomer.uid).update({
        'status': newStatus,
      });
      setState(() {
        _currentCustomer = _currentCustomer.copyWith(status: newStatus);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer status updated to ${newStatus.toUpperCase()}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<void> _showStatusChangeDialog() async {
    String? selectedStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Customer Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Active'),
                value: 'active',
                groupValue: _currentCustomer.status,
                onChanged: (val) => Navigator.of(context).pop(val),
              ),
              RadioListTile<String>(
                title: const Text('Blocked'),
                value: 'blocked',
                groupValue: _currentCustomer.status,
                onChanged: (val) => Navigator.of(context).pop(val),
              ),
              RadioListTile<String>(
                title: const Text('Deactivated'),
                value: 'deactivated',
                groupValue: _currentCustomer.status,
                onChanged: (val) => Navigator.of(context).pop(val),
              ),
            ],
          ),
        );
      },
    );

    if (selectedStatus != null && selectedStatus != _currentCustomer.status) {
      _updateCustomerStatus(selectedStatus);
      // Optional: prompt for reason if status is 'blocked'
      if (selectedStatus == 'blocked') {
        _showReasonForBlockDialog();
      }
    }
  }

  Future<void> _showReasonForBlockDialog() async {
    String? reason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reason for Blocking'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: const InputDecoration(hintText: 'Enter reason for blocking...'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save reason to Firestore (e.g., in a 'blockReasons' subcollection or directly in user doc)
                // For simplicity, we just print here.
                print('Customer ${_currentCustomer.uid} blocked for: $reason');
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmailToCustomer() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _currentCustomer.email,
      queryParameters: {
        'subject': 'Regarding your BookItUp account',
        'body': 'Dear ${_currentCustomer.name},\n\n',
      },
    );
    if (!await launchUrl(emailLaunchUri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app.')),
      );
    }
  }

  // Placeholder for sending push notification (requires Firebase Cloud Messaging setup)
  void _sendPushNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending push notification (Requires FCM setup)')),
    );
    // Implement FCM logic here
  }

  // Placeholder for resetting password (requires Firebase Admin SDK for backend)
  void _resetPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset functionality (Requires Admin SDK on backend)')),
    );
    // Admins usually trigger this via a backend call (Cloud Function, Node.js server)
    // which then uses Firebase Admin SDK to reset the password.
  }

  // Placeholder for editing user info (simple dialog example)
  Future<void> _editUserInfo() async {
    final TextEditingController nameController = TextEditingController(text: _currentCustomer.name);
    final TextEditingController phoneController = TextEditingController(text: _currentCustomer.phone);
    final TextEditingController addressController = TextEditingController(text: _currentCustomer.address);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(_currentCustomer.uid).update({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          // Update more fields as needed
        });
        setState(() {
          _currentCustomer = _currentCustomer.copyWith(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
          );
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User info updated successfully.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user info: $e')),
        );
      }
    }
  }

  // --- Build Widgets ---
  @override
  Widget build(BuildContext context) {
    final Color customPrimaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _currentCustomer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header (Profile Photo & Basic Info)
            _buildCard(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: customPrimaryColor.withOpacity(0.1),
                      backgroundImage: _currentCustomer.profilePhotoUrl != null && _currentCustomer.profilePhotoUrl!.isNotEmpty
                          ? NetworkImage(_currentCustomer.profilePhotoUrl!)
                          : null,
                      child: _currentCustomer.profilePhotoUrl == null || _currentCustomer.profilePhotoUrl!.isEmpty
                          ? Icon(Icons.person, size: 60, color: customPrimaryColor)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentCustomer.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentCustomer.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 5),
                    Chip(
                      label: Text(_currentCustomer.status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      backgroundColor: _currentCustomer.status == 'active'
                          ? Colors.green
                          : _currentCustomer.status == 'blocked'
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            // Personal Details
            _buildSectionTitle('Personal Details'),
            _buildCard(
              child: Column(
                children: [
                  _buildDetailRow('Email:', _currentCustomer.email, icon: Icons.email),
                  const Divider(),
                  _buildDetailRow('Phone:', _currentCustomer.phone ?? 'N/A', icon: Icons.phone),
                  const Divider(),
                  _buildDetailRow('Address:', _currentCustomer.address ?? 'N/A', icon: Icons.location_on),
                  const Divider(),
                  _buildDetailRow(
                      'Join Date:', DateFormat('dd-MMM-yyyy').format(_currentCustomer.joinDate),
                      icon: Icons.calendar_today),
                  const Divider(),
                  _buildDetailRow('Login Method:', _currentCustomer.loginMethod ?? 'N/A', icon: Icons.security),
                  const Divider(),
                  _buildDetailRow('Device Details:', _currentCustomer.deviceDetails ?? 'N/A', icon: Icons.devices),
                ],
              ),
            ),

            // Status & Manual Actions
            _buildSectionTitle('Admin Actions'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_off, color: Colors.blueGrey),
                    title: const Text('Change Customer Status'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _showStatusChangeDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: const Text('Edit User Info'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _editUserInfo,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.vpn_key, color: Colors.purple),
                    title: const Text('Reset Password (Admin Side)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _resetPassword, // Backend action
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text('Send Email'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _sendEmailToCustomer,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.send, color: Colors.teal),
                    title: const Text('Send Push Notification'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: _sendPushNotification, // Requires FCM
                  ),
                ],
              ),
            ),

            // Order History (StreamBuilder for real-time updates)
            _buildSectionTitle('Order History'),
            _buildCard(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('orders')
                    .where('userId', isEqualTo: _currentCustomer.uid)
                    .orderBy('orderDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading orders: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No orders placed by this customer.'),
                    ));
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Important for nested list views
                    physics: const NeverScrollableScrollPhysics(), // Important
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var order = snapshot.data!.docs[index];
                      return ListTile(
                        leading: Icon(Icons.receipt_long, color: customPrimaryColor),
                        title: Text('Order ID: ${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${DateFormat('dd-MMM-yyyy HH:mm').format((order['orderDate'] as Timestamp).toDate())}'),
                            Text('Total: \$${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}'),
                            Text('Status: ${order['status'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          // TODO: Navigate to Order Detail Page
                          print('View order ${order.id} details');
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Customer Feedback / Reviews (Placeholder)
            _buildSectionTitle('Customer Feedback & Reviews'),
            _buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.reviews, color: Colors.brown),
                    title: const Text('View All Reviews by Customer'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Implement logic to fetch and display customer reviews.')),
                      );
                      // TODO: Navigate to a dedicated reviews list page for this customer
                    },
                  ),
                  // Optionally add a summary or a few latest reviews directly here
                ],
              ),
            ),

            // Wallet / Loyalty Points
            _buildSectionTitle('Wallet & Loyalty'),
            _buildCard(
              child: Column(
                children: [
                  _buildDetailRow('Current Points:', _currentCustomer.loyaltyPoints.toString(), icon: Icons.diamond),
                  const Divider(),
                  _buildDetailRow('Loyalty Tier:', _currentCustomer.loyaltyTier, icon: Icons.verified),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                    title: const Text('Manage Wallet Balance'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Implement dialog/page for wallet management.')),
                      );
                      // TODO: Show dialog to credit/debit wallet
                    },
                  ),
                ],
              ),
            ),

            // Analytics (Optional Placeholder)
            _buildSectionTitle('Analytics'),
            _buildCard(
              child: Column(
                children: [
                  _buildDetailRow('Lifetime Value (LTV):', '\$${(250.0).toStringAsFixed(2)}', icon: Icons.trending_up), // Example
                  const Divider(),
                  _buildDetailRow('Average Order Value (AOV):', '\$${(35.0).toStringAsFixed(2)}', icon: Icons.donut_large), // Example
                  const Divider(),
                  _buildDetailRow('Total Orders:', '10', icon: Icons.numbers), // Example
                  const Divider(),
                  _buildDetailRow(
                      'Last App Usage:', DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now().subtract(const Duration(days: 7))),
                      icon: Icons.access_time), // Example
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Helper extension for Customer model to enable easy copying with updated fields
extension CustomerCopy on Customer {
  Customer copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    DateTime? joinDate,
    DateTime? lastOrderDate,
    String? status,
    String? profilePhotoUrl,
    String? deviceDetails,
    String? loginMethod,
    int? loyaltyPoints,
    String? loyaltyTier,
    String? address,
  }) {
    return Customer(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      status: status ?? this.status,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      deviceDetails: deviceDetails ?? this.deviceDetails,
      loginMethod: loginMethod ?? this.loginMethod,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      address: address ?? this.address,
    );
  }
}