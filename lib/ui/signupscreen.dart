import 'package:flutter/material.dart';
import 'package:tressle_business/ui/googleProfileCompletionScreen.dart';
import 'package:tressle_business/ui/loginScreen.dart';
import 'package:tressle_business/ui/shopDetailScreen.dart';
import 'package:tressle_business/ui/signupVerificationScreen.dart';
import 'package:tressle_business/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;
  String? _selectedDesignation;

  final List<String> _designations = ['Employee', 'Owner'];
  String selectedCountryCode = '+92';
  String selectedCountryFlag = '🇵🇰';
  String selectedCountryName = 'Pakistan';

  // List of countries with their data
  final List<Map<String, String>> countries = [
    {'name': 'Afghanistan', 'code': '+93', 'flag': '🇦🇫'},
    {'name': 'Albania', 'code': '+355', 'flag': '🇦🇱'},
    {'name': 'Algeria', 'code': '+213', 'flag': '🇩🇿'},
    {'name': 'Andorra', 'code': '+376', 'flag': '🇦🇩'},
    {'name': 'Angola', 'code': '+244', 'flag': '🇦🇴'},
    {'name': 'Antigua and Barbuda', 'code': '+1-268', 'flag': '🇦🇬'},
    {'name': 'Argentina', 'code': '+54', 'flag': '🇦🇷'},
    {'name': 'Armenia', 'code': '+374', 'flag': '🇦🇲'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Austria', 'code': '+43', 'flag': '🇦🇹'},
    {'name': 'Azerbaijan', 'code': '+994', 'flag': '🇦🇿'},
    {'name': 'Bahamas', 'code': '+1-242', 'flag': '🇧🇸'},
    {'name': 'Bahrain', 'code': '+973', 'flag': '🇧🇭'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'Barbados', 'code': '+1-246', 'flag': '🇧🇧'},
    {'name': 'Belarus', 'code': '+375', 'flag': '🇧🇾'},
    {'name': 'Belgium', 'code': '+32', 'flag': '🇧🇪'},
    {'name': 'Belize', 'code': '+501', 'flag': '🇧🇿'},
    {'name': 'Benin', 'code': '+229', 'flag': '🇧🇯'},
    {'name': 'Bhutan', 'code': '+975', 'flag': '🇧🇹'},
    {'name': 'Bolivia', 'code': '+591', 'flag': '🇧🇴'},
    {'name': 'Bosnia and Herzegovina', 'code': '+387', 'flag': '🇧🇦'},
    {'name': 'Botswana', 'code': '+267', 'flag': '🇧🇼'},
    {'name': 'Brazil', 'code': '+55', 'flag': '🇧🇷'},
    {'name': 'Brunei', 'code': '+673', 'flag': '🇧🇳'},
    {'name': 'Bulgaria', 'code': '+359', 'flag': '🇧🇬'},
    {'name': 'Burkina Faso', 'code': '+226', 'flag': '🇧🇫'},
    {'name': 'Burundi', 'code': '+257', 'flag': '🇧🇮'},
    {'name': 'Cambodia', 'code': '+855', 'flag': '🇰🇭'},
    {'name': 'Cameroon', 'code': '+237', 'flag': '🇨🇲'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Cape Verde', 'code': '+238', 'flag': '🇨🇻'},
    {'name': 'Central African Republic', 'code': '+236', 'flag': '🇨🇫'},
    {'name': 'Chad', 'code': '+235', 'flag': '🇹🇩'},
    {'name': 'Chile', 'code': '+56', 'flag': '🇨🇱'},
    {'name': 'China', 'code': '+86', 'flag': '🇨🇳'},
    {'name': 'Colombia', 'code': '+57', 'flag': '🇨🇴'},
    {'name': 'Comoros', 'code': '+269', 'flag': '🇰🇲'},
    {'name': 'Congo', 'code': '+242', 'flag': '🇨🇬'},
    {'name': 'Congo (DRC)', 'code': '+243', 'flag': '🇨🇩'},
    {'name': 'Costa Rica', 'code': '+506', 'flag': '🇨🇷'},
    {'name': 'Croatia', 'code': '+385', 'flag': '🇭🇷'},
    {'name': 'Cuba', 'code': '+53', 'flag': '🇨🇺'},
    {'name': 'Cyprus', 'code': '+357', 'flag': '🇨🇾'},
    {'name': 'Czech Republic', 'code': '+420', 'flag': '🇨🇿'},
    {'name': 'Denmark', 'code': '+45', 'flag': '🇩🇰'},
    {'name': 'Djibouti', 'code': '+253', 'flag': '🇩🇯'},
    {'name': 'Dominica', 'code': '+1-767', 'flag': '🇩🇲'},
    {'name': 'Dominican Republic', 'code': '+1-809', 'flag': '🇩🇴'},
    {'name': 'East Timor', 'code': '+670', 'flag': '🇹🇱'},
    {'name': 'Ecuador', 'code': '+593', 'flag': '🇪🇨'},
    {'name': 'Egypt', 'code': '+20', 'flag': '🇪🇬'},
    {'name': 'El Salvador', 'code': '+503', 'flag': '🇸🇻'},
    {'name': 'Equatorial Guinea', 'code': '+240', 'flag': '🇬🇶'},
    {'name': 'Eritrea', 'code': '+291', 'flag': '🇪🇷'},
    {'name': 'Estonia', 'code': '+372', 'flag': '🇪🇪'},
    {'name': 'Eswatini', 'code': '+268', 'flag': '🇸🇿'},
    {'name': 'Ethiopia', 'code': '+251', 'flag': '🇪🇹'},
    {'name': 'Fiji', 'code': '+679', 'flag': '🇫🇯'},
    {'name': 'Finland', 'code': '+358', 'flag': '🇫🇮'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Gabon', 'code': '+241', 'flag': '🇬🇦'},
    {'name': 'Gambia', 'code': '+220', 'flag': '🇬🇲'},
    {'name': 'Georgia', 'code': '+995', 'flag': '🇬🇪'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    {'name': 'Greece', 'code': '+30', 'flag': '🇬🇷'},
    {'name': 'Grenada', 'code': '+1-473', 'flag': '🇬🇩'},
    {'name': 'Guatemala', 'code': '+502', 'flag': '🇬🇹'},
    {'name': 'Guinea', 'code': '+224', 'flag': '🇬🇳'},
    {'name': 'Guinea-Bissau', 'code': '+245', 'flag': '🇬🇼'},
    {'name': 'Guyana', 'code': '+592', 'flag': '🇬🇾'},
    {'name': 'Haiti', 'code': '+509', 'flag': '🇭🇹'},
    {'name': 'Honduras', 'code': '+504', 'flag': '🇭🇳'},
    {'name': 'Hungary', 'code': '+36', 'flag': '🇭🇺'},
    {'name': 'Iceland', 'code': '+354', 'flag': '🇮🇸'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'Indonesia', 'code': '+62', 'flag': '🇮🇩'},
    {'name': 'Iran', 'code': '+98', 'flag': '🇮🇷'},
    {'name': 'Iraq', 'code': '+964', 'flag': '🇮🇶'},
    {'name': 'Ireland', 'code': '+353', 'flag': '🇮🇪'},
    {'name': 'Israel', 'code': '+972', 'flag': '🇮🇱'},
    {'name': 'Italy', 'code': '+39', 'flag': '🇮🇹'},
    {'name': 'Ivory Coast', 'code': '+225', 'flag': '🇨🇮'},
    {'name': 'Jamaica', 'code': '+1-876', 'flag': '🇯🇲'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'Jordan', 'code': '+962', 'flag': '🇯🇴'},
    {'name': 'Kazakhstan', 'code': '+7', 'flag': '🇰🇿'},
    {'name': 'Kenya', 'code': '+254', 'flag': '🇰🇪'},
    {'name': 'Kiribati', 'code': '+686', 'flag': '🇰🇮'},
    {'name': 'Kosovo', 'code': '+383', 'flag': '🇽🇰'},
    {'name': 'Kuwait', 'code': '+965', 'flag': '🇰🇼'},
    {'name': 'Kyrgyzstan', 'code': '+996', 'flag': '🇰🇬'},
    {'name': 'Laos', 'code': '+856', 'flag': '🇱🇦'},
    {'name': 'Latvia', 'code': '+371', 'flag': '🇱🇻'},
    {'name': 'Lebanon', 'code': '+961', 'flag': '🇱🇧'},
    {'name': 'Lesotho', 'code': '+266', 'flag': '🇱🇸'},
    {'name': 'Liberia', 'code': '+231', 'flag': '🇱🇷'},
    {'name': 'Libya', 'code': '+218', 'flag': '🇱🇾'},
    {'name': 'Liechtenstein', 'code': '+423', 'flag': '🇱🇮'},
    {'name': 'Lithuania', 'code': '+370', 'flag': '🇱🇹'},
    {'name': 'Luxembourg', 'code': '+352', 'flag': '🇱🇺'},
    {'name': 'Madagascar', 'code': '+261', 'flag': '🇲🇬'},
    {'name': 'Malawi', 'code': '+265', 'flag': '🇲🇼'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
    {'name': 'Maldives', 'code': '+960', 'flag': '🇲🇻'},
    {'name': 'Mali', 'code': '+223', 'flag': '🇲🇱'},
    {'name': 'Malta', 'code': '+356', 'flag': '🇲🇹'},
    {'name': 'Marshall Islands', 'code': '+692', 'flag': '🇲🇭'},
    {'name': 'Mauritania', 'code': '+222', 'flag': '🇲🇷'},
    {'name': 'Mauritius', 'code': '+230', 'flag': '🇲🇺'},
    {'name': 'Mexico', 'code': '+52', 'flag': '🇲🇽'},
    {'name': 'Micronesia', 'code': '+691', 'flag': '🇫🇲'},
    {'name': 'Moldova', 'code': '+373', 'flag': '🇲🇩'},
    {'name': 'Monaco', 'code': '+377', 'flag': '🇲🇨'},
    {'name': 'Mongolia', 'code': '+976', 'flag': '🇲🇳'},
    {'name': 'Montenegro', 'code': '+382', 'flag': '🇲🇪'},
    {'name': 'Morocco', 'code': '+212', 'flag': '🇲🇦'},
    {'name': 'Mozambique', 'code': '+258', 'flag': '🇲🇿'},
    {'name': 'Myanmar', 'code': '+95', 'flag': '🇲🇲'},
    {'name': 'Namibia', 'code': '+264', 'flag': '🇳🇦'},
    {'name': 'Nauru', 'code': '+674', 'flag': '🇳🇷'},
    {'name': 'Nepal', 'code': '+977', 'flag': '🇳🇵'},
    {'name': 'Netherlands', 'code': '+31', 'flag': '🇳🇱'},
    {'name': 'New Zealand', 'code': '+64', 'flag': '🇳🇿'},
    {'name': 'Nicaragua', 'code': '+505', 'flag': '🇳🇮'},
    {'name': 'Niger', 'code': '+227', 'flag': '🇳🇪'},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'North Korea', 'code': '+850', 'flag': '🇰🇵'},
    {'name': 'North Macedonia', 'code': '+389', 'flag': '🇲🇰'},
    {'name': 'Norway', 'code': '+47', 'flag': '🇳🇴'},
    {'name': 'Oman', 'code': '+968', 'flag': '🇴🇲'},
    {'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'name': 'Palau', 'code': '+680', 'flag': '🇵🇼'},
    {'name': 'Palestine', 'code': '+970', 'flag': '🇵🇸'},
    {'name': 'Panama', 'code': '+507', 'flag': '🇵🇦'},
    {'name': 'Papua New Guinea', 'code': '+675', 'flag': '🇵🇬'},
    {'name': 'Paraguay', 'code': '+595', 'flag': '🇵🇾'},
    {'name': 'Peru', 'code': '+51', 'flag': '🇵🇪'},
    {'name': 'Philippines', 'code': '+63', 'flag': '🇵🇭'},
    {'name': 'Poland', 'code': '+48', 'flag': '🇵🇱'},
    {'name': 'Portugal', 'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Qatar', 'code': '+974', 'flag': '🇶🇦'},
    {'name': 'Romania', 'code': '+40', 'flag': '🇷🇴'},
    {'name': 'Russia', 'code': '+7', 'flag': '🇷🇺'},
    {'name': 'Rwanda', 'code': '+250', 'flag': '🇷🇼'},
    {'name': 'Saint Kitts and Nevis', 'code': '+1-869', 'flag': '🇰🇳'},
    {'name': 'Saint Lucia', 'code': '+1-758', 'flag': '🇱🇨'},
    {
      'name': 'Saint Vincent and the Grenadines',
      'code': '+1-784',
      'flag': '🇻🇨',
    },
    {'name': 'Samoa', 'code': '+685', 'flag': '🇼🇸'},
    {'name': 'San Marino', 'code': '+378', 'flag': '🇸🇲'},
    {'name': 'Sao Tome and Principe', 'code': '+239', 'flag': '🇸🇹'},
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
    {'name': 'Senegal', 'code': '+221', 'flag': '🇸🇳'},
    {'name': 'Serbia', 'code': '+381', 'flag': '🇷🇸'},
    {'name': 'Seychelles', 'code': '+248', 'flag': '🇸🇨'},
    {'name': 'Sierra Leone', 'code': '+232', 'flag': '🇸🇱'},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬'},
    {'name': 'Slovakia', 'code': '+421', 'flag': '🇸🇰'},
    {'name': 'Slovenia', 'code': '+386', 'flag': '🇸🇮'},
    {'name': 'Solomon Islands', 'code': '+677', 'flag': '🇸🇧'},
    {'name': 'Somalia', 'code': '+252', 'flag': '🇸🇴'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'South Korea', 'code': '+82', 'flag': '🇰🇷'},
    {'name': 'South Sudan', 'code': '+211', 'flag': '🇸🇸'},
    {'name': 'Spain', 'code': '+34', 'flag': '🇪🇸'},
    {'name': 'Sri Lanka', 'code': '+94', 'flag': '🇱🇰'},
    {'name': 'Sudan', 'code': '+249', 'flag': '🇸🇩'},
    {'name': 'Suriname', 'code': '+597', 'flag': '🇸🇷'},
    {'name': 'Sweden', 'code': '+46', 'flag': '🇸🇪'},
    {'name': 'Switzerland', 'code': '+41', 'flag': '🇨🇭'},
    {'name': 'Syria', 'code': '+963', 'flag': '🇸🇾'},
    {'name': 'Taiwan', 'code': '+886', 'flag': '🇹🇼'},
    {'name': 'Tajikistan', 'code': '+992', 'flag': '🇹🇯'},
    {'name': 'Tanzania', 'code': '+255', 'flag': '🇹🇿'},
    {'name': 'Thailand', 'code': '+66', 'flag': '🇹🇭'},
    {'name': 'Togo', 'code': '+228', 'flag': '🇹🇬'},
    {'name': 'Tonga', 'code': '+676', 'flag': '🇹🇴'},
    {'name': 'Trinidad and Tobago', 'code': '+1-868', 'flag': '🇹🇹'},
    {'name': 'Tunisia', 'code': '+216', 'flag': '🇹🇳'},
    {'name': 'Turkey', 'code': '+90', 'flag': '🇹🇷'},
    {'name': 'Turkmenistan', 'code': '+993', 'flag': '🇹🇲'},
    {'name': 'Tuvalu', 'code': '+688', 'flag': '🇹🇻'},
    {'name': 'Uganda', 'code': '+256', 'flag': '🇺🇬'},
    {'name': 'Ukraine', 'code': '+380', 'flag': '🇺🇦'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'Uruguay', 'code': '+598', 'flag': '🇺🇾'},
    {'name': 'Uzbekistan', 'code': '+998', 'flag': '🇺🇿'},
    {'name': 'Vanuatu', 'code': '+678', 'flag': '🇻🇺'},
    {'name': 'Vatican City', 'code': '+379', 'flag': '🇻🇦'},
    {'name': 'Venezuela', 'code': '+58', 'flag': '🇻🇪'},
    {'name': 'Vietnam', 'code': '+84', 'flag': '🇻🇳'},
    {'name': 'Yemen', 'code': '+967', 'flag': '🇾🇪'},
    {'name': 'Zambia', 'code': '+260', 'flag': '🇿🇲'},
    {'name': 'Zimbabwe', 'code': '+263', 'flag': '🇿🇼'},
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Country',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      final isSelected =
                          country['code'] == selectedCountryCode &&
                          country['name'] == selectedCountryName;

                      return ListTile(
                        leading: Text(
                          country['flag']!,
                          style: TextStyle(fontSize: 32),
                        ),
                        title: Text(country['name']!),
                        trailing: Text(
                          country['code']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            selectedCountryCode = country['code']!;
                            selectedCountryFlag = country['flag']!;
                            selectedCountryName = country['name']!;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDesignation == null) {
      _showMessage('Please select a designation', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate email format
      if (!_authService.isValidEmail(_emailController.text.trim())) {
        _showMessage(
          'Please enter a valid email address or Email Already Used.',
          isError: true,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Validate phone number
      if (!_authService.isValidPhoneNumber(
        _phoneController.text.trim(),
        selectedCountryCode,
      )) {
        _showMessage('Please enter a valid phone number', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create account
      final result = await _authService.createUserWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        designation: _selectedDesignation!,
        phoneNumber: _phoneController.text.trim(),
        countryCode: selectedCountryCode,
        countryName: selectedCountryName,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        _showMessage(result['message']);

        // Send phone OTP
        final fullPhoneNumber =
            '$selectedCountryCode${_phoneController.text.trim()}';
        // final otpResult = await _authService.sendPhoneOTP(fullPhoneNumber);
        // if (otpResult["success"]) {
        //   _showMessage(otpResult["message"]);
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(
        //   //     builder: (context) => EmailPhoneVerifyScreen(
        //   //       phoneNumber: fullPhoneNumber,
        //   //     ),
        //   //   ),
        //   // );
        // } else {
        //   _showMessage(otpResult["message"], isError: true);
        // }

        // Navigate to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailPhoneVerifyScreen(phoneNumber: fullPhoneNumber),
          ),
        );
      } else {
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('An error occurred: $e', isError: true);
    }
  }

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
        // New Google user - redirect to profile completion screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleProfileCompletionScreen(
              uid: result['uid'],
              email: result['userData']['email'] ?? '',
              displayName: result['userData']['fullName'] ?? '',
            ),
          ),
        );
      } else {
        // Existing user - go to shop details
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

  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Bar
                SizedBox(height: 10),

                // Title
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Adamina",
                  ),
                ),
                Text(
                  'Sign up to join',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),

                // Designation Dropdown

                // Social Buttons
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Container(height: 1, width: 60, color: Colors.black),
                    Text(
                      'or sign up with',
                      style: TextStyle(color: Colors.black),
                    ),
                    Container(height: 1, width: 60, color: Colors.black),
                    Container(height: 2, color: Colors.grey.shade500),
                  ],
                ),
                SizedBox(height: 7),

                // Designation Dropdown
                Text(
                  'Designation',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedDesignation,
                  hint: Text('Select your designation'),
                  items: _designations.map((String designation) {
                    return DropdownMenuItem<String>(
                      value: designation,
                      child: Text(designation),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDesignation = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a designation' : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 7),

                // Business Name
                Text(
                  'Business Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    hintText: 'Business Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 7),

                // Full Name (instead of separate first and last name)
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Name here',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 7),

                Text(
                  'Email Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'johnDoe@example.com',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 7),

                Text(
                  'Create Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: 'at least 8 characters',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 7),

                Text(
                  'Phone number',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                Row(
                  children: [
                    InkWell(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedCountryFlag,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '$selectedCountryCode 00 000000',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          prefixText: '$selectedCountryCode ',
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Checkbox(
                      focusColor: Colors
                          .teal[700], //MaterialStateProperty.all(Colors.teal[700]),
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text('Remember Me', style: TextStyle(color: Colors.black)),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar.
                        _isLoading
                            ? null
                            : _handleSignUp(); // disable if loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Processing Data")),
                        );
                        print(_phoneController.toString());
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => EmailPhoneVerifyScreen(),
                        //   ),
                        // );
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF305CDE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ), // 👈 your custom radius
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 7),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Login here',
                          style: TextStyle(
                            color: Colors.blueAccent,
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
