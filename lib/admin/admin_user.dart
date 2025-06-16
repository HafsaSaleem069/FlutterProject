// lib/screens/admin/customer_management_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../database/customer_model.dart';
import 'customer_detail.dart';
class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({Key? key}) : super(key: key);

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _filterStatus; // 'active', 'blocked', 'deactivated', null (for all)
  String? _filterSpending; // 'high', 'low', null
  String? _filterFrequency; // 'frequent', 'occasional', null

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          color: Theme.of(context).primaryColor, // Use primary color
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can define a custom primary color based on your theme
    final Color customPrimaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor, // Use card color for search background
              ),
            ),
          ),

          // Filters (Horizontal Scrollable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Status Filter
                  FilterChip(
                    label: const Text('Status'),
                    selected: _filterStatus != null,
                    onSelected: (bool selected) {
                      setState(() {
                        _filterStatus = selected ? 'active' : null; // Example
                        // You can expand this to a dropdown for multiple statuses
                      });
                    },
                    selectedColor: customPrimaryColor.withOpacity(0.2),
                    checkmarkColor: customPrimaryColor,
                  ),
                  const SizedBox(width: 8),
                  // High Spending Filter
                  FilterChip(
                    label: const Text('High Spenders'),
                    selected: _filterSpending == 'high',
                    onSelected: (bool selected) {
                      setState(() {
                        _filterSpending = selected ? 'high' : null;
                      });
                    },
                    selectedColor: customPrimaryColor.withOpacity(0.2),
                    checkmarkColor: customPrimaryColor,
                  ),
                  const SizedBox(width: 8),
                  // Frequent Customers Filter
                  FilterChip(
                    label: const Text('Frequent Customers'),
                    selected: _filterFrequency == 'frequent',
                    onSelected: (bool selected) {
                      setState(() {
                        _filterFrequency = selected ? 'frequent' : null;
                      });
                    },
                    selectedColor: customPrimaryColor.withOpacity(0.2),
                    checkmarkColor: customPrimaryColor,
                  ),
                  // Add more filters as needed (e.g., Date Range)
                ],
              ),
            ),
          ),

          _buildSectionTitle('All Customers'),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No customers found.'));
                }

                List<Customer> customers = snapshot.data!.docs
                    .map((doc) => Customer.fromFirestore(doc))
                    .where((customer) {
                  // Apply Search Filter
                  bool matchesSearch = customer.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                      customer.email.toLowerCase().contains(_searchText.toLowerCase());

                  // Apply Status Filter
                  bool matchesStatus = _filterStatus == null || customer.status == _filterStatus;

                  // Apply Spending Filter (Example logic - you'd need actual LTV data or thresholds)
                  bool matchesSpending = _filterSpending == null ||
                      (_filterSpending == 'high' && customer.loyaltyPoints > 500); // Example threshold

                  // Apply Frequency Filter (Example logic - based on last order date or total orders)
                  bool matchesFrequency = _filterFrequency == null ||
                      (_filterFrequency == 'frequent' && (customer.lastOrderDate != null &&
                          DateTime.now().difference(customer.lastOrderDate!).inDays < 30)); // Last order within 30 days

                  return matchesSearch && matchesStatus && matchesSpending && matchesFrequency;
                }).toList();

                if (customers.isEmpty) {
                  return const Center(child: Text('No matching customers found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: customPrimaryColor.withOpacity(0.1),
                          backgroundImage: customer.profilePhotoUrl != null && customer.profilePhotoUrl!.isNotEmpty
                              ? NetworkImage(customer.profilePhotoUrl!)
                              : null,
                          child: customer.profilePhotoUrl == null || customer.profilePhotoUrl!.isEmpty
                              ? Icon(Icons.person, color: customPrimaryColor)
                              : null,
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.email),
                            Text('Status: ${customer.status.toUpperCase()}'),
                            if (customer.lastOrderDate != null)
                              Text('Last Order: ${DateFormat('dd-MMM-yyyy').format(customer.lastOrderDate!)}'),
                            Text('Joined: ${DateFormat('dd-MMM-yyyy').format(customer.joinDate)}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailPage(customer: customer),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}