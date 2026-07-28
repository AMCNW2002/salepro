import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user UID
  String? get currentUserUid => _auth.currentUser?.uid;

  // Login with email & password
  Future<UserCredential> loginWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email & password
  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String ownerName,
    required String phone,
    required String shopName,
    required String shopAddress,
    required String role,
    String routeId = '',
  }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save user profile data into Firestore
      if (userCredential.user != null) {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          name: ownerName,
          email: email,
          phone: phone,
          shopName: shopName,
          shopAddress: shopAddress,
          role: role,
          routeId: routeId,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
            
        // If the registered user is a customer, create a shop document as well
        if (role == 'customer') {
          await _firestore
              .collection('shops')
              .doc(userCredential.user!.uid)
              .set({
                'name': shopName,
                'owner': ownerName,
                'phone': phone,
                'address': shopAddress,
                'routeId': routeId,
                'balanceDue': 0.0,
              });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Get User Profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        // Auto-create missing profile for manually added Firebase Auth users
        User? user = _auth.currentUser;
        if (user != null && user.uid == uid) {
          String email = user.email ?? '';
          String role = 'customer';
          
          if (email.endsWith('@m.lk')) {
            if (email.toLowerCase().startsWith('admin')) {
              role = 'admin';
            } else {
              role = 'rep';
            }
          }
          
          UserModel newUser = UserModel(
            uid: uid,
            name: user.displayName ?? email.split('@').first,
            email: email,
            phone: '',
            role: role,
            createdAt: DateTime.now(),
          );
          
          await _firestore.collection('users').doc(uid).set(newUser.toMap());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get User Profile from Firestore (Stream)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Update FCM Token
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
