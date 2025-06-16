// lib/models/customer.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final DateTime joinDate;
  final DateTime? lastOrderDate;
  final String status; // e.g., 'active', 'blocked', 'deactivated'
  final String? profilePhotoUrl;
  final String? deviceDetails; // e.g., 'Android', 'iOS', 'Web'
  final String? loginMethod; // e.g., 'Email/Password', 'Google', 'Apple'
  final int loyaltyPoints;
  final String loyaltyTier;
  final String? address; // Example, could be a map or separate object
  // Add more fields as needed

  Customer({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.joinDate,
    this.lastOrderDate,
    this.status = 'active',
    this.profilePhotoUrl,
    this.deviceDetails,
    this.loginMethod,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Bronze',
    this.address,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Customer(
      uid: doc.id,
      name: data['name'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      phone: data['phone'],
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      lastOrderDate: (data['lastOrderDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
      profilePhotoUrl: data['profilePhotoUrl'],
      deviceDetails: data['deviceDetails'],
      loginMethod: data['loginMethod'],
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      loyaltyTier: data['loyaltyTier'] ?? 'Bronze',
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'joinDate': Timestamp.fromDate(joinDate),
      'lastOrderDate': lastOrderDate != null ? Timestamp.fromDate(lastOrderDate!) : null,
      'status': status,
      'profilePhotoUrl': profilePhotoUrl,
      'deviceDetails': deviceDetails,
      'loginMethod': loginMethod,
      'loyaltyPoints': loyaltyPoints,
      'loyaltyTier': loyaltyTier,
      'address': address,
    };
  }
}