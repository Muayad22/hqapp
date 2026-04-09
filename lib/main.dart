import 'package:flutter/material.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MaterialApp(
    title: "Heritage Quest",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light, // force light mode
    ),
    home: const LoginScreen(),
  ));
}
