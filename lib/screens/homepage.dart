<<<<<<< HEAD
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/screens/product_model.dart';
// import 'package:project/screens/product_screen.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String selectedCategory = 'Burger';
//   final List<Map<String, dynamic>> categories = [
//     {'name': 'Burger', 'icon': Icons.fastfood},
//     {'name': 'Pizza', 'icon': Icons.local_pizza},
//     {'name': 'Coffee', 'icon': Icons.local_cafe},
//     {'name': 'Desserts', 'icon': Icons.icecream},
//     {'name': 'Traditionals', 'icon': Icons.rice_bowl},
//   ];
//
//   Set<String> wishlistIds = {};
//
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   Timer? _debounce;
//
//   // AdMob variables
//   BannerAd? _bannerAd;
//   bool _isBannerAdReady = false;
//   InterstitialAd? _interstitialAd;
//   bool _isInterstitialAdReady = false;
//   int _productViewCount = 0;
//
//   // Test Ad Unit IDs (replace with your real ad unit IDs for production)
//   static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit ID
//   static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ad unit ID
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWishlist();
//     ensureNotificationCollectionExists();
//     _searchController.addListener(_onSearchChanged);
//
//     // Initialize ads
//     _loadBannerAd();
//     _loadInterstitialAd();
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _debounce?.cancel();
//
//     // Dispose ads
//     _bannerAd?.dispose();
//     _interstitialAd?.dispose();
//
//     super.dispose();
//   }
//
//   // Load Banner Ad
//   void _loadBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: _bannerAdUnitId,
//       request: const AdRequest(),
//       size: AdSize.banner,
//       listener: BannerAdListener(
//         onAdLoaded: (_) {
//           setState(() {
//             _isBannerAdReady = true;
//           });
//         },
//         onAdFailedToLoad: (ad, err) {
//           print('Failed to load a banner ad: ${err.message}');
//           _isBannerAdReady = false;
//           ad.dispose();
//         },
//       ),
//     );
//
//     _bannerAd!.load();
//   }
//
//   // Load Interstitial Ad
//   void _loadInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: _interstitialAdUnitId,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           print('$ad loaded');
//           _interstitialAd = ad;
//           _isInterstitialAdReady = true;
//           _setInterstitialAdCallbacks();
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('InterstitialAd failed to load: $error');
//           _interstitialAd = null;
//           _isInterstitialAdReady = false;
//           // Try to reload the ad after a delay
//           Future.delayed(const Duration(seconds: 30), () {
//             _loadInterstitialAd();
//           });
//         },
//       ),
//     );
//   }
//
//   // Set Interstitial Ad Callbacks
//   void _setInterstitialAdCallbacks() {
//     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (InterstitialAd ad) {
//         print('$ad onAdShowedFullScreenContent.');
//       },
//       onAdDismissedFullScreenContent: (InterstitialAd ad) {
//         print('$ad onAdDismissedFullScreenContent.');
//         ad.dispose();
//         _isInterstitialAdReady = false;
//         _loadInterstitialAd(); // Load a new ad
//       },
//       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         ad.dispose();
//         _isInterstitialAdReady = false;
//         _loadInterstitialAd(); // Load a new ad
//       },
//     );
//   }
//
//   // Show Interstitial Ad
//   void _showInterstitialAd() {
//     if (_isInterstitialAdReady && _interstitialAd != null) {
//       _interstitialAd!.show();
//     } else {
//       print('Interstitial ad is not ready yet.');
//     }
//   }
//
//   // Handle product tap with ad logic
//   void _onProductTap(Product product) {
//     _productViewCount++;
//
//     // Show interstitial ad every 2 product views
//     if (_productViewCount % 2 == 0) {
//       _showInterstitialAd();
//     }
//
//     // Navigate to product detail page
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProductDetailPage(product: product),
//       ),
//     );
//   }
//
//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (mounted) {
//         setState(() {
//           _searchQuery = _searchController.text.trim();
//         });
//       }
//     });
//   }
//
//   Future<void> ensureNotificationCollectionExists() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     final notifsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('notifications');
//     final snapshot = await notifsRef.limit(1).get();
//     if (snapshot.docs.isEmpty) {
//       await notifsRef.add({
//         'message': 'Welcome to Creative Delights!',
//         'seen': false,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }
//   }
//
//   Future<void> fetchWishlist() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final snapshot =
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('wishlist')
//           .get();
//       if (mounted) {
//         setState(() {
//           wishlistIds = snapshot.docs.map((doc) => doc.id).toSet();
//         });
//       }
//     }
//   }
//
//   Future<void> addToWishlist({
//     required String productId,
//     required Map<String, dynamic> productData,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('wishlist')
//           .doc(productId)
//           .set(productData);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Added to wishlist")));
//       await fetchWishlist();
//     } catch (e) {
//       print("Failed to add to wishlist: $e");
//     }
//   }
//
//   Future<void> removeFromWishlist(String productId) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('wishlist')
//           .doc(productId)
//           .delete();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Removed from wishlist")));
//       await fetchWishlist();
//     } catch (e) {
//       print("Failed to remove from wishlist: $e");
//     }
//   }
//
//   Stream<QuerySnapshot> getProductsStream() {
//     Query collectionRef = FirebaseFirestore.instance.collection('products');
//     final String queryText = _searchQuery.toLowerCase();
//     final double? priceSearchValue = double.tryParse(queryText);
//     bool isNumericSearch = priceSearchValue != null;
//
//     if (selectedCategory != 'Popular') {
//       collectionRef = collectionRef.where(
//         'category',
//         isEqualTo: selectedCategory,
//       );
//     }
//
//     if (queryText.isNotEmpty) {
//       if (isNumericSearch) {
//         collectionRef = collectionRef.where(
//           'price',
//           isEqualTo: priceSearchValue,
//         );
//       } else {
//         // Text-based search (title)
//         collectionRef = collectionRef
//             .orderBy('title_lower')
//             .where('title_lower', isGreaterThanOrEqualTo: queryText)
//             .where('title_lower', isLessThanOrEqualTo: queryText + '\uf8ff');
//       }
//     } else {
//       collectionRef = collectionRef.orderBy('price');
//     }
//
//     return collectionRef.snapshots();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           // Banner Ad at the top
//           if (_isBannerAdReady && _bannerAd != null)
//             Container(
//               alignment: Alignment.center,
//               width: _bannerAd!.size.width.toDouble(),
//               height: _bannerAd!.size.height.toDouble(),
//               child: AdWidget(ad: _bannerAd!),
//             ),
//
//           // Main content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Center(
//                     child: RichText(
//                       text: TextSpan(
//                         style: const TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w800,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: "Feel ",
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.tertiary,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "Hungry\n",
//                             style: TextStyle(color: Theme.of(context).primaryColor),
//                           ),
//                           TextSpan(
//                             text: "Order now",
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.tertiary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: "Search any recipe or price",
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() => _searchQuery = '');
//                           FocusScope.of(context).unfocus();
//                         },
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text("Categories", style: Theme.of(context).textTheme.titleMedium),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 80,
//                     child: SizedBox(
//                       height: 70,
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: categories.length,
//                         separatorBuilder:
//                             (context, index) => const SizedBox(width: 8),
//                         itemBuilder: (context, index) {
//                           final category = categories[index]['name'];
//                           final icon = categories[index]['icon'] as IconData;
//                           final isSelected = category == selectedCategory;
//
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedCategory = category;
//                                 _searchController.clear();
//                                 _searchQuery = '';
//                               });
//                             },
//                             child: Container(
//                               width: 80,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: BoxDecoration(
//                                 color:
//                                 isSelected
//                                     ? Theme.of(context).colorScheme.primary
//                                     : Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     icon,
//                                     size: 25,
//                                     color: isSelected ? Colors.white : Colors.black,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     category,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: isSelected ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: StreamBuilder<QuerySnapshot>(
//                       stream: getProductsStream(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting &&
//                             !snapshot.hasData) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//
//                         if (snapshot.hasError) {
//                           return Center(child: Text('Error: ${snapshot.error}'));
//                         }
//
//                         final products = snapshot.data?.docs ?? [];
//
//                         if (products.isEmpty) {
//                           return Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.search_off,
//                                   size: 64,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   'No products found for "$_searchQuery"',
//                                   style: const TextStyle(color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//
//                         return GridView.builder(
//                           padding: const EdgeInsets.only(bottom: 14),
//                           gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 18,
//                             childAspectRatio: 0.68,
//                           ),
//                           itemCount: products.length,
//                           itemBuilder: (context, index) {
//                             final productId = products[index].id;
//                             final product = Product.fromFirestore(products[index]);
//                             final title = product.title;
//                             final query = _searchQuery.toLowerCase();
//                             final matchIndex = title.toLowerCase().indexOf(query);
//
//                             final baseStyle = Theme.of(
//                               context,
//                             ).textTheme.bodyMedium!.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: Theme.of(context).colorScheme.tertiary,
//                             );
//
//                             final TextStyle highlightStyle = baseStyle.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).colorScheme.primary,
//                             );
//
//                             TextSpan styledTitle;
//                             if (matchIndex != -1 && query.isNotEmpty) {
//                               styledTitle = TextSpan(
//                                 style: baseStyle,
//                                 children: [
//                                   TextSpan(text: title.substring(0, matchIndex)),
//                                   TextSpan(
//                                     text: title.substring(
//                                       matchIndex,
//                                       matchIndex + query.length,
//                                     ),
//                                     style: highlightStyle,
//                                   ),
//                                   TextSpan(
//                                     text: title.substring(matchIndex + query.length),
//                                   ),
//                                 ],
//                               );
//                             } else {
//                               styledTitle = TextSpan(text: title, style: baseStyle);
//                             }
//
//                             return GestureDetector(
//                               onTap: () => _onProductTap(product),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).colorScheme.secondary,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Theme.of(context).colorScheme.tertiary,
//                                       blurRadius: 2,
//                                       offset: const Offset(3, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(10),
//                                         topRight: Radius.circular(10),
//                                       ),
//                                       child: AspectRatio(
//                                         aspectRatio: 1 / 1,
//                                         child: Image.network(
//                                           product.image ?? '',
//                                           fit: BoxFit.cover,
//                                           errorBuilder:
//                                               (context, error, stackTrace) =>
//                                           const Icon(
//                                             Icons.image_not_supported,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 8,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: RichText(
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               text: styledTitle,
//                                             ),
//                                           ),
//                                           GestureDetector(
//                                             onTap: () {
//                                               if (user != null) {
//                                                 wishlistIds.contains(productId)
//                                                     ? removeFromWishlist(productId)
//                                                     : addToWishlist(
//                                                   productId: productId,
//                                                   productData: product.toJson(),
//                                                 );
//                                               } else {
//                                                 ScaffoldMessenger.of(
//                                                   context,
//                                                 ).showSnackBar(
//                                                   const SnackBar(
//                                                     content: Text(
//                                                       'Please log in to add to wishlist.',
//                                                     ),
//                                                   ),
//                                                 );
//                                               }
//                                             },
//                                             child: Icon(
//                                               Icons.favorite,
//                                               size: 20,
//                                               color:
//                                               wishlistIds.contains(productId)
//                                                   ? Colors.red.shade900
//                                                   : Colors.grey[400],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 8,
//                                       ),
//                                       child: Text(
//                                         "Rs ${product.price}",
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w800,
//                                           color:
//                                           Theme.of(
//                                             context,
//                                           ).colorScheme.inversePrimary,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


=======
>>>>>>> 968df39 (reservation added)
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/product_model.dart';
import 'package:project/screens/product_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  // Scroll controller for sticky header
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // AdMob variables
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _productViewCount = 0;

  // Test Ad Unit IDs (replace with your real ad unit IDs for production)
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    fetchWishlist();
    ensureNotificationCollectionExists();
    _searchController.addListener(_onSearchChanged);

    // Add scroll listener for sticky header
    _scrollController.addListener(_onScroll);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);

    // Initialize ads
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    // Dispose ads
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show sticky header when scrolled past 200 pixels
    if (_scrollController.offset > 200 && !_showStickyHeader) {
      setState(() {
        _showStickyHeader = true;
      });
    } else if (_scrollController.offset <= 200 && _showStickyHeader) {
      setState(() {
        _showStickyHeader = false;
      });
    }
  }

  // Load Banner Ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setInterstitialAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Set Interstitial Ad Callbacks
  void _setInterstitialAdCallbacks() {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
    );
  }

  // Show Interstitial Ad
  void _showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  // Handle product tap with ad logic
  void _onProductTap(Product product) {
    _productViewCount++;
    if (_productViewCount % 2 == 0) {
      _showInterstitialAd();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Added to wishlist",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.heart_broken, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Removed from wishlist",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
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
        collectionRef = collectionRef
            .orderBy('title_lower')
            .where('title_lower', isGreaterThanOrEqualTo: queryText)
            .where('title_lower', isLessThanOrEqualTo: queryText + '\uf8ff');
      }
    } else {
      collectionRef = collectionRef.orderBy('price');
    }

    return collectionRef.snapshots();
  }

  // Build enhanced circular category list widget
  Widget _buildCategoryList({bool isSticky = false}) {
    return Container(
      height: 110, // Increased height to accommodate circular design
      color: isSticky ? Colors.white : Colors.transparent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fully circular container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [
                                  Colors.red.shade900,
                                  Colors.red.shade800,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : LinearGradient(
                                colors: [Colors.white, Colors.grey.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.red.shade900.withOpacity(0.3)
                                : Colors.grey.shade500,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isSelected
                                  ? Colors.red.shade900.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                          blurRadius: isSelected ? 15 : 10,
                          offset: Offset(0, isSelected ? 8 : 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 28,
                        color: isSelected ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category text with better positioning
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.red.shade900 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Column(
            children: [
              // Enhanced Banner Ad with beautiful gradient
              if (_isBannerAdReady && _bannerAd != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade100,
                        Colors.white,
                        Colors.purple.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                  children: [
                    TextSpan(
                      text: "Feel ",
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .tertiary,
                      ),
                    ),
                    TextSpan(
                      text: "Hungry\n",
                      style: TextStyle(color: Theme
                          .of(context)
                          .primaryColor),
                    ),
                    TextSpan(
                      text: "Order now",
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .tertiary,
                      ),
                    ),
                  ],
=======
                  child: SafeArea(
                    child: Container(
                      alignment: Alignment.center,
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
>>>>>>> 968df39 (reservation added)
                ),

<<<<<<< HEAD
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
            Text("Categories", style: Theme
                .of(context)
                .textTheme
                .titleMedium),
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
                              ? Theme
                              .of(context)
                              .colorScheme
                              .primary
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

                      final baseStyle = Theme
                          .of(
                        context,
                      )
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .tertiary,
                      );

                      final TextStyle highlightStyle = baseStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
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
                            color: Theme
                                .of(context)
                                .colorScheme
                                .secondary,
                            borderRadius: BorderRadius.circular(12),
                            // More squarish
                            boxShadow: [
                              BoxShadow(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .tertiary,
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
=======
              // Main scrollable content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Header section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                // Enhanced header with smaller "Feel Hungry" text
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.15),
                                        Colors.orange.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 24, // Reduced from 30
                                            fontWeight: FontWeight.w900,
                                            height: 1.3,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Feel ",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Hungry\n",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                shadows: [
                                                  Shadow(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    offset: const Offset(2, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Order now",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                fontSize: 20, // Reduced from 26
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Smaller search field
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Search any recipe or price",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14, // Reduced from 16
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        // Reduced from 15
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Theme.of(
                                                context,
                                              ).primaryColor.withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 20, // Reduced from 22
                                        ),
                                      ),
                                      suffixIcon:
                                          _searchQuery.isNotEmpty
                                              ? IconButton(
                                                icon: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey[600],
                                                    size: 16, // Reduced from 18
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(
                                                    () => _searchQuery = '',
                                                  );
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();
                                                },
                                              )
                                              : null,
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16, // Reduced from 20
                                            vertical: 14, // Reduced from 18
                                          ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Categories title with beautiful design
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Categories",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.6),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
>>>>>>> 968df39 (reservation added)
                                      ),
                                    ),
                                  ],
                                ),
<<<<<<< HEAD
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
                                    Theme
                                        .of(
                                      context,
                                    )
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                              ),
                            ],
=======

                                const SizedBox(height: 15),
                              ],
                            ),
>>>>>>> 968df39 (reservation added)
                          ),
                        ),

                        // Categories list
                        SliverToBoxAdapter(child: _buildCategoryList()),

                        const SliverToBoxAdapter(child: SizedBox(height: 25)),

                        // Products grid with enhanced design
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: StreamBuilder<QuerySnapshot>(
                            stream: getProductsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.1),
                                                Colors.transparent,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircularProgressIndicator(
                                            color:
                                                Theme.of(context).primaryColor,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Loading delicious items...',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red[400],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Oops! Something went wrong',
                                          style: TextStyle(
                                            color: Colors.red[400],
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            'Error: ${snapshot.error}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final products = snapshot.data?.docs ?? [];

                              if (products.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.grey.shade100,
                                                Colors.grey.shade50,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        Text(
                                          'No products found',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                          ),
                                          child: Text(
                                            _searchQuery.isNotEmpty
                                                ? 'Try searching for "$_searchQuery" with different keywords'
                                                : 'No items available in this category',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 18,
                                      mainAxisSpacing: 22,
                                      childAspectRatio: 0.78,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final productId = products[index].id;
                                  final product = Product.fromFirestore(
                                    products[index],
                                  );
                                  final title = product.title;
                                  final query = _searchQuery.toLowerCase();
                                  final matchIndex = title
                                      .toLowerCase()
                                      .indexOf(query);

                                  final baseStyle = Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize:
                                        12, // Reduced font size as requested
                                  );

                                  final TextStyle highlightStyle = baseStyle
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      );

                                  TextSpan styledTitle;
                                  if (matchIndex != -1 && query.isNotEmpty) {
                                    styledTitle = TextSpan(
                                      style: baseStyle,
                                      children: [
                                        TextSpan(
                                          text: title.substring(0, matchIndex),
                                        ),
                                        TextSpan(
                                          text: title.substring(
                                            matchIndex,
                                            matchIndex + query.length,
                                          ),
                                          style: highlightStyle,
                                        ),
                                        TextSpan(
                                          text: title.substring(
                                            matchIndex + query.length,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    styledTitle = TextSpan(
                                      text: title,
                                      style: baseStyle,
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () => _onProductTap(product),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.grey.shade50,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                          BoxShadow(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Enhanced image container
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        25,
                                                      ),
                                                      topRight: Radius.circular(
                                                        25,
                                                      ),
                                                    ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade100,
                                                    Colors.grey.shade50,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        25,
                                                      ),
                                                      topRight: Radius.circular(
                                                        25,
                                                      ),
                                                    ),
                                                child: Stack(
                                                  children: [
                                                    Image.network(
                                                      product.image ?? '',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                                  Colors
                                                                      .grey
                                                                      .shade100,
                                                                ],
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size: 45,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                    ),
                                                    // Beautiful gradient overlay
                                                    Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors.black
                                                                  .withOpacity(
                                                                    0.15,
                                                                  ),
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topCenter,
                                                            end:
                                                                Alignment
                                                                    .bottomCenter,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Enhanced content section
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Title and wishlist row
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: RichText(
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          text: styledTitle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (user != null) {
                                                            wishlistIds
                                                                    .contains(
                                                                      productId,
                                                                    )
                                                                ? removeFromWishlist(
                                                                  productId,
                                                                )
                                                                : addToWishlist(
                                                                  productId:
                                                                      productId,
                                                                  productData:
                                                                      product
                                                                          .toJson(),
                                                                );
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .login,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    const Text(
                                                                      'Please log in to add to wishlist.',
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange
                                                                        .shade600,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                margin:
                                                                    const EdgeInsets.all(
                                                                      16,
                                                                    ),
                                                                elevation: 6,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                wishlistIds.contains(
                                                                      productId,
                                                                    )
                                                                    ? LinearGradient(
                                                                      colors: [
                                                                        Colors
                                                                            .red
                                                                            .shade100,
                                                                        Colors
                                                                            .red
                                                                            .shade50,
                                                                      ],
                                                                    )
                                                                    : LinearGradient(
                                                                      colors: [
                                                                        Colors
                                                                            .grey
                                                                            .shade100,
                                                                        Colors
                                                                            .grey
                                                                            .shade50,
                                                                      ],
                                                                    ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            wishlistIds
                                                                    .contains(
                                                                      productId,
                                                                    )
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            size: 15,
                                                            color:
                                                                wishlistIds.contains(
                                                                      productId,
                                                                    )
                                                                    ? Colors
                                                                        .red
                                                                        .shade700
                                                                    : Colors
                                                                        .grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const Spacer(),

                                                  // Enhanced price section with red shade 900 as requested
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 9,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.red.shade900
                                                              .withOpacity(0.1),
                                                          Colors.red.shade800
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .red
                                                            .shade900
                                                            .withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Rs ${product.price}",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            Colors
                                                                .red
                                                                .shade900, // Changed to red shade 900 as requested
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }, childCount: products.length),
                              );
                            },
                          ),
                        ),

                        // Bottom padding
                        const SliverToBoxAdapter(child: SizedBox(height: 30)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Enhanced Sticky Categories Header
          if (_showStickyHeader)
            Positioned(
              top:
                  _isBannerAdReady
                      ? (_bannerAd?.size.height.toDouble() ?? 0) +
                          MediaQuery.of(context).padding.top
                      : MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 15,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Categories",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCategoryList(isSticky: true),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
