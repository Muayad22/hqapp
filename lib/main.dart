import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hqapp/screens/login_screen.dart';

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4423),
          brightness: Brightness.light,
          primary: const Color(0xFF6B4423),
          secondary: const Color(0xFF8B4513),
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFC62828),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6B4423),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFFFFFFFF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B4423),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4423),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B4423),
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B4423),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDAA520),
          brightness: Brightness.dark,
          primary: const Color(0xFFDAA520),
          secondary: const Color(0xFFCD853F),
          surface: const Color(0xFF2A241F),
          error: const Color(0xFFC62828),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFDAA520),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFF2A241F),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDAA520),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDAA520),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFDAA520),
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFFDAA520),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
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
                  color: const Color(0xFF6B4423),
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
