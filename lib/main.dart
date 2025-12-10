import 'package:flutter/material.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    title: "Heritage Quest",
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

