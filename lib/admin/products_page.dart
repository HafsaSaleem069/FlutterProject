// lib/pages/products_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
  TextEditingController();
  final TextEditingController _productDetailController = TextEditingController();
  String _selectedCategory = 'Burger';

  late TabController _tabController;

  final List<String> _productCategories = [
    'Burger',
    'Desserts',
    'Coffee',
    'Traditionals',
    'Pizza',
  ];

  final List<String> _assetImages = [
    'assets/images/burgers.jpeg',
    'assets/images/pizzaa.jpeg',
    'assets/images/chips.jpeg',
    'assets/images/Choco hazelnut Dessert.jpeg',
    'assets/images/cocktail Appetizer.jpeg',
    'assets/images/donuts.jpeg',
    'assets/images/main course.jpeg',
    'assets/images/main course2.jpeg',
    'assets/images/mint.jpeg',
    'assets/images/shawarma.jpeg',
    'assets/images/paratha roll.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _productCategories.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _productDetailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    String? selectedImage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image from Assets'),
        content: DropdownButton<String>(
          isExpanded: true,
          value: _imageFile?.path ?? _assetImages.first,
          items: _assetImages.map((String assetPath) {
            return DropdownMenuItem<String>(
              value: assetPath,
              child: Text(assetPath.split('/').last),
            );
          }).toList(),
          onChanged: (String? value) {
            Navigator.of(context).pop(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedImage != null) {
      setState(() {
        _imageFile = XFile(selectedImage);
      });
    }
  }

  Future<void> _addProduct() async {
    final String productName = _productNameController.text.trim();
    final String productPriceText = _productPriceController.text.trim();
    final String productDescription = _productDescriptionController.text.trim();
    final String productDetail = _productDetailController.text.trim();

    if (_imageFile == null ||
        productName.isEmpty ||
        productPriceText.isEmpty ||
        productDescription.isEmpty ||
        productDetail.isEmpty ||
        _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image.'),
        ),
      );
      return;
    }

    double? productPrice;
    try {
      productPrice = double.parse(productPriceText);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for Price.')),
      );
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing price: ${e.toString()}')),
      );
      return;
    }

    try {
      final String imagePath = _imageFile!.path;

      await _firestore.collection('products').add({
        'title': productName,
        'title_lower': productName.toLowerCase(),
        'price': productPrice,
        'description': productDescription,
        'detail': productDetail,
        'image': imagePath,
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _productNameController.clear();
      _productPriceController.clear();
      _productDescriptionController.clear();
      _productDetailController.clear();
      setState(() {
        _imageFile = null;
        _selectedCategory = _productCategories.first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteProduct(String productId, String imageUrl) async {
    try {
      await _firestore.collection('products').doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: ${e.toString()}')),
      );
    }
  }

  Widget _buildProductTable(String? category) {
    Query query = _firestore.collection('products');
    if (category != null && category != 'All Products') {
      query = query.where('category', isEqualTo: category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(
            child: Text('No products found in this category.'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            headingTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            dataTextStyle: const TextStyle(fontSize: 13),
            dataRowHeight: 80,
            columns: const [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Detail')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              String imageUrl = data['image'] ?? '';

              return DataRow(
                cells: [
                  DataCell(
                    imageUrl.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                          );
                        },
                      ),
                    )
                        : const Icon(Icons.image_not_supported),
                  ),
                  DataCell(Text(data['title'] ?? 'N/A')),
                  DataCell(Text('Rs. ${data['price'] ?? '0'}')),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        data['description'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        data['detail'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  DataCell(Text(data['category'] ?? 'N/A')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(doc.id, imageUrl),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Product',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _productNameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _productPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _productDescriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _productDetailController,
                      decoration: const InputDecoration(labelText: 'Detail'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Menu Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _productCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select Image from Assets'),
                    ),
                    _imageFile != null
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        _imageFile!.path,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                          );
                        },
                      ),
                    )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('Add Product'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DefaultTabController(
                    length: _productCategories.length + 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabs: [
                            const Tab(text: 'All Products'),
                            ..._productCategories.map((cat) => Tab(text: cat)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: _buildProductTable('All Products'),
                              ),
                              ..._productCategories.map(
                                    (cat) => SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: _buildProductTable(cat),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
