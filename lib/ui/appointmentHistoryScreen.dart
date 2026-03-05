import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tressle_business/ui/booking.dart';

class HistoryScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<String?>(
        future: _getShopId(),
        builder: (context, shopSnapshot) {
          if (shopSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!shopSnapshot.hasData || shopSnapshot.data == null) {
            return Center(child: Text('No shop found'));
          }

          String shopId = shopSnapshot.data!;

          return Column(
            children: [
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('appointments')
                      .where('shopId', isEqualTo: shopId)
                      .where('status', isEqualTo: 'completed')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No completed bookings found'));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var appointment = snapshot.data!.docs[index];
                        var data = appointment.data() as Map<String, dynamic>;
                        
                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('users').doc(data['userId']).get(),
                          builder: (context, userSnapshot) {
                            String userName = data['userName'] ?? 'Unknown Customer';
                            String userImage = 'assets/images/client_dummy_image.jpg';
                            
                            if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                              userName = userData['name'] ?? userName;
                              if (userData.containsKey('profileImage') && userData['profileImage'] != null) {
                                userImage = userData['profileImage'];
                              }
                            }

                            return Column(
                              children: [
                                _buildHistoryCard(
                                  context,
                                  appointment.id,
                                  userName,
                                  userImage,
                                ),
                                SizedBox(height: 16),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _getShopId() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          return userDoc.get('shopId');
        }
      }
    } catch (e) {
      print('Error getting shopId: $e');
    }
    return null;
  }

  Widget _buildHistoryCard(BuildContext context, String bookingId, String userName, String userImage) {
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
                  'Booking id: ${bookingId.substring(0, bookingId.length > 12 ? 12 : bookingId.length)}',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingOK(appointmentId: bookingId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF305CDE)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25),
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
  }
}