import 'package:flutter/material.dart';
import 'package:tressle_business/ui/employeeProfileScreen.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  String selectedDate = '27/06/2025';

  final List<Map<String, dynamic>> employees = [
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '05:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '05:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '06:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '05:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '05:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
    {
      'name': 'Cameron Williamson',
      'id': 'XXL504900',
      'position': 'Barber',
      'timeIn': '05:00:00',
      'timeOut': '06:00:00',
      'avatar': 'assets/images/client_dummy_image.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.black87,
      //       size: 20,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.menu, color: Colors.black87),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              Row(
                children: [
                  const Text(
                    '      Attendance List',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 15),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            selectedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    // Total Employee Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'Total Employee',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '400',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Employee List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 1, color: Colors.black45),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Profile Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: Image.asset(
                                  employee['avatar'],
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.brown.shade300,
                                      child: Center(
                                        child: Text(
                                          employee['name']
                                              .split(' ')
                                              .map((e) => e[0])
                                              .join(''),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Employee Info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  employee['id'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  employee['position'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Text(
                                  'Time In',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF305CDE),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    employee['timeIn'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Time Out
                            Column(
                              children: [
                                Text(
                                  'Time Out',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color(0xFF305CDE),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    employee['timeOut'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF305CDE),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Coming Soon Overlay
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Employee Attendance Feature',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
