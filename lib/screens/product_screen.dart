import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double totalPrice = 0;

  // currentRating ab user ki selected rating hogi, display ke liye fetchedRating use karenge
  double currentRating = 0;

  // Nayi variables for fetched data
  int _favouriteCount = 0;
  double _averageRating = 0.0;
  bool _isLoadingCounts = true; // Loading state ke liye

  List<String> selectedToppings = [];
  String? selectedSize;
  String? selectedSpice;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.product.price;
    currentRating =
        widget
            .product
            .rating; // User ki current rating, ya product ki default rating
    updatePrice();
    _fetchProductCountsAndRatings(); // Naya method call karein data fetch karne ke liye
  }

  // ==== Naya Method: Favourites Count aur Average Rating Fetch karne ke liye ====
  Future<void> _fetchProductCountsAndRatings() async {
    setState(() {
      _isLoadingCounts = true;
    });

    try {
      // 1. Favourites Count Fetch karna
      // Har user ki wishlist mein check karna hoga
      // Yeh bohot expensive query hai client side par!
      // Agar aap Cloud Functions use nahi kar rahe, toh yeh chalega, lekin scale nahi karega.
      int count = 0;
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        final wishlistSnapshot =
            await userDoc.reference
                .collection('wishlist')
                .doc(widget.product.id)
                .get();
        if (wishlistSnapshot.exists) {
          count++;
        }
      }
      _favouriteCount = count;

      // 2. Average Rating Fetch karna
      // Yeh bhi abhi product ke document se aa raha hai.
      // Agar aapko users ki multiple ratings ka average chahiye, to aapko
      // ek separate collection banani padegi jahan har user ki rating store ho.
      // For now, hum assume karte hain ke `product.rating` hi average hai ya aap isko update karte hain.
      // Agar aap har user ki rating save karte hain (e.g., product_ratings/{product_id}/user_ratings/{user_id}),
      // to aapko woh data fetch karke average nikalna hoga.
      // Example: Agar har user ne product ko rate kiya aur woh ratings 'product_ratings' subcollection mein hain:
      final productRatingsSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product.id)
              .collection(
                'user_ratings',
              ) // Assuming a subcollection for user-specific ratings
              .get();

      if (productRatingsSnapshot.docs.isNotEmpty) {
        double totalSum = 0;
        int numRatings = 0;
        for (var ratingDoc in productRatingsSnapshot.docs) {
          final ratingData = ratingDoc.data();
          if (ratingData.containsKey('rating')) {
            totalSum += (ratingData['rating'] as num).toDouble();
            numRatings++;
          }
        }
        if (numRatings > 0) {
          _averageRating = totalSum / numRatings;
        }
      } else {
        _averageRating =
            widget
                .product
                .rating; // Agar koi rating nahi, default product rating dikhao
      }
    } catch (e) {
      print("Error fetching product counts and ratings: $e");
      // Handle error, maybe show default values or an error message
    } finally {
      setState(() {
        _isLoadingCounts = false;
      });
    }
  }

  void updatePrice() {
    double base = widget.product.price;

    // Size Price
    if (selectedSize != null) {
      final sizePrices = {
        'Small': 1000.0,
        'Medium': 1500.0,
        'Large': 2000.0,
        'Party': 2500.0,
      };
      if (widget.product.category == 'Pizza' ||
          sizePrices.containsKey(selectedSize)) {
        base = sizePrices[selectedSize] ?? base;
      }
    }

    // Toppings
    double toppingsPrice = 0;
    if (widget.product.category == 'Pizza') {
      for (var topping in selectedToppings) {
        final toppingPrices = {
          'Extra Cheese': 200.0,
          'Jalapeños': 300.0,
          'Olives': 500.0,
        };
        toppingsPrice += toppingPrices[topping] ?? 0;
      }
    }

    setState(() {
      totalPrice = base + toppingsPrice;
    });
  }

  void saveRating(int newRating) async {
    print("Trying to save rating for Product ID: ${widget.product.id}");

    if (widget.product.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error: Product ID majood nahi hai, rating save nahi ho saki.",
          ),
        ),
      );
      return;
    }

    try {
      // Ab yahan rating ko product document mein update karne ki bajaye,
      // us product ki 'user_ratings' subcollection mein save karenge.
      // Is tarah har user apni rating de sakega aur hum average nikal sakenge.
      // User ki ID use karein document ID ke taur par user_ratings subcollection mein.
      final currentUser =
          FirebaseAuth.instance.currentUser; // Import firebase_auth
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rating dene ke liye login zaroori hai."),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .collection('user_ratings') // Nayi subcollection
          .doc(currentUser.uid) // User ki ID se document banayein
          .set({
            'rating': newRating,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Rating save hone ke baad counts aur ratings ko dobara fetch karein
      await _fetchProductCountsAndRatings();

      setState(() {
        currentRating =
            newRating.toDouble(); // User ki apni selected rating update karein
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rating save ho gai! Shukriya.")),
      );
    } catch (e) {
      print("Firebase error during rating save: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save rating: $e")));
    }
  }

  Future<void> addToCart(Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(productData['id'])
          .set(productData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to Cart')));
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  child: Image.network(
                    product.image,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Overflow issue fix ke liye SizedBox adjust kia
                SizedBox(height: 600), // Image height - Positioned top offset
              ],
            ),
          ),
          Positioned(
            top: 270,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // height: MediaQuery.of(context).size.height - 320, // Ye line hata di
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text("Free Delivery"),
                              ),
                              Text(
                                "Rs. ${totalPrice.toInt()}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rate this product:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index <
                                          currentRating // User ki selected rating dikhayegi
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentRating = (index + 1).toDouble();
                                  });
                                  saveRating(index + 1);
                                },
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Favourites count display
                          _isLoadingCounts
                              ? CircularProgressIndicator() // Loading state
                              : _circularInfo(
                                "$_favouriteCount", // Dynamically fetched count
                                "Favourite",
                                Icons.favorite,
                              ),
                          // Reviews/Rating display
                          _isLoadingCounts
                              ? CircularProgressIndicator() // Loading state
                              : _circularInfo(
                                "${_averageRating.toStringAsFixed(1)}",
                                // Dynamically fetched average
                                "Reviews",
                                Icons.star,
                              ),
                          _circularInfo("50+", "Sold", Icons.shopping_cart),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.detail),
                      const SizedBox(height: 20),

                      if (product.category == 'Pizza') ...[
                        const Text(
                          "Customize Your Pizza",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children:
                              ['Small', 'Medium', 'Large', 'Party']
                                  .map(
                                    (size) => ChoiceChip(
                                      label: Text(size),
                                      selected: selectedSize == size,
                                      onSelected: (val) {
                                        setState(() {
                                          selectedSize = val ? size : null;
                                          updatePrice();
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Toppings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children:
                              ['Extra Cheese', 'Jalapeños', 'Olives']
                                  .map(
                                    (topping) => FilterChip(
                                      label: Text(topping),
                                      selected: selectedToppings.contains(
                                        topping,
                                      ),
                                      onSelected: (val) {
                                        setState(() {
                                          if (val) {
                                            selectedToppings.add(topping);
                                          } else {
                                            selectedToppings.remove(topping);
                                          }
                                          updatePrice();
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {addToCart(product.toJson());},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.red.shade900,
                        ),
                        child: Text(
                          "Add to Cart -   Rs. ${totalPrice.toInt()}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularInfo(String value, String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.red.shade900,
          radius: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
