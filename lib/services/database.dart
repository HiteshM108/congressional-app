import 'dart:async';

import 'package:Nutritrack/models/foodImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Nutritrack/models/scanItem.dart';
import 'package:Nutritrack/models/user.dart';
import 'package:Nutritrack/screens/home/scanned_history.dart';
import 'package:Nutritrack/screens/home/food_history.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // Collection Reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection("user-data");
  final CollectionReference userScanCollection = FirebaseFirestore.instance.collection("user-scans");
  final CollectionReference userImageCollection = FirebaseFirestore.instance.collection("user-images");

  final StreamController<int> _controller = StreamController<int>();

  Future updateUserData(String name, int age, int weight, int height, String gender, String activityLevel) async {
    return await userDataCollection.doc(uid).set({
      "name" : name,
      "age" : age,
      "weight" : weight,
      "height" : height,
      "gender" : gender,
      "activity-level" : activityLevel
    }).onError((e, _) => print("ERROR WRITING TO DOC: $e"));
  }

  Future updateUserScans(String imageRequest, String itemName, String description, String feedback, String nutriScore, List<String> ingredients, List<double> nutrients) async {

    String scan = await nextScanNumber();

    return await userScanCollection.doc(uid).set({
      scan : {
        "image-request" : imageRequest,
        "name" : itemName,
        "description" : description,
        "feedback" : feedback,
        "nutriScore" : nutriScore,
        "ingredients" : ingredients,
        "nutrients" : nutrients
      }
    }, SetOptions(merge: true)).onError((e, _) => print("ERROR WRITING TO DOC: $e"));
  }

  Future updateUserImages(String imageRequest, String itemName, String nutriScore, List<String> nutrients, String feedback) async {

    String image = await nextImageNumber();

    return await userImageCollection.doc(uid).set({
      image : {
        "image-request" : imageRequest,
        "name" : itemName,
        "nutriScore" : nutriScore,
        "nutrients" : nutrients,
        "feedback" : feedback,
      }
    }, SetOptions(merge: true)).onError((e, _) => print("ERROR WRITING TO DOC: $e"));
  }

  Future<String> nextScanNumber() async {
    DocumentSnapshot snapshot = await userScanCollection.doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>;
      print(data.length);
      return "scan-${data.length + 1}";
    } else {
      return "scan-1";
    }
  }

  Future<String> nextImageNumber() async {
    DocumentSnapshot snapshot = await userImageCollection.doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>;
      print(data.length);
      return "scan-${data.length + 1}";
    } else {
      return "scan-1";
    }
  }

  Stream<UserModel> getUserData() {
    return userDataCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  Stream<ScanHistory> getScanData() {
    return userScanCollection.doc(uid).snapshots()
        .map(_userScanFromSnapshot);
  }

  Stream<FoodImageHistory> getFoodData(){
    return userImageCollection.doc(uid).snapshots()
        .map(_userFoodFromSnapshot);
  }

  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(uid: uid, name: snapshot.get("name"), age: snapshot.get("age"), height: snapshot.get("weight"), weight: snapshot.get("height"), gender: snapshot.get("gender"), activityLevel: snapshot.get("activity-level"));
  }

  FoodImageHistory _userFoodFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {

      List<Map<String, dynamic>> foodImage = [];

      data.forEach((key, value) {
        if (key.startsWith("scan-")) {
          foodImage.add(value as Map<String, dynamic>);
        }
      });
      return FoodImageHistory(foodHistory: foodImage);
    } else {
      return FoodImageHistory(foodHistory: []);
    }
  }

  ScanHistory _userScanFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {

      List<Map<String, dynamic>> scanItems = [];

      data.forEach((key, value) {
        if (key.startsWith("scan-")) {
          scanItems.add(value as Map<String, dynamic>);
        }
      });
      return ScanHistory(scanHistory: scanItems);
    } else {
      return ScanHistory(scanHistory: []);
    }
  }

  // Future<UserModel> getUserData(String uid) async {
  //   print("Getting user data");
  //   print(uid);
  //   final snapshot = userDataCollection.doc(uid).snapshots();
  //   final userData = snapshot.map((e) => UserModel.fromSnapshot(e as DocumentSnapshot<Map<String, dynamic>>)).single;
  //   return userData;
  //
  // }
}