import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tressle_business/UI/loginScreen.dart';
import 'package:tressle_business/services/auth_service.dart'; // Import your auth service

class EmailPhoneVerifyScreen extends StatefulWidget {
  final String phoneNumber; // Pass phone number from signup
  
  const EmailPhoneVerifyScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _EmailPhoneVerifyScreenState createState() => _EmailPhoneVerifyScreenState();
}

class _EmailPhoneVerifyScreenState extends State<EmailPhoneVerifyScreen> {
  final _phoneOtpController = TextEditingController();
  final AuthService _authService = AuthService();

  Timer? _timer;
  Timer? _emailCheckTimer;
  int _countdown = 52;
  bool _canRequestOtp = false;
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _isVerifyingPhone = false;
  bool _otpSent = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startEmailVerificationCheck();
    _sendInitialPhoneOTP();
  }

  // Send OTP when screen loads
  Future<void> _sendInitialPhoneOTP() async {
    if (widget.phoneNumber.isNotEmpty) {
      final result = await _authService.sendPhoneOTP(widget.phoneNumber);
      if (result['success']) {
        setState(() {
          _otpSent = true;
        });
        Future.delayed(Duration(seconds: 3), () {
          _showSnackBar(result['message'], isError: false);
        });
        
      } else {
        Future.delayed(Duration(seconds: 3), () {
          _showSnackBar(result['message'], isError: true);
        });
      }
    }
  }

  void _startEmailVerificationCheck() {
    _checkEmailVerification();

    _emailCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (user?.emailVerified == true && !_isEmailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
        _emailCheckTimer?.cancel();
        _showSnackBar('Email verified successfully!', isError: false);
      }
    }
  }

  void _startCountdown() {
    _canRequestOtp = false;
    _countdown = 52;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canRequestOtp = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    if (_canRequestOtp && !_isVerifyingPhone) {
      setState(() {
        _isVerifyingPhone = true;
      });

      final result = await _authService.resendOTP(widget.phoneNumber);
      
      setState(() {
        _isVerifyingPhone = false;
      });

      if (result['success']) {
        _showSnackBar(result['message'], isError: false);
        _startCountdown();
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    }
  }

  Future<void> _verifyPhoneOTP() async {
    String otp = _phoneOtpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar('Please enter OTP', isError: true);
      return;
    }

    if (otp.length != 6) {
      _showSnackBar('OTP must be 6 digits', isError: true);
      return;
    }

    setState(() {
      _isVerifyingPhone = true;
    });

    final result = await _authService.verifyPhoneOTP(otp);

    setState(() {
      _isVerifyingPhone = false;
    });

    if (result['success']) {
      setState(() {
        _isPhoneVerified = true;
      });
      _showSnackBar('Phone verified successfully!', isError: false);
      
      // If both verifications are done, wait a bit then navigate
      if (_isEmailVerified && _isPhoneVerified) {
        await Future.delayed(Duration(seconds: 1));
        _navigateToLogin();
      }
    } else {
      _showSnackBar(result['message'], isError: true);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCheckTimer?.cancel();
    _phoneOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine button state
    bool canProceed = _isEmailVerified && _isPhoneVerified;
    bool canVerifyPhone = _isEmailVerified && !_isPhoneVerified;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                ),

                SizedBox(height: 60),

                Text(
                  'Email & Phone \nVerify',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Adamina",
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Verify your email and phone number',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                SizedBox(height: 70),

                // Email Verification Status Container
                Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isEmailVerified
                        ? Colors.green[50]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isEmailVerified
                          ? Colors.green
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isEmailVerified
                                ? Icons.check_circle
                                : Icons.email_outlined,
                            color: _isEmailVerified
                                ? Colors.green
                                : Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEmailVerified
                                  ? 'Your email has been verified!'
                                  : 'Verification link sent to email',
                              style: TextStyle(
                                color: _isEmailVerified
                                    ? Colors.green[800]
                                    : Colors.grey[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isEmailVerified
                            ? 'Now verify your phone number below'
                            : 'Click the link in your email to verify',
                        style: TextStyle(
                          color: _isEmailVerified
                              ? Colors.green[700]
                              : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // Phone Number OTP Section
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),

                // Phone verification status container (when verified)
                if (_isPhoneVerified)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Phone number verified!',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneOtpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              enabled: !_isVerifyingPhone,
                              decoration: InputDecoration(
                                hintText: 'Enter 6-digit OTP',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal[700]!),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                counterText: "",
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: _canRequestOtp && !_isVerifyingPhone
                                ? _resendOtp
                                : null,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: _canRequestOtp && !_isVerifyingPhone
                                    ? Color(0xFF305CDE)
                                    : Colors.blue[300],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Countdown Timer
                      Center(
                        child: Text(
                          _canRequestOtp
                              ? 'You can request OTP now'
                              : 'You can request OTP after ${_formatTime(_countdown)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 30),

                // Action Button
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifyingPhone
                        ? null
                        : () {
                            if (canProceed) {
                              _navigateToLogin();
                            } else if (canVerifyPhone) {
                              _verifyPhoneOTP();
                            } else {
                              _showSnackBar(
                                'Please verify your email first',
                                isError: true,
                              );
                            }
                          },
                    child: _isVerifyingPhone
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            canProceed
                                ? 'Go to Login'
                                : canVerifyPhone
                                    ? 'Verify Phone'
                                    : 'Verify Email First',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? Colors.green
                          : canVerifyPhone
                              ? Color(0xFF305CDE)
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Progress indicator
                if (!_isEmailVerified || !_isPhoneVerified)
                  Center(
                    child: Text(
                      _isEmailVerified
                          ? 'Step 2: Verify phone number'
                          : 'Step 1: Verify email address',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}