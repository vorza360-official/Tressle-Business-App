import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tressle_business/models/EmployeeModel.dart';

// Main Employee Management Widget
class EmployeeManagement extends StatefulWidget {
  @override
  _EmployeeManagementState createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  List<Employee> employees = [];

  void addEmployee(Employee employee) {
    setState(() {
      employees.add(employee);
    });
  }

  void deleteEmployee(int index) {
    setState(() {
      employees.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: employees.isEmpty ? _buildEmptyState() : _buildEmployeeList(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Text(
          'Add Employee',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Center(
            child: Image.asset(
              "assets/icons/no_data_icon.png",
              width: 300,
              height: 300,
            ),
          ),
        ),
        Row(
          children: [
            Spacer(),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white, size: 30),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         AddEmployeeScreen(onEmployeeAdded: addEmployee),
                    //   ),
                    // );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: employee.profileImage != null
                        ? FileImage(employee.profileImage!)
                        : null,
                    child: employee.profileImage == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  title: Text(employee.name),
                  subtitle: Text(employee.designation),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteEmployee(index),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         AddEmployeeScreen(onEmployeeAdded: addEmployee),
                //   ),
                // );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Add Employee Screen

class AddEmployeeScreen extends StatefulWidget {
  final String shopId;
  final String? employeeId; // If provided, we're editing
  final Map<String, dynamic>? employeeData; // Existing data for editing

  AddEmployeeScreen({required this.shopId, this.employeeId, this.employeeData});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _joiningDateController = TextEditingController();

  String selectedDesignation = 'Barber';
  List<String> selectedWorkingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  Map<String, String> shiftStartTimes = {
    'Mon': '09:00 AM',
    'Tue': '09:00 AM',
    'Wed': '09:00 AM',
    'Thu': '09:00 AM',
    'Fri': '09:00 AM',
    'Sat': '09:00 AM',
    'Sun': '09:00 AM',
  };
  Map<String, String> shiftEndTimes = {
    'Mon': '06:00 PM',
    'Tue': '06:00 PM',
    'Wed': '06:00 PM',
    'Thu': '06:00 PM',
    'Fri': '06:00 PM',
    'Sat': '06:00 PM',
    'Sun': '06:00 PM',
  };
  File? _profileImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  final List<String> designations = [
    'Barber',
    'Manager',
    'Receptionist',
    'Trainee',
  ];

  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  // Portfolio items
  List<Map<String, dynamic>> portfolio =
      []; // {title: string, image: File? or url: string}

  @override
  void initState() {
    super.initState();
    if (widget.employeeData != null) {
      _loadEmployeeData();
    }
  }

  void _loadEmployeeData() {
    final data = widget.employeeData!;
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _joiningDateController.text = data['joiningDate'] ?? '';
    selectedDesignation = data['designation'] ?? 'Barber';

    // Load working days
    if (data['workingDays'] is String) {
      selectedWorkingDays = (data['workingDays'] as String).split(' ');
    } else if (data['workingDays'] is List) {
      selectedWorkingDays = List<String>.from(data['workingDays']);
    }

    // Load shift times
    if (data['shiftStartTimes'] is Map) {
      shiftStartTimes = Map<String, String>.from(data['shiftStartTimes']);
    }
    if (data['shiftEndTimes'] is Map) {
      shiftEndTimes = Map<String, String>.from(data['shiftEndTimes']);
    }

    _existingImageUrl = data['profileImageUrl'];
    portfolio = List.from(
      data['portfolio'] ?? [],
    ); // Assuming array of {title, imageUrl}
  }

  Future<void> _selectJoiningDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _joiningDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _addPortfolioItem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      TextEditingController titleController = TextEditingController();
      bool? saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Portfolio Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(image.path), height: 100),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title (Optional)',
                  hintText: 'Leave empty for auto-generated title',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Save'),
            ),
          ],
        ),
      );

      if (saved == true) {
        setState(() {
          String title = titleController.text.trim();
          if (title.isEmpty) {
            title = "Portfolio ${portfolio.length + 1}";
          }
          portfolio.add({'title': title, 'image': File(image.path)});
        });
      }
    }
  }

  void _editPortfolioItem(int index) async {
    Map<String, dynamic> item = portfolio[index];
    TextEditingController titleController = TextEditingController(
      text: item['title'],
    );
    File? newImage = item['image'] is File ? item['image'] : null;
    String? existingUrl = item['imageUrl'];

    bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Portfolio Item'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (newImage != null)
                Image.file(newImage!, height: 100)
              else if (existingUrl != null)
                Image.network(existingUrl, height: 100),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title (Optional)',
                  hintText: 'Leave empty for auto-generated title',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? img = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() {
                      newImage = File(img.path);
                    });
                  }
                },
                child: Text('Change Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        String title = titleController.text.trim();
        if (title.isEmpty) {
          title = "Portfolio ${index + 1}";
        }
        portfolio[index] = {
          'title': title,
          if (newImage != null) 'image': newImage,
          if (existingUrl != null && newImage == null) 'imageUrl': existingUrl,
        };
      });
    }
  }

  void _deletePortfolioItem(int index) {
    setState(() {
      portfolio.removeAt(index);
    });
  }

  void _showWorkingHoursDialog(String day) {
    String tempStart = shiftStartTimes[day]!;
    String tempEnd = shiftEndTimes[day]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Set Working Hours for $day'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shift Start
                  ListTile(
                    title: Text('Shift Start'),
                    subtitle: Text(tempStart),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _parseTime(tempStart),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempStart = _formatTime(picked);
                        });
                      }
                    },
                  ),
                  Divider(),
                  // Shift End
                  ListTile(
                    title: Text('Shift End'),
                    subtitle: Text(tempEnd),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _parseTime(tempEnd),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempEnd = _formatTime(picked);
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      shiftStartTimes[day] = tempStart;
                      shiftEndTimes[day] = tempEnd;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // Email validation function
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone validation function
  bool _isValidPhone(String phone) {
    // Basic phone validation - adjust regex as needed for your region
    return RegExp(r'^[\d\s\+\(\)\-]{10,}$').hasMatch(phone);
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        String? imageUrl = _existingImageUrl;

        // Upload profile image if new
        if (_profileImage != null) {
          String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = FirebaseStorage.instance
              .ref()
              .child('employee_images')
              .child(widget.shopId)
              .child(fileName);

          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        }

        // Handle portfolio uploads
        List<Map<String, String>> uploadedPortfolio = [];
        for (var item in portfolio) {
          String? itemImageUrl = item['imageUrl'];
          if (item['image'] is File) {
            String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
            final ref = FirebaseStorage.instance
                .ref()
                .child('employee_portfolio')
                .child(widget.shopId)
                .child(widget.employeeId ?? 'new')
                .child(fileName);
            await ref.putFile(item['image']);
            itemImageUrl = await ref.getDownloadURL();
          }
          uploadedPortfolio.add({
            'title': item['title'],
            'imageUrl': itemImageUrl ?? '',
          });
        }

        Map<String, dynamic> employeeData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'designation': selectedDesignation,
          'workingDays': selectedWorkingDays,
          'shiftStartTimes': shiftStartTimes,
          'shiftEndTimes': shiftEndTimes,
          'joiningDate': _joiningDateController.text,
          'profileImageUrl': imageUrl,
          'shopId': widget.shopId,
          'portfolio': uploadedPortfolio,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.employeeId != null) {
          // Update existing employee
          await FirebaseFirestore.instance
              .collection('employees')
              .doc(widget.employeeId)
              .update(employeeData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Create new employee with auto-generated ID
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('employees')
              .add({
                ...employeeData,
                'createdAt': FieldValue.serverTimestamp(),
              });

          // Add employee ID to shop's staff array
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(widget.shopId)
              .update({
                'staff': FieldValue.arrayUnion([docRef.id]),
              });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        print('Error saving employee: $e');
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.employeeId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                isEditing ? '  Edit Employee' : '  Add Employee',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: _profileImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (_existingImageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            child: Image.network(
                                              _existingImageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[600],
                                          )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 30),

                        // First field side by side with picture
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: _selectJoiningDate,
                                child: AbsorbPointer(
                                  child: _buildCompactTextField(
                                    'Joining Date',
                                    _joiningDateController,
                                    'Select date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    _buildCompactTextField(
                      'Full Name',
                      _nameController,
                      'Robert Collins',
                    ),

                    // Email with validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'example@email.com',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!_isValidEmail(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Phone with validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: '+92 000 0000000',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!_isValidPhone(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),

                    // Designation Dropdown
                    SizedBox(height: 16),
                    Text(
                      'Designation',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDesignation,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: designations.map((String designation) {
                        return DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDesignation = newValue!;
                        });
                      },
                    ),

                    SizedBox(height: 16),
                    Text(
                      'Working Days',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),

                    // Working Days Selection
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: weekDays.map((day) {
                        bool isSelected = selectedWorkingDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedWorkingDays.add(day);
                              } else {
                                selectedWorkingDays.remove(day);
                              }
                            });
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 16),

                    // Working Hours for Selected Days
                    if (selectedWorkingDays.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Working Hours',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          ...selectedWorkingDays.map((day) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Card(
                                child: ListTile(
                                  title: Text(day),
                                  subtitle: Text(
                                    '${shiftStartTimes[day]} - ${shiftEndTimes[day]}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _showWorkingHoursDialog(day),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),

                    SizedBox(height: 30),

                    // Portfolio Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Portfolio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addPortfolioItem,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (portfolio.isEmpty) Text('No portfolio items added'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: portfolio.length,
                      itemBuilder: (context, index) {
                        var item = portfolio[index];
                        return ListTile(
                          leading: item['image'] is File
                              ? Image.file(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : (item['imageUrl'] != null
                                    ? Image.network(
                                        item['imageUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.image)),
                          title: Text(item['title']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editPortfolioItem(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePortfolioItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 30),

                    // Save Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveEmployee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF305CDE),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField(
    String label,
    TextEditingController controller,
    String hint, {
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
            suffixIcon: suffixIcon,
          ),
          style: TextStyle(fontSize: 14),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }
}

// Working Hours Dialog
class WorkingHoursDialog extends StatefulWidget {
  final String currentShiftStart;
  final String currentShiftEnd;
  final Function(String, String) onSave;

  WorkingHoursDialog({
    required this.currentShiftStart,
    required this.currentShiftEnd,
    required this.onSave,
  });

  @override
  _WorkingHoursDialogState createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  late String shiftStart;
  late String shiftEnd;

  @override
  void initState() {
    super.initState();
    shiftStart = widget.currentShiftStart;
    shiftEnd = widget.currentShiftEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),

            // Date
            Text(
              'Monday, 22 June 2025',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            SizedBox(height: 20),

            // Shift Start and End in a row
            Row(
              children: [
                // Shift Start
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift Start',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shiftStart,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // Shift End
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift End',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shiftEnd,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Action buttons row
            Row(
              children: [
                // Delete button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),

                Spacer(),

                // Cancel button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Save button
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(shiftStart, shiftEnd);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF305CDE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
