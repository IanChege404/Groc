import 'package:firebase_auth/firebase_auth.dart';
import '../network/api_client.dart';

class FirestoreAuthService {
  static final FirestoreAuthService _instance =
      FirestoreAuthService._internal();

  factory FirestoreAuthService() {
    return _instance;
  }

  FirestoreAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return ApiResponse.error('Login failed: User is null');
      }

      final userData = {
        'id': user.uid,
        'email': user.email,
        'firstName': user.displayName?.split(' ').first ?? '',
        'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'photoUrl': user.photoURL,
        'phone': user.phoneNumber,
      };

      return ApiResponse.success(data: userData);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(e.message ?? 'Login failed');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Sign up with email and password
  Future<ApiResponse<Map<String, dynamic>>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return ApiResponse.error('Signup failed: User is null');
      }

      // Update user profile
      await user.updateDisplayName('$firstName $lastName');

      final userData = {
        'id': user.uid,
        'email': user.email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      };

      return ApiResponse.success(data: userData);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(e.message ?? 'Signup failed');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Send password reset email
  Future<ApiResponse<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ApiResponse.success(data: null);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to send reset email');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    try {
      await _auth.signOut();
      return ApiResponse.success(data: null);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(e.message ?? 'Logout failed');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _auth.currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }
}
