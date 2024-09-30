import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/models/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // Collection Reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection("user-data");

  Future updateUserData(String name, int age, int weight, int height) async {
    return await userDataCollection.doc(uid).set({
      "name" : name,
      "age" : age,
      "weight" : weight,
      "height" : height
    }).onError((e, _) => print("ERROR WRITING TO DOC: $e"));
  }

  Stream<UserModel> get userData {
    return userDataCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(uid: uid, name: snapshot.get("name"), age: snapshot.get("age"), height: snapshot.get("weight"), weight: snapshot.get("height"));
  }

}