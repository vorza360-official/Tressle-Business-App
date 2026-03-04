import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tressle_business/ui/addEmployeeScreen.dart';
import 'package:tressle_business/ui/employeeProfilePortFolioScreen.dart'; // Import the portfolio screen

class StaffTab extends StatefulWidget {
  final String previousScreen;

  const StaffTab({super.key, required this.previousScreen});

  @override
  _StaffTabState createState() => _StaffTabState();
}

class _StaffTabState extends State<StaffTab> {
  String? shopId;
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (shopId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Shop ID not found')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: widget.previousScreen == 'staffTab'
                ? null
                : AppBar(title: Text("Add Employees")),
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: widget.previousScreen == 'staffTab'
                ? null
                : AppBar(title: Text("Add Employees")),
            backgroundColor: Colors.white,
            body: _buildEmptyState(),
          );
        }

        List<dynamic> staffIds = snapshot.data!.get('staff') ?? [];

        if (staffIds.isEmpty) {
          return Scaffold(
            appBar: widget.previousScreen == 'staffTab'
                ? null
                : AppBar(title: Text("Add Employees")),
            backgroundColor: Colors.white,
            body: _buildEmptyState(),
          );
        }

        return Scaffold(
          appBar: widget.previousScreen == 'staffTab'
              ? null
              : AppBar(title: Text("Add Employees")),
          backgroundColor: Colors.white,
          body: _buildEmployeeList(staffIds),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              "assets/icons/no_data_icon.png",
              width: 250,
              height: 250,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEmployeeScreen(shopId: shopId!),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeList(List<dynamic> staffIds) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: staffIds.length,
            itemBuilder: (context, index) {
              String employeeId = staffIds[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('employees')
                    .doc(employeeId)
                    .snapshots(),
                builder: (context, employeeSnapshot) {
                  if (!employeeSnapshot.hasData ||
                      !employeeSnapshot.data!.exists) {
                    return SizedBox.shrink();
                  }

                  Map<String, dynamic> employeeData =
                      employeeSnapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: employeeData['profileImageUrl'] != null
                            ? NetworkImage(employeeData['profileImageUrl'])
                            : null,
                        child: employeeData['profileImageUrl'] == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                      title: Text(employeeData['name'] ?? 'Unknown'),
                      subtitle: Text(employeeData['designation'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Navigate to edit screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEmployeeScreen(
                                    shopId: shopId!,
                                    employeeId: employeeId,
                                    employeeData: employeeData,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEmployee(employeeId),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to portfolio screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmployeePortfolioScreen(employeeId: employeeId),
                          ),
                        );
                      },
                    ),
                  );
                },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEmployeeScreen(shopId: shopId!),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteEmployee(String employeeId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete this employee?'),
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

    if (confirm == true) {
      try {
        // Remove from staff array in shop document
        await FirebaseFirestore.instance.collection('shops').doc(shopId).update(
          {
            'staff': FieldValue.arrayRemove([employeeId]),
          },
        );

        // Delete employee document
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting employee: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting employee'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
