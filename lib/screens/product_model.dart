// product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String image;
  final double price;
  final String description;
  final String detail;
  final String category;
  final double rating;
  final int favourites;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
    required this.detail,
    required this.rating,
    required this.favourites,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Product data is null for document ID: ${doc.id}');
    }
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      detail: data['detail'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      favourites: (data['favourites'] ?? 0).toInt(),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      detail: json['detail'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      favourites: (json['favourites'] ?? 0).toInt(),
    );
  }

  // <--- YE METHOD ADD KAREIN AGAR wishlist mein Product object save karna hai --->
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Firestore document ID khud manage karta hai, isko yahan save karne ki aam taur par zaroorat nahi.
      // Agar aapko data ke andar ID bhi chahiye to add kar sakte hain.
      'title': title,
      'image': image,
      'price': price,
      'description': description,
      'detail': detail,
      'category': category,
      'rating': rating,
      'favourites': favourites,
    };
  }


}