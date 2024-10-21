import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Nutritrack/models/user.dart';
import 'package:Nutritrack/services/database.dart';
import 'package:flutter/material.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = "";

  UserModel? _userFromFirebase(User? user, String? name, int age, int weight, int height, String gender, String activityLevel) {
    return user?.uid != null ? UserModel(uid: user!.uid, name: name, age: age, weight: weight, height: height, gender: gender, activityLevel: activityLevel) : null;
  }

  // Auth Stream Change
  // Stream<UserModel?> get user {
  //   return _auth.authStateChanges()
  //       .map((User? user) => _userFromFirebase(user!));
  // }

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) => _userFromFirebase(user, null, 0, 0, 0, "", ""));
  }

  // anon sign in
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebase(user!, null, 35, 69, 190, "Male", "Lightly Active - Casual light exercise a few times a week");
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & pass
  Future signInWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("SIGNING IN USER");

      User? user = result.user;

      uid = user!.uid;

      CollectionReference users = FirebaseFirestore.instance.collection(
          'user-data');

      users.doc(uid).get().then((value) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        return _userFromFirebase(user, data['name'], data['age'], data['height'], data['weight'], data['gender'], data['activity-level']);
      });

    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // FutureBuilder<DocumentSnapshot<Map<String, dynamic>>() {}
  //
  // FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  // future: collection.doc('docume tIdHere').get(),
  // builder: (_, snapshot) {
  // if (snapshot.hasError) return Text ('${snapshot.error}');
  //
  // if (snapshot.hasData) {
  // var data = snapshot.data!.data();
  // var firstName = data!['firstName'];
  // return Text('first name is $firstName');
  // }
  //
  // return Center(child: CircularProgressIndicator());
  // },
  // )

  // register with email & pass
  Future registerWithEmailAndPass(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      uid = user!.uid;

      print("PUSHING PAGE");
      final List<String>creds = await Navigator.pushNamed(
          context, '/setup') as List<String>;

      // Create document object with new UID
      print("REGISTERING NEW USER");
      print(creds[0]);
      print(creds[5]);
      await DatabaseService(uid: user.uid).updateUserData(
          creds[0], int.parse(creds[1]), int.parse(creds[2]),
          int.parse(creds[3]), creds[4], creds[5]);
      print("USER DATA REGISTERED");

      return _userFromFirebase(user, creds[0], int.parse(creds[1]), int.parse(creds[2]),
          int.parse(creds[3]), creds[4], creds[5]);
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

  // String getUid() {
  //   return uid;
  // }
}