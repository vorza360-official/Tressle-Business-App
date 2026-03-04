import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tressle_business/ui/allBookingHistory.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:tressle_business/ui/booking.dart';
import 'package:tressle_business/ui/bookingDetailScreen.dart';
import 'package:tressle_business/ui/dashboardScreen.dart';
import 'package:tressle_business/ui/notificationScreen.dart';

class BookingListScreenH extends StatefulWidget {
  @override
  _BookingListScreenHState createState() => _BookingListScreenHState();
}

class _BookingListScreenHState extends State<BookingListScreenH> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? shopId;
  double? userLatitude;
  double? userLongitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUserLocation();
    await _getShopId();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userLatitude = userData['latitude'];
            userLongitude = userData['longitude'];
          });
        }
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  Future<void> _getShopId() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            shopId = userDoc.get('shopId');
          });
        }
      }
    } catch (e) {
      print('Error getting shopId: $e');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Map<String, dynamic>> _getShopRating(String shopId) async {
    try {
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('shopId', isEqualTo: shopId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return {'avgRating': 0.0, 'totalReviews': 0};
      }

      double totalRating = 0.0;
      int count = 0;

      for (var doc in ratingsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('shopRating')) {
          totalRating += (data['shopRating'] ?? 0).toDouble();
          count++;
        }
      }

      double avgRating = count > 0 ? totalRating / count : 0.0;

      return {'avgRating': avgRating, 'totalReviews': count};
    } catch (e) {
      print('Error getting shop rating: $e');
      return {'avgRating': 0.0, 'totalReviews': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("All Booking History")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : shopId == null
                  ? Center(child: Text('No shop associated with this account'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('appointments')
                          .where('shopId', isEqualTo: shopId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No bookings found'));
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var appointment = snapshot.data!.docs[index];
                            return FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('shops')
                                  .doc(appointment.get('shopId'))
                                  .get(),
                              builder: (context, shopSnapshot) {
                                if (!shopSnapshot.hasData) {
                                  return Container(
                                    height: 200,
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                var shopData =
                                    shopSnapshot.data!.data()
                                        as Map<String, dynamic>;

                                double distance = 0.0;
                                if (userLatitude != null &&
                                    userLongitude != null &&
                                    shopData.containsKey('latitude') &&
                                    shopData.containsKey('longitude')) {
                                  distance = _calculateDistance(
                                    userLatitude!,
                                    userLongitude!,
                                    shopData['latitude'],
                                    shopData['longitude'],
                                  );
                                }

                                return FutureBuilder<Map<String, dynamic>>(
                                  future: _getShopRating(
                                    appointment.get('shopId'),
                                  ),
                                  builder: (context, ratingSnapshot) {
                                    double avgRating = 0.0;
                                    int totalReviews = 0;

                                    if (ratingSnapshot.hasData) {
                                      avgRating =
                                          ratingSnapshot.data!['avgRating'];
                                      totalReviews =
                                          ratingSnapshot.data!['totalReviews'];
                                    }

                                    return _buildBookingCard(
                                      context,
                                      appointment.id,
                                      appointment.get('appointmentDate') ?? '',
                                      appointment.get('appointmentTime') ?? '',
                                      shopData['shopName'] ?? 'Unknown Shop',
                                      shopData['shopAddress'] ?? 'No address',
                                      shopData['shopImage'] ?? '',
                                      distance,
                                      appointment
                                              .get('grandTotal')
                                              ?.toDouble() ??
                                          0.0,
                                      appointment.get('currency') ?? 'PKR',
                                      appointment.id,
                                      appointment.get('status'),
                                      avgRating,
                                      totalReviews,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    String bookingId,
    String appointmentDate,
    String appointmentTime,
    String shopName,
    String address,
    String shopImage,
    double distance,
    double total,
    String currency,
    String documentId,
    String status,
    double avgRating,
    int totalReviews,
  ) {
    String formattedDate = '';
    try {
      if (appointmentDate.isNotEmpty) {
        DateTime date = DateTime.parse(appointmentDate);
        List<String> months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        formattedDate =
            '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year} | $appointmentTime';
      }
    } catch (e) {
      formattedDate = '$appointmentDate | $appointmentTime';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking id: ${bookingId.substring(0, bookingId.length > 12 ? 12 : bookingId.length)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Booking date: $formattedDate',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 90,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: shopImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          shopImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.store, size: 40, color: Colors.grey),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: totalReviews > 0 ? Colors.amber : Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          totalReviews > 0
                              ? '${avgRating.toStringAsFixed(1)} ($totalReviews)'
                              : 'Not rated',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          height: 3,
                          width: 3,
                          color: Color(0xFF305CDE),
                        ),
                        SizedBox(width: 4),
                        Text(
                          distance > 0
                              ? '${distance.toStringAsFixed(1)} km'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total: ',
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
                  color: Color(0xFF305CDE),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'cancelled'
                      ? Colors.red.shade100
                      : status == 'completed'
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                  border: Border.all(
                    width: 1,
                    color: status == 'cancelled'
                        ? Colors.red
                        : status == 'completed'
                        ? Colors.green
                        : Colors.amber,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'cancelled'
                        ? Colors.red
                        : status == 'completed'
                        ? Colors.green
                        : Colors.amber,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          status == 'cancelled'
              ? SizedBox()
              : Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingOK(appointmentId: documentId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF305CDE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 25,
                        ),
                      ),
                      child: Text(
                        'View Booking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(context, documentId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF305CDE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 25,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF305CDE),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('appointments')
                      .doc(documentId)
                      .update({'status': 'cancelled'});
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking cancelled successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error cancelling booking: $e')),
                  );
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
