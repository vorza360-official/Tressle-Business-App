import 'package:flutter/material.dart';
import 'package:tressle_business/ui/loginScreen.dart';

class ResetLinkSentScreen extends StatelessWidget {
  const ResetLinkSentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Link Sent',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: "Adamina",
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A password reset link has been sent to your email. Please check your inbox (and spam/junk folder) and click the link to reset your password.',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF305CDE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
