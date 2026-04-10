import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Firebase instances
  late FirebaseApp _firebaseApp;
  late FirebaseAuth _firebaseAuth;
  late FirebaseFirestore _firebaseFirestore;

  // Getters
  FirebaseAuth get auth => _firebaseAuth;
  FirebaseFirestore get firestore => _firebaseFirestore;
  FirebaseApp get app => _firebaseApp;

  /// Initialize Firebase
  Future<void> initialize({String? firebaseProjectId}) async {
    try {
      _firebaseApp = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseAuth = FirebaseAuth.instance;
      _firebaseFirestore = FirebaseFirestore.instance;

      // Set Firestore settings
      _firebaseFirestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _firebaseApp.delete();
  }
}
