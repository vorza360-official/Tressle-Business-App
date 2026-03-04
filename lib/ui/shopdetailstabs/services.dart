import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicesTab extends StatefulWidget {
  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  String? shopId;
  bool isLoading = true;
  List<Map<String, dynamic>> categories = [];

  final List<String> currencies = ['PKR', 'USD', 'EUR', 'GBP', 'AED'];

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
        if (shopId != null) {
          _loadCategories();
        }
      }
    } catch (e) {
      print('Error loading shop ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      DocumentSnapshot shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .get();

      if (shopDoc.exists) {
        var data = shopDoc.data() as Map<String, dynamic>;
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['services'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _addCategory(String name) async {
    try {
      final newCategory = {'categoryName': name, 'services': []};
      categories.add(newCategory);
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'services': categories,
      });
      await _loadCategories();
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> _renameCategory(int index, String newName) async {
    try {
      categories[index]['categoryName'] = newName;
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'services': categories,
      });
      await _loadCategories();
    } catch (e) {
      print('Error renaming category: $e');
    }
  }

  Future<void> _deleteCategory(int index) async {
    try {
      final serviceIds = List<String>.from(categories[index]['services'] ?? []);
      for (String id in serviceIds) {
        await FirebaseFirestore.instance.collection('services').doc(id).delete();
      }
      categories.removeAt(index);
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'services': categories,
      });
      await _loadCategories();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  Future<void> _addService({
    required int categoryIndex,
    required String name,
    required double price,
    required String duration,
    required String currency,
  }) async {
    try {
      DocumentReference serviceRef = await FirebaseFirestore.instance.collection('services').add({
        'name': name,
        'price': price,
        'duration': duration,
        'currency': currency,
      });
      categories[categoryIndex]['services'].add(serviceRef.id);
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'services': categories,
      });
      await _loadCategories();
    } catch (e) {
      print('Error adding service: $e');
    }
  }

  Future<void> _deleteService(String serviceId, int categoryIndex) async {
    try {
      categories[categoryIndex]['services'].remove(serviceId);
      await FirebaseFirestore.instance.collection('services').doc(serviceId).delete();
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'services': categories,
      });
      await _loadCategories();
    } catch (e) {
      print('Error deleting service: $e');
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

    return Column(
      children: [
        // Category management section
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCategoryButton(),
              SizedBox(height: 12),
              _buildEditCategoryButton(),
            ],
          ),
        ),

        // Services list
        Expanded(
          child: categories.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategorySection(category, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Categories Added',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Add a category to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset("assets/icons/category_icon.png", width: 30, height: 30),
          SizedBox(width: 12),
          Expanded(child: Text('Category')),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: categories.length >= 20
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Maximum 20 categories allowed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                : () => _showAddCategoryDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCategoryButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset("assets/icons/category_icon.png", width: 30, height: 30),
          SizedBox(width: 12),
          Expanded(child: Text('Edit Category')),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: categories.isEmpty
                ? null
                : () => _showEditCategoriesDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category, int categoryIndex) {
    List<dynamic> serviceIds = category['services'] ?? [];

    return StreamBuilder<QuerySnapshot>(
      stream: serviceIds.isEmpty
          ? null
          : FirebaseFirestore.instance
              .collection('services')
              .where(FieldPath.documentId, whereIn: serviceIds.isEmpty ? ['dummy'] : serviceIds)
              .snapshots(),
      builder: (context, snapshot) {
        List<DocumentSnapshot> services = [];
        if (snapshot.hasData) {
          services = snapshot.data!.docs;
        }

        return Column(
          children: [
            Divider(color: Colors.grey,),
            ExpansionTile(
              title: Text(
                category['categoryName'] ?? '',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              initiallyExpanded: false,
              children: [
                ...services.map((serviceDoc) {
                  var serviceData = serviceDoc.data() as Map<String, dynamic>;
                  return _buildServiceTile(serviceDoc.id, serviceData, categoryIndex);
                }).toList(),
                if (services.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No services in this category',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ListTile(
                  leading: Icon(Icons.add, color: Colors.blue),
                  title: Text('Add Service', style: TextStyle(color: Colors.blue)),
                  onTap: serviceIds.length >= 30
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Maximum 30 services per category'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      : () => _showAddServiceDialog(categoryIndex: categoryIndex),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceTile(String serviceId, Map<String, dynamic> service, int categoryIndex) {
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1,color: Colors.grey)
      ),
      child: ListTile(
        title: Text(service['name'] ?? ''),
        subtitle: Text('Duration: ${service['duration'] ?? ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${service['currency'] ?? 'PKR'} ${service['price']?.toStringAsFixed(0) ?? '0'}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _showEditServiceDialog(
                serviceId: serviceId,
                serviceData: service,
                categoryIndex: categoryIndex,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteService(serviceId, categoryIndex),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_categoryController.text.isNotEmpty) {
                          await _addCategory(_categoryController.text);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category['categoryName'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                              _showRenameCategoryDialog(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteCategory(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameCategoryDialog(int categoryIndex) {
    final _categoryController = TextEditingController(
      text: categories[categoryIndex]['categoryName'],
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rename Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_categoryController.text.isNotEmpty) {
                          await _renameCategory(categoryIndex, _categoryController.text);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddServiceDialog({required int categoryIndex}) {
    final _serviceNameController = TextEditingController();
    final _servicePriceController = TextEditingController();
    final _serviceDurationController = TextEditingController();
    String _selectedCurrency = 'PKR';
    String categoryName = categories[categoryIndex]['categoryName'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Service',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Category Section
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Service Name
                  Text(
                    'Service Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _serviceNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter service name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Price and Currency Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _servicePriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currency',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Duration
                  Text(
                    'Duration (minutes)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _serviceDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '30',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_serviceNameController.text.isNotEmpty &&
                                _servicePriceController.text.isNotEmpty &&
                                _serviceDurationController.text.isNotEmpty) {
                              await _addService(
                                categoryIndex: categoryIndex,
                                name: _serviceNameController.text,
                                price: double.parse(_servicePriceController.text),
                                duration: '${_serviceDurationController.text} min',
                                currency: _selectedCurrency,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save Service',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog({
    required String serviceId,
    required Map<String, dynamic> serviceData,
    required int categoryIndex,
  }) {
    final _serviceNameController = TextEditingController(text: serviceData['name']);
    final _servicePriceController =
        TextEditingController(text: serviceData['price']?.toString() ?? '');
    final _serviceDurationController = TextEditingController(
        text: serviceData['duration']?.toString().replaceAll(' min', '') ?? '');
    String _selectedCurrency = serviceData['currency'] ?? 'PKR';
    String categoryName = categories[categoryIndex]['categoryName'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Service',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Category
                  Text('Category',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(categoryName,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700])),
                  ),
                  SizedBox(height: 20),

                  // Service Name
                  Text('Service Name',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  SizedBox(height: 8),
                  TextField(
                    controller: _serviceNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter service name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Price and Currency
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700])),
                            SizedBox(height: 8),
                            TextField(
                              controller: _servicePriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Currency',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700])),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: currencies.map((currency) {
                                return DropdownMenuItem(
                                    value: currency, child: Text(currency));
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() => _selectedCurrency = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Duration
                  Text('Duration (minutes)',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  SizedBox(height: 8),
                  TextField(
                    controller: _serviceDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '30',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_serviceNameController.text.isNotEmpty &&
                                _servicePriceController.text.isNotEmpty &&
                                _serviceDurationController.text.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('services')
                                  .doc(serviceId)
                                  .update({
                                'name': _serviceNameController.text,
                                'price': double.parse(_servicePriceController.text),
                                'currency': _selectedCurrency,
                                'duration': '${_serviceDurationController.text} min',
                              });
                              Navigator.pop(context);
                              await _loadCategories();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save Service',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}