import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<bool> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Enable Firestore offline persistence for web/mobile if supported
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      if (kDebugMode) {
        print('Firebase initialized successfully.');
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
        print(stackTrace);
      }
      return false;
    }
  }
}
