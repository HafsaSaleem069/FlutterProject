import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/product_model.dart';
import 'package:project/screens/product_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'Burger';
  final List<Map<String, dynamic>> categories = [
    {'name': 'Burger', 'icon': Icons.fastfood},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Coffee', 'icon': Icons.local_cafe},
    {'name': 'Desserts', 'icon': Icons.icecream},
    {'name': 'Traditionals', 'icon': Icons.rice_bowl},
  ];

  Set<String> wishlistIds = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
    ensureNotificationCollectionExists();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
        });
      }
    });
  }

  Future<void> ensureNotificationCollectionExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final notifsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
    final snapshot = await notifsRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await notifsRef.add({
        'message': 'Welcome to Creative Delights!',
        'seen': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> fetchWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('wishlist')
              .get();
      if (mounted) {
        setState(() {
          wishlistIds = snapshot.docs.map((doc) => doc.id).toSet();
        });
      }
    }
  }

  Future<void> addToWishlist({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId)
          .set(productData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to wishlist")));
      await fetchWishlist();
    } catch (e) {
      print("Failed to add to wishlist: $e");
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from wishlist")));
      await fetchWishlist();
    } catch (e) {
      print("Failed to remove from wishlist: $e");
    }
  }

  Stream<QuerySnapshot> getProductsStream() {
    Query collectionRef = FirebaseFirestore.instance.collection('products');
    final String queryText = _searchQuery.toLowerCase();
    final double? priceSearchValue = double.tryParse(queryText);
    bool isNumericSearch = priceSearchValue != null;

    if (selectedCategory != 'Popular') {
      collectionRef = collectionRef.where(
        'category',
        isEqualTo: selectedCategory,
      );
    }

    if (queryText.isNotEmpty) {
      if (isNumericSearch) {
        collectionRef = collectionRef.where(
          'price',
          isEqualTo: priceSearchValue,
        );
      } else {
        // Text-based search (title)
        collectionRef = collectionRef
            .orderBy('title_lower')
            .where('title_lower', isGreaterThanOrEqualTo: queryText)
            .where('title_lower', isLessThanOrEqualTo: queryText + '\uf8ff');
      }
    } else {
      // Agar koi search query nahi hai, to default ordering (jese price)
      // aur category filter (agar laga hai) ko sambhalne ke liye orderBy lagao
      // Varna Firebase 'orderBy' na hone par index mang sakta hai agar sirf 'where' clause ho.
      collectionRef = collectionRef.orderBy('price');
    }

    return collectionRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: "Feel ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    TextSpan(
                      text: "Hungry\n",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    TextSpan(
                      text: "Order now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search any recipe or price",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    FocusScope.of(context).unfocus();
                  },
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Categories", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index]['name'];
                    final icon = categories[index]['icon'] as IconData;
                    final isSelected = category == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 25,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final products = snapshot.data?.docs ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products found for "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 14),

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productId = products[index].id;
                      final product = Product.fromFirestore(products[index]);
                      final title = product.title;
                      final query = _searchQuery.toLowerCase();
                      final matchIndex = title.toLowerCase().indexOf(query);

                      final baseStyle = Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.tertiary,
                      );

                      final TextStyle highlightStyle = baseStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      );

                      TextSpan styledTitle;
                      if (matchIndex != -1 && query.isNotEmpty) {
                        styledTitle = TextSpan(
                          style: baseStyle,
                          children: [
                            TextSpan(text: title.substring(0, matchIndex)),
                            TextSpan(
                              text: title.substring(
                                matchIndex,
                                matchIndex + query.length,
                              ),
                              style: highlightStyle,
                            ),
                            TextSpan(
                              text: title.substring(matchIndex + query.length),
                            ),
                          ],
                        );
                      } else {
                        styledTitle = TextSpan(text: title, style: baseStyle);
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                            // More squarish
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.tertiary,
                                blurRadius: 2,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Image.network(
                                    product.image ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: styledTitle,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (user != null) {
                                          wishlistIds.contains(productId)
                                              ? removeFromWishlist(productId)
                                              : addToWishlist(
                                                productId: productId,
                                                productData: product.toJson(),
                                              );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please log in to add to wishlist.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color:
                                            wishlistIds.contains(productId)
                                                ? Colors.red.shade900
                                                : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  "Rs ${product.price}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
