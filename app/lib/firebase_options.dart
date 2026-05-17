// Firebase configuration for the web app.
// Replace the placeholder values below with the firebaseConfig object you
// copied from the Firebase Console when registering the web app.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web; // single-platform demo — reuse web config everywhere
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBOh8TraMVFbJe7sJ5ujmks2K-vjPhx2FM',
    authDomain: 'kkr-aihallucination-check-app.firebaseapp.com',
    projectId: 'kkr-aihallucination-check-app',
    storageBucket: 'kkr-aihallucination-check-app.firebasestorage.app',
    messagingSenderId: '700600976729',
    appId: '1:700600976729:web:72abdaf4f1e753f7907848',
    measurementId: 'G-VLJG5YK0BH',
  );
}
