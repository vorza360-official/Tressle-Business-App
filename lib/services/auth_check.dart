import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tressle_business/UI/homeScreen.dart';
import 'package:tressle_business/UI/onBoardingScreen.dart';
import 'package:tressle_business/UI/shopDetailScreen.dart';

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in, now check shop details
          print("I am here");
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                return const Scaffold(
                  body: Center(
                    child: Text('Error loading user data'),
                  ),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // User document doesn't exist, go to shop details
                return ShopDetailsScreen();
              }

              // Check if shopId exists and shop details are filled
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              final shopId = userData?['shopId'];

              if (shopId == null || shopId.toString().isEmpty) {
                // No shopId, go to shop details screen
                return ShopDetailsScreen();
              }

              // ShopId exists, verify shop details are complete
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('shops')
                    .doc(shopId)
                    .get(),
                builder: (context, shopSnapshot) {
                  if (shopSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (shopSnapshot.hasError || 
                      !shopSnapshot.hasData || 
                      !shopSnapshot.data!.exists) {
                    // Shop document doesn't exist, go to shop details
                    return ShopDetailsScreen();
                  }

                  // Check if major shop details are filled
                  final shopData = shopSnapshot.data!.data() as Map<String, dynamic>?;
                  
                  if (_areShopDetailsFilled(shopData)) {
                    // All major details filled, go to home
                    return MainScreen();
                  } else {
                    // Details incomplete, go to shop details screen
                    return ShopDetailsScreen();
                  }
                },
              );
            },
          );
        } else {
          // User not logged in
          return OnboardingScreen();
        }
      },
    );
  }

  /// Check if major shop details are filled
  bool _areShopDetailsFilled(Map<String, dynamic>? shopData) {
    if (shopData == null) return false;

    // Define your required fields here
    final requiredFields = [
      'shopName',
      'description',
      'shopImage',
      'shopAddress',
      // Add other required fields as needed
    ];

    for (String field in requiredFields) {
      final value = shopData[field];
      if (value == null || value.toString().trim().isEmpty) {
        return false;
      }
    }

    return true;
  }
}