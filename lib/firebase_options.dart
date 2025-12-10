import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _unsupported('web');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDYxhDS42S-wmODLQFeEsmFONpcNLhhcRM',
          appId: '1:1097532649584:android:3e9654985f21e6c0aa84b5',
          messagingSenderId: '1097532649584',
          projectId: 'hqdb-1fbae',
          databaseURL:
              'https://hqdb-1fbae-default-rtdb.asia-southeast1.firebasedatabase.app',
          storageBucket: 'hqdb-1fbae.firebasestorage.app',
        );
      case TargetPlatform.windows:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDYxhDS42S-wmODLQFeEsmFONpcNLhhcRM',
          appId: '1:1097532649584:windows:default',
          messagingSenderId: '1097532649584',
          projectId: 'hqdb-1fbae',
          databaseURL:
              'https://hqdb-1fbae-default-rtdb.asia-southeast1.firebasedatabase.app',
          storageBucket: 'hqdb-1fbae.firebasestorage.app',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _unsupported(defaultTargetPlatform.name);
    }
  }

  static FirebaseOptions _unsupported(String platform) {
    throw UnsupportedError(
      'No Firebase configuration found for $platform. '
      'Run `flutterfire configure` to regenerate firebase_options.dart for your platforms.',
    );
  }
}
