import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Controllers for text fields
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // State variables for individual field editing
  bool _isEditingDescription = false;
  bool _isEditingTimings = false;
  bool _isEditingAddress = false;
  bool _isEditingPhone = false;

  bool _isLoading = true;
  bool _isSaving = false;
  List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Default/saved data
  String _savedDescription = '';
  String _savedAddress = '';
  String _savedPhone = '';

  // Timing slots
  List<TimingSlot> _timingSlots = [];
  List<TimingSlot> _savedTimingSlots = [];

  String? shopId;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        shopId = userData?['shopId'] as String?;

        if (shopId != null) {
          DocumentSnapshot shopDoc = await FirebaseFirestore.instance
              .collection('shops')
              .doc(shopId)
              .get();

          if (shopDoc.exists) {
            Map<String, dynamic> data = shopDoc.data() as Map<String, dynamic>;

            setState(() {
              // Load gallery
              if (data['gallery'] != null) {
                _existingImageUrls = List<String>.from(data['gallery']);
              }

              // Load description
              _savedDescription = data['description'] ?? '';
              _descriptionController.text = _savedDescription;

              // Load timings
              if (data['timings'] != null && data['timings'] is List) {
                _savedTimingSlots = (data['timings'] as List)
                    .map((slot) => TimingSlot.fromMap(slot))
                    .toList();
                _timingSlots = _savedTimingSlots
                    .map((slot) => TimingSlot.copy(slot))
                    .toList();
              }

              // Load external address
              _savedAddress = data['externalAddress'] ?? '';
              _addressController.text = _savedAddress;

              // Load phone number
              _savedPhone = data['phoneNumber'] ?? '';
              _phoneController.text = _savedPhone;

              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading shop data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _newImages.add(File(image.path));
        });

        // Automatically save when new image is added
        await _saveGalleryOnly();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _removeNewImage(int index) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Image'),
          content: Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _newImages.removeAt(index);
      });
    }
  }

  void _removeExistingImage(int index) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Image'),
          content: Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _existingImageUrls.removeAt(index);
      });

      // Automatically save the gallery update
      await _saveGalleryOnly();
    }
  }

  void _addTimingSlot() {
    setState(() {
      _timingSlots.add(
        TimingSlot(
          startDay: 'Monday',
          endDay: 'Monday',
          startTime: TimeOfDay(hour: 9, minute: 0),
          endTime: TimeOfDay(hour: 17, minute: 0),
        ),
      );
    });
  }

  void _removeTimingSlot(int index) {
    setState(() {
      _timingSlots.removeAt(index);
    });
  }

  void _toggleDescriptionEdit() {
    setState(() {
      if (_isEditingDescription) {
        // Cancel editing - restore saved value
        _descriptionController.text = _savedDescription;
      }
      _isEditingDescription = !_isEditingDescription;
    });
  }

  void _toggleTimingsEdit() {
    setState(() {
      if (_isEditingTimings) {
        // Cancel editing - restore saved values
        _timingSlots = _savedTimingSlots
            .map((slot) => TimingSlot.copy(slot))
            .toList();
      }
      _isEditingTimings = !_isEditingTimings;
    });
  }

  void _toggleAddressEdit() {
    setState(() {
      if (_isEditingAddress) {
        // Cancel editing - restore saved value
        _addressController.text = _savedAddress;
      }
      _isEditingAddress = !_isEditingAddress;
    });
  }

  void _togglePhoneEdit() {
    setState(() {
      if (_isEditingPhone) {
        // Cancel editing - restore saved value
        _phoneController.text = _savedPhone;
      }
      _isEditingPhone = !_isEditingPhone;
    });
  }

  Future<void> _saveGalleryOnly() async {
    if (shopId == null) return;

    try {
      List<String> galleryUrls = List.from(_existingImageUrls);

      // Upload new images to Firebase Storage
      for (File imageFile in _newImages) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop_gallery')
            .child(shopId!)
            .child(fileName);

        await ref.putFile(imageFile);
        String downloadUrl = await ref.getDownloadURL();
        galleryUrls.add(downloadUrl);
      }

      // Update only gallery in Firestore
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'gallery': galleryUrls,
      });

      setState(() {
        _existingImageUrls = galleryUrls;
        _newImages.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      if (shopId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Shop ID not found')));
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        List<String> galleryUrls = List.from(_existingImageUrls);

        // Upload new images to Firebase Storage
        for (File imageFile in _newImages) {
          String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = FirebaseStorage.instance
              .ref()
              .child('shop_gallery')
              .child(shopId!)
              .child(fileName);

          await ref.putFile(imageFile);
          String downloadUrl = await ref.getDownloadURL();
          galleryUrls.add(downloadUrl);
        }

        // Convert timing slots to map
        List<Map<String, dynamic>> timingsData = _timingSlots
            .map((slot) => slot.toMap())
            .toList();

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('shops')
            .doc(shopId)
            .update({
              'gallery': galleryUrls,
              'description': _descriptionController.text,
              'timings': timingsData,
              'externalAddress': _addressController.text,
              'phoneNumber': _phoneController.text,
            });

        setState(() {
          _savedDescription = _descriptionController.text;
          _savedAddress = _addressController.text;
          _savedPhone = _phoneController.text;
          _savedTimingSlots = _timingSlots
              .map((slot) => TimingSlot.copy(slot))
              .toList();
          _existingImageUrls = galleryUrls;
          _newImages.clear();
          _isEditingDescription = false;
          _isEditingTimings = false;
          _isEditingAddress = false;
          _isEditingPhone = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving data: $e');
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return digitsOnly;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Remove all non-digit characters except +
    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it starts with + and has at least 10 digits
    if (cleaned.startsWith('+')) {
      if (cleaned.length < 11 || cleaned.length > 16) {
        return 'Phone number should be between 10-15 digits';
      }
    } else {
      if (cleaned.length < 10 || cleaned.length > 15) {
        return 'Phone number should be between 10-15 digits';
      }
    }

    // Check if it contains only digits and optionally a + at the start
    if (!RegExp(r'^\+?\d+$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  Widget _buildImageGallery() {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._existingImageUrls.asMap().entries.map((entry) {
            int index = entry.key;
            String imageUrl = entry.value;
            return Container(
              margin: EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  // Always show delete button in gray
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeExistingImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          ..._newImages.asMap().entries.map((entry) {
            int index = entry.key;
            File image = entry.value;
            return Container(
              margin: EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Always show delete button in gray
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeNewImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/add_image_icon.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Add Images',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSlots() {
    if (!_isEditingTimings && _savedTimingSlots.isEmpty) {
      return Text(
        'No timings added',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      );
    }

    List<TimingSlot> displaySlots = _isEditingTimings
        ? _timingSlots
        : _savedTimingSlots;

    return Column(
      children: [
        ...displaySlots.asMap().entries.map((entry) {
          int index = entry.key;
          TimingSlot slot = entry.value;
          return _buildTimingSlotCard(slot, index);
        }).toList(),
        if (_isEditingTimings)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addTimingSlot,
              icon: Icon(Icons.add, color: Color(0xFF305CDE)),
              label: Text(
                'Add Timing Slot',
                style: TextStyle(color: Color(0xFF305CDE)),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF305CDE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimingSlotCard(TimingSlot slot, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
              SizedBox(width: 8),
              Expanded(
                child: _isEditingTimings
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildDayDropdown('From', slot.startDay, (
                              value,
                            ) {
                              setState(() {
                                slot.startDay = value!;
                              });
                            }),
                          ),
                          SizedBox(width: 8),
                          Text('to', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildDayDropdown('To', slot.endDay, (
                              value,
                            ) {
                              setState(() {
                                slot.endDay = value!;
                              });
                            }),
                          ),
                        ],
                      )
                    : Text(
                        '${slot.startDay} - ${slot.endDay}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              if (_isEditingTimings)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeTimingSlot(index),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
              SizedBox(width: 8),
              Expanded(
                child: _isEditingTimings
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector('Start', slot.startTime, (
                              time,
                            ) {
                              setState(() {
                                slot.startTime = time;
                              });
                            }),
                          ),
                          SizedBox(width: 8),
                          Text('to', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeSelector('End', slot.endTime, (
                              time,
                            ) {
                              setState(() {
                                slot.endTime = time;
                              });
                            }),
                          ),
                        ],
                      )
                    : Text(
                        '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                        style: TextStyle(fontSize: 14),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        isDense: true,
      ),
      items: days.map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(day, style: TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time.format(context), style: TextStyle(fontSize: 13)),
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String value,
    IconData icon,
    TextEditingController controller,
    bool isEditing,
    VoidCallback onToggleEdit, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                if (isEditing)
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: title == 'Phone Number'
                        ? [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d+\s\-()]'),
                            ),
                          ]
                        : null,
                    decoration: InputDecoration(
                      hintText: hint ?? 'Enter $title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    validator: title == 'Phone Number'
                        ? _validatePhoneNumber
                        : null,
                  )
                else
                  Text(
                    value.isEmpty ? 'No $title added' : value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value.isEmpty ? Colors.grey[600] : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          if (!isEditing)
            GestureDetector(
              onTap: onToggleEdit,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, color: Colors.grey[600], size: 20),
              ),
            ),
          if (isEditing && (title == 'Address' || title == 'Phone Number'))
            Container(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: title == 'Address'
                    ? Colors.blue
                    : Colors.green,
                child: Icon(icon, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  bool get _isAnyFieldEditing {
    return _isEditingDescription ||
        _isEditingTimings ||
        _isEditingAddress ||
        _isEditingPhone;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gallery Section
              Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              _buildImageGallery(),
              SizedBox(height: 10),

              // Description Section
              Row(
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  Spacer(),
                  if (!_isEditingDescription)
                    GestureDetector(
                      onTap: _toggleDescriptionEdit,
                      child: Icon(
                        Icons.edit,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              if (_isEditingDescription)
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your description here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                )
              else
                Text(
                  _savedDescription.isEmpty
                      ? 'Write your description here'
                      : _savedDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: _savedDescription.isEmpty
                        ? Colors.grey[600]
                        : Colors.black54,
                  ),
                ),
              SizedBox(height: 15),

              // Information Section
              Text(
                'Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              // Timings Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Timings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        if (!_isEditingTimings)
                          GestureDetector(
                            onTap: _toggleTimingsEdit,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildTimingSlots(),
                  ],
                ),
              ),

              _buildInfoSection(
                'Address',
                _savedAddress,
                Icons.location_on,
                _addressController,
                _isEditingAddress,
                _toggleAddressEdit,
                hint: 'Enter external address (optional)',
              ),
              _buildInfoSection(
                'Phone Number',
                _savedPhone,
                Icons.phone,
                _phoneController,
                _isEditingPhone,
                _togglePhoneEdit,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),

              // Save Button - Only show when editing
              if (_isAnyFieldEditing)
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF305CDE),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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

// TimingSlot class to manage timing data
class TimingSlot {
  String startDay;
  String endDay;
  TimeOfDay startTime;
  TimeOfDay endTime;

  TimingSlot({
    required this.startDay,
    required this.endDay,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDay': startDay,
      'endDay': endDay,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
    };
  }

  factory TimingSlot.fromMap(Map<String, dynamic> map) {
    List<String> startTimeParts = map['startTime'].toString().split(':');
    List<String> endTimeParts = map['endTime'].toString().split(':');

    return TimingSlot(
      startDay: map['startDay'] ?? 'Monday',
      endDay: map['endDay'] ?? 'Monday',
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
    );
  }

  factory TimingSlot.copy(TimingSlot other) {
    return TimingSlot(
      startDay: other.startDay,
      endDay: other.endDay,
      startTime: other.startTime,
      endTime: other.endTime,
    );
  }
}
