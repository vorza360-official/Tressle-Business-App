import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'package:tressle_business/UI/emplyeeManagementScreen.dart';
import 'package:tressle_business/UI/loginScreen.dart';
import 'package:tressle_business/UI/notificationScreen.dart';
import 'package:tressle_business/UI/shopDetailScreen.dart';
import 'package:tressle_business/UI/shopReviewsScreen.dart';
import 'package:tressle_business/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? shopImageUrl;
  String? shopId;
  String? shopName;
  int totalBookings = 0;
  double totalIncome = 0.0;
  String selectedPeriod = 'Weekly';
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDoc.exists) return;

    shopId = userDoc['shopId'];
    if (shopId == null) return;

    DocumentSnapshot shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .get();
    if (!shopDoc.exists) return;

    setState(() {
      shopImageUrl = shopDoc['shopImage'];
      shopName = shopDoc['shopName'];
    });

    await fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    if (shopId == null) return;

    QuerySnapshot appts = await FirebaseFirestore.instance
        .collection('appointments')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: 'completed')
        .get();

    DateTime now = DateTime.now();
    DateTime startDate;
    if (selectedPeriod == 'Weekly') {
      startDate = now.subtract(Duration(days: 7));
    } else if (selectedPeriod == 'Monthly') {
      startDate = now.subtract(Duration(days: 30));
    } else {
      startDate = now.subtract(Duration(days: 365));
    }

    int count = 0;
    double income = 0.0;
    Map<DateTime, int> bookingsPerDay = {};

    for (var doc in appts.docs) {
      String apptDateStr = doc['appointmentDate'];
      DateTime apptDate;
      try {
        apptDate = DateTime.parse(apptDateStr);
      } catch (e) {
        continue;
      }

      if (apptDate.isAfter(startDate) || apptDate.isAtSameMomentAs(startDate)) {
        count++;
        income += (doc['grandTotal'] as num).toDouble();

        DateTime day = DateTime(apptDate.year, apptDate.month, apptDate.day);
        bookingsPerDay[day] = (bookingsPerDay[day] ?? 0) + 1;
      }
    }

    List<BarChartGroupData> groups = [];
    if (selectedPeriod == 'Weekly') {
      for (int i = 6; i >= 0; i--) {
        DateTime d = now.subtract(Duration(days: i));
        DateTime key = DateTime(d.year, d.month, d.day);
        int num = bookingsPerDay[key] ?? 0;
        groups.add(makeGroupData(6 - i, num.toDouble()));
      }
    } else if (selectedPeriod == 'Monthly') {
      DateTime start = now.subtract(Duration(days: 28));
      for (int w = 0; w < 4; w++) {
        int weekCount = 0;
        DateTime weekStart = start.add(Duration(days: w * 7));
        DateTime weekEnd = weekStart.add(Duration(days: 7));
        bookingsPerDay.forEach((date, cnt) {
          if (date.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
              date.isBefore(weekEnd)) {
            weekCount += cnt;
          }
        });
        groups.add(makeGroupData(w, weekCount.toDouble()));
      }
    } else {
      for (int m = 11; m >= 0; m--) {
        DateTime monthDate = DateTime(now.year, now.month - m, 1);
        int monthCount = 0;
        bookingsPerDay.forEach((date, cnt) {
          if (date.year == monthDate.year && date.month == monthDate.month) {
            monthCount += cnt;
          }
        });
        groups.add(makeGroupData(11 - m, monthCount.toDouble()));
      }
    }

    setState(() {
      totalBookings = count;
      totalIncome = income;
      barGroups = groups;
    });
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue.shade600,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      int index = value.toInt();
      DateTime now = DateTime.now();
      switch (selectedPeriod) {
        case 'Weekly':
          DateTime d = now.subtract(Duration(days: 6 - index));
          return Text('${d.day}/${d.month}');
        case 'Monthly':
          return Text('Week ${index + 1}');
        case 'Yearly':
          DateTime m = DateTime(now.year, now.month - (11 - index), 1);
          return Text('${m.month}');
        default:
          return Text('');
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
          ),
          padding: EdgeInsets.only(left: 3, right: 3),
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 30,
            backgroundImage: shopImageUrl != null
                ? NetworkImage(shopImageUrl!)
                : AssetImage('assets/images/dummy_image_map.png')
                      as ImageProvider,
          ),
        ),
        title: shopName != null
            ? Text(shopName!, style: TextStyle(fontWeight: FontWeight.bold))
            : Text('Your Shop Name'),
        actions: [
          IconButton(
            icon: Image.asset("assets/icons/notification_icon.png"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu_outlined, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: selectedPeriod,
                      items: ['Weekly', 'Monthly', 'Yearly']
                          .map(
                            (val) => DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            ),
                          )
                          .toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            selectedPeriod = newVal;
                          });
                          fetchAppointments();
                        }
                      },
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: "assets/icons/DashIcons/dash_booking.png",
                      iconColor: Colors.blue,
                      title: 'Total Booking',
                      value: totalBookings.toString(),
                      subtitle: 'Customers',
                      change: '+1.3%',
                      changeText: 'from last week',
                      isPositive: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      icon: "assets/icons/DashIcons/dash_income.png",
                      iconColor: Colors.blue,
                      title: 'Total Income',
                      value: 'PKR ${totalIncome.toStringAsFixed(2)}',
                      subtitle: '',
                      change: '+1.3%',
                      changeText: 'from last week',
                      isPositive: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: "assets/icons/DashIcons/dash_expense.png",
                      iconColor: Colors.blue,
                      title: 'Total Expense',
                      value: 'N/A',
                      subtitle: '',
                      change: '+1.3%',
                      changeText: 'from last week',
                      isPositive: false,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      icon: "assets/icons/DashIcons/dash_inventory.png",
                      iconColor: Colors.blue,
                      title: 'Inventory Left',
                      value: 'N/A',
                      subtitle: '',
                      change: '+1.3%',
                      changeText: 'from last week',
                      isPositive: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shop Performance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(Icons.more_vert, color: Colors.grey),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmployeeManagementScreen(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                              child: Text(
                                'Employee Management',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (barGroups.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: _bottomTitles,
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final String change;
  final String changeText;
  final bool isPositive;

  const StatsCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.changeText,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, height: 24, width: 24),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(width: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                isPositive
                    ? "assets/icons/DashIcons/dash_up.png"
                    : "assets/icons/DashIcons/dash_down.png",
                width: 24,
                height: 24,
              ),
              SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Text(
                changeText,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? fullName;
  String? designation;
  String? profilePictureUrl;
  String? shopId;
  bool isLoading = true;

  // Real stats
  double shopRating = 0.0;
  int totalReviews = 0;
  int totalClients = 0;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    fetchUserAndShopData();
  }

  Future<void> fetchUserAndShopData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return;

      shopId = userDoc['shopId'];
      if (shopId == null) return;

      setState(() {
        fullName = userDoc['fullName'] ?? 'User';
        designation = userDoc['designation'] ?? 'Role';
        profilePictureUrl = userDoc['profilePicture'];
      });

      await Future.wait([fetchRatingsAndReviews(), fetchUniqueClients()]);

      setState(() => isLoading = false);
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRatingsAndReviews() async {
    if (shopId == null) return;

    QuerySnapshot reviewsSnap = await FirebaseFirestore.instance
        .collection('reviews')
        .where('shopId', isEqualTo: shopId)
        .get();

    int count = reviewsSnap.docs.length;
    double totalRating = 0.0;

    for (var doc in reviewsSnap.docs) {
      totalRating += (doc['shopRating'] as num?)?.toDouble() ?? 0.0;
    }

    setState(() {
      totalReviews = count;
      shopRating = count > 0 ? totalRating / count : 0.0;
    });
  }

  Future<void> fetchUniqueClients() async {
    if (shopId == null) return;

    QuerySnapshot appointmentsSnap = await FirebaseFirestore.instance
        .collection('appointments')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: 'completed')
        .get();

    Set<String> uniqueUserIds = {};

    for (var doc in appointmentsSnap.docs) {
      String? userId = doc['userId'] as String?;
      if (userId != null && userId.isNotEmpty) {
        uniqueUserIds.add(userId);
      }
    }

    setState(() {
      totalClients = uniqueUserIds.length;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );

    if (image == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      String filePath = 'user_profiles/${user.uid}.jpg';
      UploadTask uploadTask = _storage.ref(filePath).putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'profilePicture': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      setState(() {
        profilePictureUrl = downloadUrl;
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile picture updated!")));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update image")));
    }
  }

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.only(top: 60, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          profilePictureUrl != null &&
                              profilePictureUrl!.isNotEmpty
                          ? NetworkImage(profilePictureUrl!)
                          : AssetImage('assets/profile_image.jpg')
                                as ImageProvider,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  fullName ?? 'Loading...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  designation ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      value: isLoading ? '...' : shopRating.toStringAsFixed(1),
                      label: 'Ratings',
                      icon: Icons.star,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopReviewsScreen(),
                          ),
                        );
                      },
                    ),
                    Container(width: 1, height: 50, color: Colors.black45),
                    _buildStatColumn(
                      value: isLoading ? '...' : totalReviews.toString(),
                      label: 'Reviews',
                      icon: Icons.rate_review,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopReviewsScreen(),
                          ),
                        );
                      },
                    ),
                    Container(width: 1, height: 50, color: Colors.black45),
                    _buildStatColumn(
                      value: isLoading ? '...' : totalClients.toString(),
                      label: 'Clients',
                      icon: Icons.person,
                      color: Colors.green,
                      onTap: () {
                        // Có thể tạo màn hình Clients sau
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Clients screen coming soon!"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_setting.png",
                  title: 'Settings',
                  onTap: () {},
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_notification.png",
                  title: 'Notification',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_profile.png",
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopDetailsScreen(),
                      ),
                    );
                  },
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_customer.png",
                  title: 'Employee Management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeManagementScreen(),
                      ),
                    );
                  },
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_customer_service.png",
                  title: 'Customer Support',
                  onTap: () {},
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_blog.png",
                  title: 'Blogs',
                  onTap: () {},
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_terms_condition.png",
                  title: 'Terms & Condition',
                  onTap: () {},
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_privacy_policy.png",
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                DrawerItem(
                  icon: "assets/icons/DrawerIcons/drawer_logout.png",
                  title: 'Log Out',
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFF305CDE), width: 3),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.priority_high,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Are you sure you want to log out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF305CDE0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _authService.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color(0xFF305CDE),
                              width: 1,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: Color(0xFF305CDE),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const DrawerItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(icon, width: 24, height: 24, color: Colors.black),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
