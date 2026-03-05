import 'package:flutter/material.dart';
import 'package:tressle_business/ui/onBoardingScreen.dart';
import 'package:tressle_business/ui/signupscreen.dart';
import 'package:tressle_business/services/auth_check.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to SignUpScreen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthCheck()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            // Logo and Title
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for your logo image
                    Image.asset(
                      "assets/images/tressleLogoBus.png",
                      height: 250,
                      width: 250,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'TRESSLE FOR BUSINESS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        fontFamily: "Adamina",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
