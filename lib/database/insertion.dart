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
Future<void> addDetailFieldToAllProducts() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final querySnapshot = await firestore.collection('products').get();

    for (final doc in querySnapshot.docs) {
      // You can generate or customize this detail as needed
      const sampleDetail = '''This is one of our best-selling products, loved by food enthusiasts for its perfect balance of flavor, freshness, and quality ingredients. Whether you're ordering it for a quick lunch or a weekend treat, it never disappoints.

Carefully crafted with attention to detail, every bite delivers a satisfying experience that keeps customers coming back. It's a go-to choice for anyone who values delicious, dependable meals made with premium ingredients.'''
      ;

      await firestore.collection('products').doc(doc.id).update({
        'detail': sampleDetail,
      });

      print("✅ Added detail to: ${doc['title']}");
    }
  } catch (e) {
    print("❌ Error updating products with detail field: $e");
  }
}
Future<void> addTitleLowerToAllProducts() async {
  final productsRef = FirebaseFirestore.instance.collection('products');
  final snapshot = await productsRef.get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final title = data['title'];

    if (title != null && title is String) {
      await doc.reference.update({'title_lower': title.toLowerCase()});
      print('Updated ${doc.id} with title_lower: ${title.toLowerCase()}');
    } else {
      print('Skipping ${doc.id} — no valid title found');
    }
  }

  print('✅ All products updated with title_lower');
}

// Future<void> updateImagePaths() async {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   try {
//     QuerySnapshot snapshot = await firestore.collection('products').get();
//
//     if (snapshot.docs.isEmpty) {
//       print('⚠️ No products found in Firestore.');
//       return;
//     }
//
//     int updatedCount = 0;
//     int skippedCount = 0;
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//
//       if (data.containsKey('image') && data['image'] != null) {
//         String oldImage = data['image'];
//         String fileName = oldImage.split('/').last;
//
//         String newUrl = 'http://192.168.1.266:3000/images/$fileName';
//
//         await firestore.collection('products').doc(doc.id).update({
//           'image': newUrl,
//         });
//
//         updatedCount++;
//         print('✅ Updated: ${doc.id} -> $newUrl');
//       } else {
//         skippedCount++;
//         print('⚠️ Skipped: ${doc.id} — No valid "image" field found');
//       }
//     }
//
//     print('\n🎉 Done! Total updated: $updatedCount | Skipped: $skippedCount');
//   } catch (e) {
//     print('❌ Error while updating image URLs: $e');
//   }
// }
final Map<String, String> imageMap = {
  'dessertMain.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761812/dessertMain_csumfb.jpg',
  'Donuts.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761804/Donuts_cweka1.jpg',
  'ChocCheeseTiramisu.jpeg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761802/ChocCheeseTiramisu_rlogjs.jpg',
  'Harlow_Ice_cream.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761845/Harlow_Ice_cream_icezm9.jpg',
  'coffeeMain.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761811/coffeeMain_hsnvtg.jpg',
  'grilled_p.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761808/grilled_p_tconnw.jpg',
  'Espresso_Martini.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761807/Espresso_Martini_qxngyk.jpg',
  'double_decker.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761806/double_decker_pw4xz7.jpg',
  'burgerHeading.png':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761805/burgerHeading_suwmyh.png',
  'coffee_latte_cup.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761803/coffee_latte_cup_aufrzm.jpg',
  'Coconut_and_Pistachio_Baklava.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761801/Coconut_and_Pistachio_Baklava_a60udb.jpg',
  'Chicken_Biryani.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761801/Chicken_Biryani_puuxux.jpg',
  'Chicken_rice.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761801/Chicken_rice_uu1wbv.jpg',
  'Chicken_Fillet_Burger_Crispy_Buttermilk_Fried_Chicken_Burger.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761800/Chicken_Fillet_Burger_Crispy_Buttermilk_Fried_Chicken_Burger_kub1u1.jpg',
  'cheez_burger.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761800/cheez_burger_ly6e8f.jpg',
  'cheesePizza.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761799/cheesePizza_yl01fz.jpg',
  'Beef_Pizza_Pie.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761799/Beef_Pizza_Pie_d3re8o.jpg',
  'blackCoffee.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761798/blackCoffee_irulaw.jpg',
  'Chana_Masala.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761798/Chana_Masala_geftrh.jpg',
  'bbqPizza.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761797/bbqPizza_kjxr75.jpg',
  'bbq_p.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761796/bbq_p_fdkobm.jpg',
  'pasta.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761796/pasta_kzk5j4.jpg',
  'peproni.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761795/peproni_glcttl.jpg',
  'mushroom_p.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761795/mushroom_p_ppv20h.jpg',
  'Ultimate_Kidney_Bean_Burger_Nutriciously.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761794/Ultimate_Kidney_Bean_Burger_Nutriciously_p51dot.jpg',
  'StrwVeganCake.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761793/StrwVeganCake_bekuar.jpg',
  'StrwCreamTiramisu.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761793/StrwCreamTiramisu_oam67n.jpg',
  'Mocha_recipe.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761793/Mocha_recipe_nqabej.jpg',
  'Mithayi.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761792/Mithayi_bhaqts.jpg',
  'mini_p.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761792/mini_p_vqrfkp.jpg',
  'macarons.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761792/macarons_tvdfgi.jpg',
  'Spicy_momo.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761792/Spicy_momo_kmbqut.jpg',
  'steak_Burger.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761792/steak_Burger_ujdsr3.jpg',
  'lotusCoffee.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761791/lotusCoffee_zhywit.jpg',
  'Shahi_Paneer.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761790/Shahi_Paneer_cwhd3u.jpg',
  'Korean_food.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761789/Korean_food_en2qbe.jpg',
  'img1.jpg':
      'https://res.cloudinary.com/dlnbmx3it/image/upload/v1752761790/img1_dhz9mh.jpg',
};

Future<void> updateFirestoreImageLinks() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot snapshot = await firestore.collection('products').get();

    int updated = 0;
    int skipped = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (!data.containsKey('image') || data['image'] == null) {
        skipped++;
        continue;
      }

      String oldUrl = data['image'];
      String fileName = oldUrl.split('/').last; // e.g. ChocCheeseTiramisu.jpeg

      if (imageMap.containsKey(fileName)) {
        String newUrl = imageMap[fileName]!;

        await firestore.collection('products').doc(doc.id).update({
          'image': newUrl,
        });

        updated++;
        print('✅ Updated: ${doc.id} -> $newUrl');
      } else {
        skipped++;
        print('⚠️ Skipped: ${doc.id} — No new URL found for $fileName');
      }
    }

    print('\n🎉 Done! Updated: $updated | Skipped: $skipped');
  } catch (e) {
    print('❌ Error: $e');
  }
}
