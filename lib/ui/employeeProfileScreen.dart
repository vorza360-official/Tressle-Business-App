import 'package:flutter/material.dart';
import 'dart:math' as math;


class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  String selectedDate = '27/06/2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section with Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B73FF), Color(0xFF9DD5EA)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Profile Section
                  Column(
                    children: [
                      // Profile Image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              "assets/images/client_dummy_image.jpg",
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cameron Williamson',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 4),

                              const Text(
                                'Employee Id: 1213X2C',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Employee Name and ID

                      // Timer Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: const Text(
                          '09:00:07',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            Icons.power_settings_new,
                            'Log Out',
                          ),
                          _buildActionButton(
                            Icons.calendar_today,
                            'Attendance',
                          ),
                          InkWell(
                            onTap: () {
                              //       Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => BarberProfileScreen()),
                              // );
                            },
                            child: _buildActionButton(
                              Icons.report_gmailerrorred,
                              'Report',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // White Content Section
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Statics Section
                    const Text(
                      'Personal Statics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Circular Progress Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularProgress(
                          '90%',
                          'Present',
                          0.9,
                          Colors.blue,
                        ),
                        _buildCircularProgress(
                          '5%',
                          'Absent',
                          0.05,
                          Colors.red,
                        ),
                        _buildCircularProgress(
                          '5%',
                          'Leaves',
                          0.05,
                          Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Leave Request Section
                    const Text(
                      'Leave Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sick Leave Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sick Leave',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Starting from....',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '12 June',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4285F4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'From',
                                      style: TextStyle(
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
                                    '20 June',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Leave Statistics
                    _buildLeaveStatItem('Number Of Leaves', '18 Leaves'),
                    const SizedBox(height: 16),
                    _buildLeaveStatItem('Used Leaves', '05 Leaves'),
                    const SizedBox(height: 16),
                    _buildLeaveStatItem('Casual Leaves', '01 Leaves'),
                    const SizedBox(height: 16),
                    _buildLeaveStatItem('Sick Leaves', '04 Leaves'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    String percentage,
    String label,
    double progress,
    Color color,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              // Background Circle
              CustomPaint(
                size: const Size(80, 80),
                painter: CircularProgressPainter(
                  progress: 1.0,
                  color: Colors.grey.shade200,
                  strokeWidth: 3,
                ),
              ),
              // Progress Circle
              CustomPaint(
                size: const Size(80, 80),
                painter: CircularProgressPainter(
                  progress: progress,
                  color: color,
                  strokeWidth: 3,
                ),
              ),
              // Center Text
              Center(
                child: Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveStatItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Circular Progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Progress angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
