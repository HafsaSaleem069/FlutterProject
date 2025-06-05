import 'package:cloud_firestore/cloud_firestore.dart';

final List<Map<String, dynamic>> meals = [
  {
    "name": "Beef Burger",
    "category": "Burger",
    "image": "assets/images/cheez burger.jpg",
    "description":
        "A juicy beef patty with caramelized onions and secret sauce.",
    "price": 999,
  },
  {
    "name": "Zinger Burger",
    "category": "Burger",
    "image": "assets/images/zinger burger.jpg",
    "description":
        "Crispy chicken with a spicy kick, layered with fresh lettuce.",
    "price": 750,
  },
  {
    "name": "Cheez Burger",
    "category": "Burger",
    "image": "assets/images/beef burger.jpg",
    "description":
        "Overflowing with melted cheddar and a dash of smoky flavor.",
    "price": 1199,
  },
  {
    "name": "Double Decker",
    "category": "Burger",
    "image": "assets/images/double decker.jpg",
    "description":
        "Two thick patties stacked with tangy pickles and creamy mayo.",
    "price": 899,
  },
  {
    "name": "Chicken Fillet",
    "category": "Burger",
    "image":
        "assets/images/Chicken Fillet Burger (Crispy Buttermilk Fried Chicken Burger).jpeg",
    "description":
        "Golden fried chicken fillet with a hint of garlic and herb seasoning.",
    "price": 999,
  },
  {
    "name": "Veggie Burger",
    "category": "Burger",
    "image": "assets/images/Chickpea Veggie Burgers.jpeg",
    "description": "Loaded with fresh veggies and a flavorful chickpea patty.",
    "price": 750,
  },
  {
    "name": "Steak Burger",
    "category": "Burger",
    "image": "assets/images/steak Burger.jpeg",
    "description":
        "Tender steak slices, sautéed mushrooms, and a drizzle of BBQ sauce.",
    "price": 1399,
  },
  {
    "name": "Kidney Bean Burger",
    "category": "Burger",
    "image": "assets/images/Ultimate Kidney Bean Burger – Nutriciously.jpeg",
    "description":
        "Packed with kidney beans, zesty spices, and a touch of lime.",
    "price": 899,
  },
  {
    "name": "Black Coffee",
    "category": "Coffee",
    "image": "assets/images/blackCoffee.jpeg",
    "description": "Strong and aromatic brew",
    "price": 790,
  },
  {
    "name": "Cappuccino",
    "category": "Coffee",
    "image": "assets/images/cappuccino.jpeg",
    "description": "Creamy coffee with froth",
    "price": 400,
  },
  {
    "name": "Espresso Martini",
    "category": "Coffee",
    "image": "assets/images/Espresso Martini.jpeg",
    "description": "Espresso with a twist",
    "price": 600,
  },
  {
    "name": "Cold Brew Coffee",
    "category": "Coffee",
    "image": "assets/images/Cold Brew Coffee.jpeg",
    "description": "Smooth and refreshing drink",
    "price": 750,
  },
  {
    "name": "Latte Coffee",
    "category": "Coffee",
    "image": "assets/images/coffee latte cup.jpeg",
    "description": "Rich and creamy delight",
    "price": 450,
  },
  {
    "name": "Mocha Latte",
    "category": "Coffee",
    "image": "assets/images/Mocha recipe.jpeg",
    "description": "Coffee with chocolate flavor",
    "price": 500,
  },
  {
    "name": "Special Lotus Coffee",
    "category": "Coffee",
    "image": "assets/images/lotusCoffee.jpeg",
    "description": "Infused with lotus biscuit",
    "price": 700,
  },
  {
    "name": "Turkish Coffee",
    "category": "Coffee",
    "image": "assets/images/Turkish Coffee.jpeg",
    "description": "Traditional and flavorful cup",
    "price": 800,
  },
  {
    "name": "Chana Masala",
    "category": "Traditionals",
    "image": "assets/images/Chana Masala.jpeg",
    "description": "Spicy and flavorful chickpea curry",
    "price": 599,
  },
  {
    "name": "Ramen Noodles",
    "category": "Traditionals",
    "image": "assets/images/Korean food ❤.jpeg",
    "description": "Authentic Korean style ramen",
    "price": 750,
  },
  {
    "name": "Sambar Daal",
    "category": "Traditionals",
    "image": "assets/images/Sambar Wali Dal.jpeg",
    "description": "Traditional South Indian lentil soup",
    "price": 699,
  },
  {
    "name": "Shahi Paneer",
    "category": "Traditionals",
    "image": "assets/images/Shahi Paneer.jpeg",
    "description": "Paneer cooked in rich creamy gravy",
    "price": 899,
  },
  {
    "name": "Alfredo Pasta",
    "category": "Traditionals",
    "image": "assets/images/pasta.jpeg",
    "description": "Creamy pasta with a cheesy twist",
    "price": 1199,
  },
  {
    "name": "Saucy Momos",
    "category": "Traditionals",
    "image": "assets/images/Spicy momo.jpeg",
    "description": "Steamed dumplings with spicy sauce",
    "price": 750,
  },
  {
    "name": "Chicken with Rice",
    "category": "Traditionals",
    "image": "assets/images/Chicken rice.jpeg",
    "description": "Grilled chicken served over rice",
    "price": 1199,
  },
  {
    "name": "Chicken Biryani",
    "category": "Traditionals",
    "image": "assets/images/Chicken Biryani.jpeg",
    "description": "Traditional Biryani with Raita",
    "price": 499,
  },
  {
    "name": "Chocolate Cheese Tiramisu",
    "category": "Desserts",
    "image": "assets/images/ChocCheeseTiramisu.jpeg",
    "description": "Rich chocolate with creamy layers",
    "price": 1299,
  },
  {
    "name": "Coconut-Pistachio Baklava",
    "category": "Desserts",
    "image": "assets/images/Coconut and Pistachio Baklava.jpeg",
    "description": "Flaky layers with nutty flavors",
    "price": 1499,
  },
  {
    "name": "Strawberry Vegan Cake",
    "category": "Desserts",
    "image": "assets/images/StrwVeganCake.jpeg",
    "description": "Fresh strawberries and vegan delight",
    "price": 1399,
  },
  {
    "name": "Macarons",
    "category": "Desserts",
    "image": "assets/images/macarons.jpeg",
    "description": "Assorted flavors, crisp and chewy (Pack of 3)",
    "price": 999,
  },
  {
    "name": "Mithayi",
    "category": "Desserts",
    "image": "assets/images/Mithayi.jpeg",
    "description": "Traditional sweets with a twist",
    "price": 1699,
  },
  {
    "name": "Strawberry Cream Tiramisu",
    "category": "Desserts",
    "image": "assets/images/StrwCreamTiramisu.jpeg",
    "description": "Layers of strawberry and cream",
    "price": 1499,
  },
  {
    "name": "Donuts",
    "category": "Desserts",
    "image": "assets/images/Donuts.jpeg",
    "description": "Pack of 4, glazed to perfection",
    "price": 1799,
  },
  {
    "name": "Cupcakes",
    "category": "Desserts",
    "image": "assets/images/Vegan Strawberry Lemon Cupcakes.jpeg",
    "description": "Vegan strawberry with a hint of lemon",
    "price": 1299,
  },
  {
    "name": "BBQ Pizza",
    "category": "Pizza",
    "image": "assets/images/bbqPizza.jpeg",
    "description": "With special BBQ sauce",
    "price": 1599,
  },
  {
    "name": "Beef Pizza Pie",
    "category": "Pizza",
    "image": "assets/images/Beef Pizza Pie.jpeg",
    "description": "With double beef sides",
    "price": 1699,
  },
  {
    "name": "Pepproni Pizza",
    "category": "Pizza",
    "image": "assets/images/peproni.jpeg",
    "description": "With extra cheese",
    "price": 1299,
  },
  {
    "name": "Cheese Pizza",
    "category": "Pizza",
    "image": "assets/images/cheesePizza.jpeg",
    "description": "Special cheesy juicy pizza",
    "price": 1299,
  },
  {
    "name": "Chicken Fajita",
    "category": "Pizza",
    "image": "assets/images/grilled p.jpg",
    "description": "With extra cheese slices",
    "price": 1299,
  },
  {
    "name": "Mushroom Olives",
    "category": "Pizza",
    "image": "assets/images/mushroom p.jpg",
    "description": "With extra cheese slices",
    "price": 1299,
  },
  {
    "name": "Mini Pizzas",
    "category": "Pizza",
    "image": "assets/images/mini p.jpg",
    "description": "Pack of 4",
    "price": 1599,
  },
  {
    "name": "Chicken Onion",
    "category": "Pizza",
    "image": "assets/images/bbq p.jpg",
    "description": "With extra cheese slices",
    "price": 1299,
  },
  {
    "name": "tikka boti",
    "category": "Traditionals",
    "image": "assets/images/1734901283100.jpg",
    "description": "tikka boti handi full plate",
    "price": 1200,
  },
  {
    "name": "Molten Lava Cake",
    "category": "Desserts",
    "image": "assets/images/1734981459856.jpg",
    "description":
    "Perfect for chocolate lovers looking for a rich and indulgent dessert.",
    "price": 4000,
  },
];

Future<void> uploadMealsToFirestore() async {
  final firestore = FirebaseFirestore.instance;

  for (final meal in meals) {
    try {
      await firestore.collection('products').add({
        'title': meal['name'],
        'category': meal['category'],
        'description': meal['description'],
        'image': meal['image'],
        // relative to assets or Firebase URL if uploaded
        'price': meal['price'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("✅ Uploaded: ${meal['name']}");
    } catch (e) {
      print("❌ Error uploading ${meal['name']}: $e");
    }
  }
}
