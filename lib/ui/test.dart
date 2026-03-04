import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Format: +1234567890
        timeout: const Duration(seconds: 60),
        
        // Called when verification is completed automatically
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
          // Auto sign in
          await _auth.signInWithCredential(credential);
        },
        
        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            onError('Invalid phone number format');
          } else if (e.code == 'too-many-requests') {
            onError('Too many requests. Try again later');
          } else {
            onError(e.message ?? 'Verification failed');
          }
        },
        
        // Called when OTP is sent
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Called when timeout occurs
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId ?? _verificationId!,
        smsCode: otp,
      );
      
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw 'Invalid OTP. Please try again';
      } else if (e.code == 'session-expired') {
        throw 'OTP expired. Please request a new one';
      } else {
        throw e.message ?? 'Verification failed';
      }
    }
  }

  // Resend OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}

// Example usage in a widget
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final PhoneAuthService _authService = PhoneAuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _otpSent = false;
  bool _loading = false;
  String? _verificationId;

  // Send OTP
  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter phone number');
      return;
    }

    setState(() => _loading = true);

    await _authService.sendOTP(
      phoneNumber: _phoneController.text, // e.g., +923001234567
      onCodeSent: (verificationId) {
        setState(() {
          _otpSent = true;
          _loading = false;
          _verificationId = verificationId;
        });
        _showSnackBar('OTP sent successfully');
      },
      onError: (error) {
        setState(() => _loading = false);
        _showSnackBar(error);
      },
      onAutoVerify: (credential) {
        _showSnackBar('Auto verified!');
        // Navigate to home screen
      },
    );
  }

  // Verify OTP
  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter OTP');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await _authService.verifyOTP(
        otp: _otpController.text,
        verificationId: _verificationId,
      );

      if (userCredential != null) {
        _showSnackBar('Login successful!');
        // Navigate to home screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_otpSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+923001234567',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _sendOTP,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Send OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _verifyOTP,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Verify OTP'),
              ),
              TextButton(
                onPressed: _loading ? null : _sendOTP,
                child: const Text('Resend OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}