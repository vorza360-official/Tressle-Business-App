import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tressle_business/UI/HomeScreen.dart';
import 'package:tressle_business/UI/dashboardScreen.dart';
import 'package:tressle_business/UI/forgetPasswordUsernameScreen.dart';
import 'package:tressle_business/UI/shopDetailScreen.dart';
import 'package:tressle_business/UI/signupscreen.dart';
import 'package:tressle_business/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;
  int _selectedTabIndex = 0; // 0 for Email, 1 for Phone Number

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if phone number tab is selected
    if (_selectedTabIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone authentication is coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService().loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      // ✅ Navigate to your main/home screen
      // Example:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ShopDetailsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  final AuthService _authService = AuthService();
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      if (result['isNewUser'] == true) {
        // New Google user - redirect to profile completion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ShopDetailsScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Existing user - go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShopDetailsScreen()),
        );
      }
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),

                // Title
                Text(
                  'WELCOME \nBACK',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Adamina",
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                SizedBox(height: 40),

                // Tab Selection
                Row(
                  children: [
                    // Email Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 0;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0
                                    ? Color(0xFF305CDE)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _selectedTabIndex == 0
                                    ? Color(0xFF305CDE)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Phone Number Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 1;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1
                                    ? Color(0xFF305CDE)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _selectedTabIndex == 1
                                    ? Color(0xFF305CDE)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom border for tabs
                Container(height: 1, color: Colors.grey[300]),

                SizedBox(height: 30),

                // Email/Phone Input Field
                Text(
                  _selectedTabIndex == 0 ? 'Email Address' : 'Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _selectedTabIndex == 0
                      ? _emailController
                      : _phoneController,
                  keyboardType: _selectedTabIndex == 0
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _selectedTabIndex == 0
                          ? 'Please enter your email address'
                          : 'Please enter your phone number';
                    }
                    if (_selectedTabIndex == 0) {
                      // Email validation
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    } else {
                      // Phone validation - must start with + and have 10-15 digits
                      final phoneRegex = RegExp(r'^\+[1-9]\d{9,14}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Please enter a valid phone number (e.g., +923001234567)';
                      }
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: _selectedTabIndex == 0
                        ? 'hello@example.com'
                        : '+92123456789',
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
                      borderSide: BorderSide(color: Colors.blue[600]!),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Password Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter you password',
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
                      borderSide: BorderSide(color: Colors.blue[600]!),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Keep me signed in
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: Colors.blue[600],
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text(
                      'Keep me signed in',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Sign In Button
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF305CDE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Row(
                  children: [
                    // Google Button
                    Expanded(
                      child: Container(
                        height: 45,
                        child: OutlinedButton(
                          onPressed: _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            side: BorderSide(color: Colors.white, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.black)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google "G" logo
                                    Image.asset(
                                      "assets/icons/google_icon.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Sign up with Google',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Facebook Button
                    Expanded(
                      child: Container(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Facebook blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/facebook_icon.png",
                                width: 20,
                                height: 20,
                              ),
                              Text(
                                'Sign up with Facebook',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
