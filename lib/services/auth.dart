import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test_app/models/user.dart';
import 'package:flutter_test_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user, String? name, int age, int weight, int height) {
    return user?.uid != null ? UserModel(uid: user!.uid, name: name, age: age, weight: weight, height: height) : null;
  }

  // Auth Stream Change
  // Stream<UserModel?> get user {
  //   return _auth.authStateChanges()
  //       .map((User? user) => _userFromFirebase(user!));
  // }

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) => _userFromFirebase(user, null, 0, 0, 0));
  }

  // anon sign in
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebase(user!, null, 0, 0, 0);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & pass
  Future signInWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      // DatabaseService(uid: user)

      // final userModel = Provider.of<UserModel>(DatabaseService(uid: uid).userData);
      // StreamBuilder<UserModel> userModel = DatabaseService(uid: uid).userData;
      // print(user.);
      return _userFromFirebase(user, null, 0, 0, 0);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & pass
  Future registerWithEmailAndPass(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      print("PUSHING PAGE");
      final List<String>creds = await Navigator.pushNamed(
          context, '/setup') as List<String>;

      // Create document object with new UID
      print("REGISTERING NEW USER");
      print(creds[0]);
      await DatabaseService(uid: user!.uid).updateUserData(
          creds[0], int.parse(creds[1]), int.parse(creds[2]),
          int.parse(creds[3]));
      print("USER DATA REGISTERED");

      return _userFromFirebase(user, creds[0], int.parse(creds[1]), int.parse(creds[2]),
          int.parse(creds[3]));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      print("SIGN OUT SUCCESSFUL");
      return await _auth.signOut();
    } catch (e) {
      print("SIGN OUT FAIL");
      print(e.toString());
      return null;
    }
  }

  // UserModel getUser() {
  //   return userModel;
  // }
}