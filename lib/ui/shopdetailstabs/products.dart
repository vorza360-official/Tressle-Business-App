import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String? shopId;
  bool isLoading = true;
  String _selectedFilter = 'Shampoo';
  String _searchQuery = '';

  final List<String> _filters = ['Shampoo', 'Serum', 'Makeup', 'Hair Gel'];

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          shopId = userDoc.get('shopId') as String?;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading shop ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'PKR':
        return 'Rs ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'GBP':
        return '£ ';
      default:
        return 'Rs ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (shopId == null) {
      return Center(child: Text('Shop ID not found'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyState();
        }

        List<dynamic> productIds = snapshot.data!.get('products') ?? [];

        return Column(
          children: [
            // Search and filters
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type to search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = filter == _selectedFilter;
                        return Container(
                          margin: EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.blue[50],
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[600],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Products grid
            Expanded(
              child: productIds.isEmpty
                  ? _buildEmptyState()
                  : _buildProductsGrid(productIds),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Products Added',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductScreen(),
            icon: Icon(Icons.add),
            label: Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<dynamic> productIds) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where(
            FieldPath.documentId,
            whereIn: productIds.isEmpty ? ['dummy'] : productIds,
          )
          .snapshots(),
      builder: (context, productsSnapshot) {
        if (!productsSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var products = productsSnapshot.data!.docs;

        // Filter by type and search query
        var filteredProducts = products.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          bool matchesType = data['type'] == _selectedFilter;
          bool matchesSearch =
              _searchQuery.isEmpty ||
              (data['name'] as String).toLowerCase().contains(_searchQuery);
          return matchesType && matchesSearch;
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredProducts.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            if (index == filteredProducts.length) {
              return _buildAddProductCard();
            }

            var productDoc = filteredProducts[index];
            var productData = productDoc.data() as Map<String, dynamic>;
            return _buildProductCard(productDoc.id, productData);
          },
        );
      },
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> product) {
    String currency = product['currency'] ?? 'PKR';
    String currencySymbol = _getCurrencySymbol(currency);

    return GestureDetector(
      onTap: () {
        // Navigate to edit product screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductScreen(
              shopId: shopId!,
              productId: productId,
              productData: product,
            ),
          ),
        );
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child:
                    product['images'] != null &&
                        (product['images'] as List).isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product['images'][0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product['type'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Spacer(),
                    Text(
                      '$currencySymbol${product['price']?.toStringAsFixed(0) ?? '0'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 15,
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
  }

  Widget _buildAddProductCard() {
    return GestureDetector(
      onTap: () => _showAddProductScreen(),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 40, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('Add Product', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(shopId: shopId!),
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final String shopId;
  final String? productId; // If provided, we're editing
  final Map<String, dynamic>? productData;

  const AddProductScreen({
    Key? key,
    required this.shopId,
    this.productId,
    this.productData,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Shampoo';
  String _selectedCurrency = 'PKR';
  final List<String> _productTypes = ['Shampoo', 'Serum', 'Makeup', 'Hair Gel'];
  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP'];
  List<File?> _newImages = [null, null];
  List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final data = widget.productData!;
    _nameController.text = data['name'] ?? '';
    _priceController.text = data['price']?.toString() ?? '';
    _descriptionController.text = data['description'] ?? '';
    _selectedType = data['type'] ?? 'Shampoo';
    _selectedCurrency = data['currency'] ?? 'PKR';
    if (data['images'] != null) {
      _existingImageUrls = List<String>.from(data['images']);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.productId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteProduct,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Pictures
              Text(
                'Product Pictures',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildImageContainer(0)),
                  SizedBox(width: 16),
                  Expanded(child: _buildImageContainer(1)),
                ],
              ),
              SizedBox(height: 32),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Product Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Product Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              SizedBox(height: 20),

              // Price and Currency Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Product Price',
                        hintText: 'Enter price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCurrency = value!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your product here',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildImageContainer(int index) {
    // Check if we have an existing image at this index
    bool hasExistingImage = index < _existingImageUrls.length;
    bool hasNewImage = _newImages[index] != null;

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: hasNewImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(_newImages[index]!, fit: BoxFit.cover),
              )
            : (hasExistingImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        _existingImageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add Images',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
      ),
    );
  }

  Future<void> _pickImage(int index) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _getImage(ImageSource.gallery, index);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera, index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source, int index) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _newImages[index] = File(image.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      List<String> imageUrls = List.from(_existingImageUrls);

      // Upload new images
      for (int i = 0; i < _newImages.length; i++) {
        if (_newImages[i] != null) {
          String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final ref = FirebaseStorage.instance
              .ref()
              .child('product_images')
              .child(widget.shopId)
              .child(fileName);

          await ref.putFile(_newImages[i]!);
          String downloadUrl = await ref.getDownloadURL();

          // Replace or add to the list
          if (i < imageUrls.length) {
            imageUrls[i] = downloadUrl;
          } else {
            imageUrls.add(downloadUrl);
          }
        }
      }

      Map<String, dynamic> productData = {
        'name': _nameController.text,
        'type': _selectedType,
        'price': double.parse(_priceController.text),
        'currency': _selectedCurrency,
        'description': _descriptionController.text,
        'images': imageUrls,
        'shopId': widget.shopId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.productId != null) {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new product
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('products')
            .add({...productData, 'createdAt': FieldValue.serverTimestamp()});

        // Add product ID to shop's products array
        await FirebaseFirestore.instance
            .collection('shops')
            .doc(widget.shopId)
            .update({
              'products': FieldValue.arrayUnion([docRef.id]),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error saving product: $e');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProduct() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.productId != null) {
      try {
        // Remove from products array in shop document
        await FirebaseFirestore.instance
            .collection('shops')
            .doc(widget.shopId)
            .update({
              'products': FieldValue.arrayRemove([widget.productId]),
            });

        // Delete product document
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error deleting product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
