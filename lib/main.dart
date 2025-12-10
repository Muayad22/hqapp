import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hqapp/firebase_options.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:hqapp/theme/app_theme.dart';

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  // Handle Firebase initialization errors
  bool firebaseInitialized = false;
  try {
    await _initializeFirebase();
    firebaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
    // Continue with app even if Firebase fails (for development)
  }

  runApp(HeritageQuestApp(firebaseInitialized: firebaseInitialized));
}

class HeritageQuestApp extends StatelessWidget {
  final bool firebaseInitialized;

  const HeritageQuestApp({super.key, this.firebaseInitialized = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heritage Quest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: firebaseInitialized
          ? const LoginScreen()
          : _ErrorScreen(
              message:
                  'Firebase is not configured for this platform. Please configure Firebase or use Android/iOS device.',
            ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Configuration Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Try to initialize Firebase again
                  final initialized = await _initializeFirebase();
                  if (context.mounted) {
                    if (initialized) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to initialize Firebase. Please check your configuration.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
