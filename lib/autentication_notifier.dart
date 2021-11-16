import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io' as io;

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  String? _avatar;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  String? get avatar => _avatar;

  set avatarPicutre(io.File picture) {
    if (user == null) return;
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(user!.uid)
        .putFile(picture)
        .then((p0) => _getAvatarURL())
        .whenComplete(() => notifyListeners());
  }

  Future<void> _getAvatarURL() async {
    try {
      _avatar = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child(user!.uid)
          .getDownloadURL();
    } catch (e) {
      _avatar = null;
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _avatar = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      await _getAvatarURL();
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}
