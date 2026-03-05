import 'package:flutter/material.dart';
import 'package:tressle_business/ui/homeScreen.dart';
import 'package:tressle_business/ui/shopdetailstabs/about.dart';
import 'package:tressle_business/ui/shopdetailstabs/products.dart';
import 'package:tressle_business/ui/shopdetailstabs/services.dart';
import 'package:tressle_business/ui/shopdetailstabs/staff.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:tressle_business/services/auth_service.dart';

class ShopDetailsScreen extends StatefulWidget {
  @override
  _ShopDetailsScreenState createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String shopName = 'Razed Right';
  String shopAddress = 'Taganskaya Square, 86/1c1, ТЦ Атом, этаж 2';
  File? profileImage;
  String? shopImageUrl;
  String? shopId;

  double? latitude;
  double? longitude;

  bool isLoading = true;
  bool hasChanges = false;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _nameController.text = shopName;
    _loadShopData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('No user logged in');
        return;
      }

      // Step 1: Get user document
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        _showError('User profile not found');
        return;
      }

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      String? fetchedShopId = userData?['shopId'] as String?;

      // Step 2: If shopId missing → create one and save it
      if (fetchedShopId == null || fetchedShopId.isEmpty) {
        fetchedShopId = FirebaseFirestore.instance.collection('shops').doc().id;

        await userRef.update({
          'shopId': fetchedShopId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Also create empty shop document
        await _createEmptyShopDocument(fetchedShopId);
      }

      setState(() => shopId = fetchedShopId);

      // Step 3: Load shop document
      DocumentSnapshot shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .get();

      // If shop document doesn't exist (shouldn't happen after above), create it
      if (!shopSnapshot.exists) {
        await _createEmptyShopDocument(shopId!);
        shopSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .doc(shopId)
            .get();
      }

      Map<String, dynamic>? shopData =
          shopSnapshot.data() as Map<String, dynamic>?;

      if (shopData == null) {
        _showError('Failed to load shop data');
        return;
      }

      // Step 4: Safely extract fields with fallbacks and type checks
      setState(() {
        shopName = _safeString(shopData['shopName']) ?? 'My Shop';
        shopImageUrl = _safeString(shopData['shopImage']);
        shopAddress =
            _safeString(shopData['shopAddress']) ?? 'No Address added';
        latitude = shopData['latitude'] is num
            ? (shopData['latitude'] as num).toDouble()
            : null;
        longitude = shopData['longitude'] is num
            ? (shopData['longitude'] as num).toDouble()
            : null;

        _nameController.text = shopName;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _loadShopData: $e\n$stackTrace');
      _showError('Failed to load shop details. Please try again.');
    }
  }

  // Helper: Safe string extraction
  String? _safeString(dynamic value) {
    if (value is String) return value;
    if (value == null) return null;
    return value.toString(); // last resort
  }

  // Helper: Show error snackbar
  void _showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Create empty shop document if missing
  Future<void> _createEmptyShopDocument(String shopId) async {
    try {
      await FirebaseFirestore.instance.collection('shops').doc(shopId).set({
        'shopName': 'My Shop',
        'shopImage': null,
        'shopAddress': '',
        'latitude': null,
        'longitude': null,
        'gallery': <String>[],
        'description': '',
        'timings': {},
        'externalAddress': '',
        'phoneNumber': '',
        'services': <Map>[],
        'staff': <Map>[],
        'products': <Map>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to create shop document: $e');
    }
  }

  Future<void> _createShopDocument() async {
    if (shopId == null) return;

    try {
      await FirebaseFirestore.instance.collection('shops').doc(shopId).set({
        'shopName': shopName,
        'shopImage': null,
        'shopAddress': shopAddress,
        'latitude': null,
        'longitude': null,
        'gallery': [],
        'description': '',
        'timings': {},
        'externalAddress': '',
        'phoneNumber': '',
        'services': [],
        'staff': [],
        'products': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error creating shop document: $e');
    }
  }

  Future<void> _pickImage() async {
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
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        profileImage = File(image.path);
        hasChanges = true;
      });
    }
  }

  void _editShopName() {
    _nameController.text = shopName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Shop Name'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Shop Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  setState(() {
                    shopName = _nameController.text;
                    hasChanges = true;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editAddress() {
    _latController.clear();
    _lngController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Set Shop Location'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // Check location permission
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }

                          if (permission == LocationPermission.deniedForever) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Location permission denied permanently',
                                ),
                              ),
                            );
                            return;
                          }

                          // Get current location
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          // Get address from coordinates
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                position.latitude,
                                position.longitude,
                              );

                          if (placemarks.isNotEmpty) {
                            Placemark place = placemarks[0];
                            String address =
                                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';

                            setDialogState(() {
                              _latController.text = position.latitude
                                  .toString();
                              _lngController.text = position.longitude
                                  .toString();
                            });

                            setState(() {
                              latitude = position.latitude;
                              longitude = position.longitude;
                              shopAddress = address;
                            });
                          }
                        } catch (e) {
                          print('Error getting location: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to get location')),
                          );
                        }
                      },
                      icon: Icon(Icons.my_location),
                      label: Text('Use My Current Location'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 45),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Or enter coordinates manually:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _latController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 55.7558',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) async {
                        if (_latController.text.isNotEmpty &&
                            _lngController.text.isNotEmpty) {
                          try {
                            double lat = double.parse(_latController.text);
                            double lng = double.parse(_lngController.text);

                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(lat, lng);
                            if (placemarks.isNotEmpty) {
                              Placemark place = placemarks[0];
                              String address =
                                  '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';

                              setState(() {
                                latitude = lat;
                                longitude = lng;
                                shopAddress = address;
                              });
                            }
                          } catch (e) {
                            print('Error parsing coordinates: $e');
                          }
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _lngController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 37.6173',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) async {
                        if (_latController.text.isNotEmpty &&
                            _lngController.text.isNotEmpty) {
                          try {
                            double lat = double.parse(_latController.text);
                            double lng = double.parse(_lngController.text);

                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(lat, lng);
                            if (placemarks.isNotEmpty) {
                              Placemark place = placemarks[0];
                              String address =
                                  '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';

                              setState(() {
                                latitude = lat;
                                longitude = lng;
                                shopAddress = address;
                              });
                            }
                          } catch (e) {
                            print('Error parsing coordinates: $e');
                          }
                        }
                      },
                    ),
                    if (shopAddress.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(shopAddress),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (latitude != null && longitude != null) {
                      setState(() {
                        hasChanges = true;
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please set location first')),
                      );
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (shopId == null) return;

    setState(() => isLoading = true);

    try {
      String? imageUrl = shopImageUrl;

      if (profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop_images')
            .child('$shopId.jpg');

        await ref.putFile(profileImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'shopName': shopName.trim(),
        'shopImage': imageUrl,
        'shopAddress': shopAddress.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        shopImageUrl = imageUrl;
        profileImage = null;
        hasChanges = false;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop details saved successfully')),
      );
    } catch (e) {
      print('Save error: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        actions: [
          if (hasChanges)
            IconButton(
              onPressed: isLoading ? null : _saveChanges,
              icon: isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    )
                  : Icon(Icons.check, color: Colors.green),
            ),
          IconButton(
            icon: Icon(Icons.door_back_door, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header section
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: profileImage != null
                                    ? FileImage(profileImage!)
                                    : (shopImageUrl != null
                                          ? NetworkImage(shopImageUrl!)
                                                as ImageProvider
                                          : null),
                                child:
                                    (profileImage == null &&
                                        shopImageUrl == null)
                                    ? Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey[600],
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _editShopName,
                                  child: Text(
                                    shopName,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Admin',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey[600]),
                            onPressed: _editShopName,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _editAddress,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                shopAddress,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      // Tab bar
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey[600],
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: 'About'),
                            Tab(text: 'Services'),
                            Tab(text: 'Staff'),
                            Tab(text: 'Products'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AboutScreen(),
                      ServicesTab(),
                      StaffTab(previousScreen: "staffTab"),
                      ProductsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
