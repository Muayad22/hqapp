import 'package:flutter/material.dart';
import 'package:hqapp/screens/admin_home_screen.dart';
import 'package:hqapp/screens/home_screen.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/services/session_service.dart';


class SessionBootstrapScreen extends StatefulWidget {
  const SessionBootstrapScreen({super.key});

  @override
  State<SessionBootstrapScreen> createState() => _SessionBootstrapScreenState();
}

class _SessionBootstrapScreenState extends State<SessionBootstrapScreen> {
  Widget? _target;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final userId = await SessionService.getSavedUserId();
      if (userId == null) {
        if (mounted) setState(() => _target = const LoginScreen());
        return;
      }

      final user = await FirestoreService.getUserProfileById(userId);
      if (!mounted) return;

      if (user == null) {
        await SessionService.clearSession();
        setState(() => _target = const LoginScreen());
        return;
      }

      setState(() {
        _target = user.hasStaffAccess
            ? AdminHomeScreen(user: user)
            : HomeScreen(user: user);
      });
    } catch (_) {
      await SessionService.clearSession();
      if (mounted) setState(() => _target = const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_target == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _target!;
  }
}
