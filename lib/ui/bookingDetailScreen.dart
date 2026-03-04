import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String? appointmentId;
  BookingDetailsScreen({this.appointmentId});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    if (appointmentId == null) {
      return Center(child: Text('No appointment selected'));
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('appointments').doc(appointmentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Appointment not found'));
          }
          var appointment = snapshot.data!.data() as Map<String, dynamic>;
          String status = appointment['status'] ?? 'pending';

          return Column(
            children: [
              // Status Icons Row
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildIconButton(Icons.calendar_today, 'Booked', status == 'waiting' || status == 'processing' || status == 'completed'),
                        Container(
                          height: 10,
                          margin: EdgeInsets.only(bottom: 20),
                          width: MediaQuery.of(context).size.width * 0.1,
                          color: status == 'waiting' || status == 'processing' || status == 'completed' ? Colors.blue : Colors.grey[300],
                        ),
                        _buildIconButton(Icons.access_time, 'Waiting', status == 'waiting' || status == 'processing' || status == 'completed'),
                        Container(
                          height: 10,
                          margin: EdgeInsets.only(bottom: 20),
                          width: MediaQuery.of(context).size.width * 0.1,
                          color: status == 'processing' || status == 'completed' ? Colors.blue : Colors.grey[300],
                        ),
                        _buildIconButton(Icons.content_cut, 'Processing', status == 'processing' || status == 'completed'),
                        Container(
                          height: 10,
                          margin: EdgeInsets.only(bottom: 20),
                          width: MediaQuery.of(context).size.width * 0.1,
                          color: status == 'completed' ? Colors.blue : Colors.grey[300],
                        ),
                        _buildIconButton(Icons.check_circle, 'Finished', status == 'completed'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Customer Card
                        FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('users').doc(appointment['userId']).get(),
                          builder: (context, userSnapshot) {
                            String userName = appointment['userName'] ?? 'Unknown Customer';
                            String userImage = 'assets/images/client_dummy_image.jpg';
                            if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                              userName = userData['name'] ?? userName;
                              if (userData.containsKey('profileImage') && userData['profileImage'] != null) {
                                userImage = userData['profileImage'];
                              }
                            }
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: userImage.startsWith('http')
                                        ? NetworkImage(userImage) as ImageProvider
                                        : AssetImage(userImage),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Booking id: ${appointmentId!.substring(0, appointmentId!.length > 12 ? 12 : appointmentId!.length)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              'Not rated',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            // TODO: Implement e-receipt view
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(width: 1, color: Color(0xFF305CDE)),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                          ),
                                          child: Text(
                                            'View E-Receipt',
                                            style: TextStyle(
                                              color: Color(0xFF305CDE),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        // Date & Time Card
                        _buildDateTimeCard(appointment),
                        SizedBox(height: 16),
                        // Services Card
                        _buildServicesCard(appointment),
                        SizedBox(height: 16),
                        // Specialist Card
                        _buildSpecialistCard(appointment),
                        SizedBox(height: 16),
                        // Payment Method Card
                        _buildPaymentMethodCard(),
                        SizedBox(height: 16),
                        // Total Card
                        _buildTotalCard(appointment),
                        SizedBox(height: 16),
                        // Dynamic Button
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ElevatedButton(
                            onPressed: status == 'completed' ? null : () async {
                              if (status == 'waiting') {
                                _showConfirmationDialog(
                                  context,
                                  'Process Booking',
                                  'Are you sure you want to start processing this booking?',
                                  () async {
                                    await _firestore.collection('appointments').doc(appointmentId).update({'status': 'processing'});
                                    Navigator.of(context).pop();
                                  },
                                );
                              } else if (status == 'processing') {
                                _showConfirmationDialog(
                                  context,
                                  'Complete Booking',
                                  'Are you sure you want to mark this booking as completed?',
                                  () async {
                                    await _firestore.collection('appointments').doc(appointmentId).update({'status': 'completed'});
                                    Navigator.of(context).pop();
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'completed' ? Colors.grey : Color(0xFF4A90E2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            child: Text(
                              status == 'waiting' ? 'Process the Booking' : (status == 'processing' ? 'Complete the Booking' : 'Booking Completed'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF4A90E2) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color(0xFF4A90E2) : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(Map<String, dynamic> appointment) {
    String date = '';
    String time = appointment['appointmentTime'] ?? '';
    try {
      DateTime dateTime = DateTime.parse(appointment['appointmentDate']);
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      date = '${dateTime.day} ${months[dateTime.month - 1]}';
    } catch (e) {
      date = appointment['appointmentDate'] ?? '';
    }
    // Calculate end time based on service durations
    String endTime = time;
    try {
      List<dynamic> services = appointment['services'] ?? [];
      int totalMinutes = 0;
      for (var service in services) {
        String duration = service['duration'] ?? '0 min';
        int minutes = int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        totalMinutes += minutes;
      }
      if (time.isNotEmpty && totalMinutes > 0) {
        DateTime startTime = DateTime.now();
        try {
          final parts = time.split(' ');
          final timeParts = parts[0].split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
            hour += 12;
          } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
            hour = 0;
          }
          startTime = DateTime(2000, 1, 1, hour, minute);
          DateTime end = startTime.add(Duration(minutes: totalMinutes));
          int endHour = end.hour;
          String period = endHour >= 12 ? 'PM' : 'AM';
          if (endHour > 12) endHour -= 12;
          if (endHour == 0) endHour = 12;
          endTime = '${endHour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')} $period';
        } catch (e) {
          print('Error parsing time: $e');
        }
      }
    } catch (e) {
      print('Error calculating end time: $e');
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date & Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '$time to $endTime',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(Map<String, dynamic> appointment) {
    List<dynamic> services = appointment['services'] ?? [];
    String currency = appointment['currency'] ?? 'PKR';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          ...services.map((service) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildServiceItem(
                service['serviceName'] ?? 'Unknown Service',
                '$currency ${service['price']?.toString() ?? '0'}',
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service, String price) {
    return Row(
      children: [
        Container(
          width: 65,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage('assets/images/dummy_image_map.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            service,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> appointment) {
    String staffName = appointment['staffName'] ?? 'Unknown';
    String staffDesignation = appointment['staffDesignation'] ?? 'Staff';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specialist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/client_dummy_image.jpg'),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staffName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    staffDesignation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'CASH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Cash Payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(Map<String, dynamic> appointment) {
    double total = appointment['grandTotal']?.toDouble() ?? 0.0;
    String currency = appointment['currency'] ?? 'PKR';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            '$currency ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}