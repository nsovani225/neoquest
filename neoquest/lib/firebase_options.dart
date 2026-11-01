import 'package:firebase_core/firebase_core.dart';

/// Web app settings from Firebase Console. Firebase Web API keys identify the
/// app; access is protected by Firebase Authentication and Firestore rules.
abstract final class DefaultFirebaseOptions {
  static const currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyD0fWh-TLC10P22mK34DzZUTie40vrENQY',
    appId: '1:199788942388:web:ccf03c43333ad1c9ad2661',
    messagingSenderId: '199788942388',
    projectId: 'neoquest-74e8c',
    authDomain: 'neoquest-74e8c.firebaseapp.com',
    storageBucket: 'neoquest-74e8c.firebasestorage.app',
    measurementId: 'G-BYHB449TDW',
  );
}
