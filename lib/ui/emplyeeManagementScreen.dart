import 'package:flutter/material.dart';
import 'package:tressle_business/ui/ShopDetailsTabs/staff.dart';
import 'package:tressle_business/ui/addEmployeeScreen.dart';

class EmployeeManagementScreen extends StatelessWidget {
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
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Employee Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40),
            
            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  MenuListItem(
                    icon: "assets/icons/add_employee.png",
                    title: 'Add Employee',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StaffTab(previousScreen: "staffScreen")),
                        );
                    },
                  ),
                  MenuListItem(
                    icon: "assets/icons/attendence_list.png",
                    title: 'Attendance List',
                    onTap: () {
                      // Navigate to Attendance List screen
                    },
                  ),
                  MenuListItem(
                    icon: "assets/icons/leave_management.png",
                    title: 'Leave Management',
                    onTap: () {
                      // Navigate to Leave Management screen
                    },
                  ),
                  MenuListItem(
                    icon: "assets/icons/employee_overtime.png",
                    title: 'Employee Overtime',
                    onTap: () {
                      // Navigate to Employee Overtime screen
                    },
                  ),
                  MenuListItem(
                    icon: "assets/icons/salary_statement.png",
                    title: 'Salary Statement',
                    onTap: () {
                      // Navigate to Salary Statement screen
                    },
                  ),
                  MenuListItem(
                    icon: "assets/icons/DrawerIcons/drawer_profile.png",
                    title: 'Profile',
                    onTap: () {
                      // Navigate to Profile screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuListItem extends StatelessWidget {
  final String icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const MenuListItem({
    Key? key,
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        leading: Container(
          width: 24,
          height: 24,
          child: Image.asset(icon,width: 24,height: 24,)
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: titleColor ?? Colors.black87,
            decoration: titleColor == Colors.blue ? TextDecoration.underline : null,
            decorationColor: Colors.blue,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 28,
        ),
        onTap: onTap,
      ),
    );
  }
}