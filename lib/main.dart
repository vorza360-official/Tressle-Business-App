import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressle_business/UI/splashScreen.dart';
import 'package:tressle_business/UI/test.dart';
import 'package:tressle_business/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AuthService().initializeAuthListener();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRESSLE',
      theme: ThemeData(
        textTheme: GoogleFonts.manropeTextTheme(),
        primarySwatch: Colors.teal,
        //fontFamily: 'Adamina',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
