import 'package:cloud_firestore/cloud_firestore.dart';

// final List<Map<String, dynamic>> meals = [
// ];
//
// Future<void> uploadMealsToFirestore() async {
//   final firestore = FirebaseFirestore.instance;
//
//   for (final meal in meals) {
//     try {
//       await firestore.collection('products').add({
//         'title': meal['name'],
//         'category': meal['category'],
//         'description': meal['description'],
//         'image': meal['image'],
//         // relative to assets or Firebase URL if uploaded
//         'price': meal['price'],
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       print("✅ Uploaded: ${meal['name']}");
//     } catch (e) {
//       print("❌ Error uploading ${meal['name']}: $e");
//     }
//   }
// }
/// Adds a demo detail field (2-paragraph summary) to each product in Firestore
// Future<void> addDetailFieldToAllProducts() async {
//   final firestore = FirebaseFirestore.instance;
//
//   try {
//     final querySnapshot = await firestore.collection('products').get();
//
//     for (final doc in querySnapshot.docs) {
//       // You can generate or customize this detail as needed
//       const sampleDetail = '''
// This is one of our best-selling products, loved by food enthusiasts for its perfect balance of flavor, freshness, and quality ingredients. Whether you're ordering it for a quick lunch or a weekend treat, it never disappoints.
//
// Prepared with care by our expert chefs, this item brings a restaurant-quality experience right to your doorstep. Give it a try and taste the difference!
// ''';
//
//       await firestore.collection('products').doc(doc.id).update({
//         'detail': sampleDetail,
//       });
//
//       print("✅ Added detail to: ${doc['title']}");
//     }
//   } catch (e) {
//     print("❌ Error updating products with detail field: $e");
//   }
// }
Future<void> addTitleLowerToAllProducts() async {
  final productsRef = FirebaseFirestore.instance.collection('products');
  final snapshot = await productsRef.get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final title = data['title'];

    if (title != null && title is String) {
      await doc.reference.update({
        'title_lower': title.toLowerCase(),
      });
      print('Updated ${doc.id} with title_lower: ${title.toLowerCase()}');
    } else {
      print('Skipping ${doc.id} — no valid title found');
    }
  }

  print('✅ All products updated with title_lower');
}
