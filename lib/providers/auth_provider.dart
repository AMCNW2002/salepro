import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUserModel;
  bool _isLoading = true; // Initial loading state (checking auth)
  bool _isActionLoading = false; // Loading state for login/register actions
  String? _errorMessage;

  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _userProfileSubscription;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Ensure profile is created for manually added users (admin/rep)
        await _authService.getUserProfile(user.uid);
        _listenToUserProfile(user.uid);
      } else {
        _userProfileSubscription?.cancel();
        _currentUserModel = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToUserProfile(String uid) {
    _userProfileSubscription?.cancel();
    _userProfileSubscription = _authService
        .streamUserProfile(uid)
        .listen(
          (userModel) {
            if (userModel != null) {
              _currentUserModel = _applyDailyRouteReset(userModel);
            } else {
              _currentUserModel = null;
            }
            _isLoading = false;
            _isActionLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  UserModel _applyDailyRouteReset(UserModel user) {
    if (user.routeId.isEmpty) return user;

    final now = DateTime.now();
    final routeDate = user.routeUpdatedAt ?? user.createdAt;

    // Reset route at midnight (if day is different)
    if (routeDate.year != now.year ||
        routeDate.month != now.month ||
        routeDate.day != now.day) {
      return UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        phone: user.phone,
        shopName: user.shopName,
        shopAddress: user.shopAddress,
        role: user.role,
        routeId: '', // Treated as unassigned client-side
        routeUpdatedAt: user.routeUpdatedAt,
        createdAt: user.createdAt,
      );
    }

    return user;
  }

  Future<bool> login(String email, String password) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.loginWithEmailPassword(email, password);
      // AuthListener will handle fetching the profile and setting _isActionLoading to false
      // Do not set _isActionLoading = false here so the button keeps spinning until transition
      return true;
    } on FirebaseAuthException catch (e) {
      _isActionLoading = false;
      _errorMessage = e.message ?? "An error occurred during login.";
      notifyListeners();
      return false;
    } catch (e) {
      _isActionLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String ownerName,
    required String phone,
    required String shopName,
    required String shopAddress,
    required String role,
    String routeId = '',
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerUser(
        email: email,
        password: password,
        ownerName: ownerName,
        phone: phone,
        shopName: shopName,
        shopAddress: shopAddress,
        role: role,
        routeId: routeId,
      );
      // AuthListener will handle fetching the profile and setting _isActionLoading to false
      return true;
    } on FirebaseAuthException catch (e) {
      _isActionLoading = false;
      _errorMessage = e.message ?? "An error occurred during registration.";
      notifyListeners();
      return false;
    } catch (e) {
      _isActionLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _userProfileSubscription?.cancel();
    await _authService.logout();
    _currentUserModel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
