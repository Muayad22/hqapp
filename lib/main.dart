import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hqapp/screens/session_bootstrap_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      title: 'Heritage Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: const SessionBootstrapScreen(),
    ),
  );
}
