import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tressle_business/ui/appointmentHistoryScreen.dart';
import 'package:tressle_business/ui/bookingDetailScreen.dart';

// ==================== BOOKING OK SCREEN ====================
class BookingOK extends StatefulWidget {
  final String? appointmentId;
  
  const BookingOK({Key? key, this.appointmentId}) : super(key: key);

  @override
  State<BookingOK> createState() => _BookingOKState();
}

class _BookingOKState extends State<BookingOK> {
  bool isHistorySelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isHistorySelected = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: !isHistorySelected
                                ? Color(0xFF305CDE)
                                : Colors.transparent,
                            boxShadow: !isHistorySelected
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Upcoming',
                              style: TextStyle(
                                fontFamily: "Adamina",
                                color: !isHistorySelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: !isHistorySelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isHistorySelected = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isHistorySelected
                                ? Color(0xFF305CDE)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              'History',
                              style: TextStyle(
                                fontFamily: "Adamina",
                                color: isHistorySelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: isHistorySelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isHistorySelected 
                  ? HistoryScreen() 
                  : BookingDetailsScreen(appointmentId: widget.appointmentId),
            ),
          ],
        ),
      ),
    );
  }
}