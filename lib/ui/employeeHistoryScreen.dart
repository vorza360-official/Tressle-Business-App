import 'package:flutter/material.dart';
import 'package:tressle_business/UI/attendenceListScreen.dart';

class EmployeeHistoryScreen extends StatefulWidget {
  const EmployeeHistoryScreen({super.key});

  @override
  State<EmployeeHistoryScreen> createState() => _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState extends State<EmployeeHistoryScreen> {
  String selectedDate = '27/06/2025';
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(fontSize: 32, color: Colors.black),
                    ),
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
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedIndex == 0
                                      ? const Color(0xFF4285F4)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Attendance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedIndex == 0
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedIndex == 1
                                      ? const Color(0xFF4285F4)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Leaves',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedIndex == 1
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Tab Content
              Expanded(
                child: _selectedIndex == 0
                    ? const AttendanceWidget()
                    : const LeavesEmployeeWidget(),
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

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Container(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LeavesEmployeeWidget extends StatefulWidget {
  const LeavesEmployeeWidget({super.key});

  @override
  State<LeavesEmployeeWidget> createState() => _LeavesEmployeeWidgetState();
}

class _LeavesEmployeeWidgetState extends State<LeavesEmployeeWidget> {
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Container(
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
                              color: Colors.red,
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
                              border: Border.all(width: 0.5, color: Colors.red),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              employee['timeOut'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
