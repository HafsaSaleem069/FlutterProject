// lib/pages/customers_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage registered users and their details.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No customers registered yet.', style: TextStyle(color: Colors.white70)));
                }
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8), // CardTheme provides outer margin
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow.shade700, // Stronger yellow for avatar
                          child: Text(
                            user['name']?.isNotEmpty == true ? user['name']!.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user['name'] ?? 'No Name', style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(user['email'] ?? 'No Email', style: Theme.of(context).textTheme.titleSmall),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF2C2C2C),
                                title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
                                content: Text(
                                  'Are you sure you want to delete user: ${user['name'] ?? 'No Name'}?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'), // Uses TextButtonThemeData
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmDelete == true) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deleted successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete user: $e')),
                                );
                              }
                            }
                          },
                        ),
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