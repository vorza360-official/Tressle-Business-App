import 'package:flutter/material.dart';
import 'package:tressle_business/UI/attendenceListScreen.dart';
import 'package:tressle_business/UI/bookingListScreen.dart';
import 'package:tressle_business/UI/dashboardScreen.dart';
import 'package:tressle_business/UI/employeeHistoryScreen.dart';
import 'package:tressle_business/UI/notificationScreen.dart';
import 'package:tressle_business/UI/shopDetailScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    DashboardScreen(),
    AttendanceListScreen(),
    BookingListScreen(),
    EmployeeHistoryScreen(),
    ShopDetailsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'outlines_icon_home.png', 'filled_icon_home.png', 'Home'),
                _buildNavItem(1, 'outlines_icon_employee.png', 'filled_icon_emplyee.png', 'Employee'),
                _buildNavItem(2, 'outlines_icon_booking.png', 'filled_icon_booking.png', 'Booking'),
                _buildNavItem(3, 'outlines_icon_history.png', 'filled_icon_history.png', 'History'),
                _buildNavItem(4, 'outlines_icon_profile.png', 'filled_icon_profile.png', 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String unselectedIcon, String selectedIcon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/BottomNavIcons/${isSelected ? selectedIcon : unselectedIcon}',
              width: 35,
              height: 35,
            ),

          ],
        ),
      ),
    );
  }
}
