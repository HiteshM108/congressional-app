import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Nutritrack/models/scanItem.dart';
import 'package:Nutritrack/models/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // Collection Reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection("user-data");
  final CollectionReference userScanCollection = FirebaseFirestore.instance.collection("user-scans");
  final CollectionReference userImageCollection = FirebaseFirestore.instance.collection("user-images");

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

  Future updateUserImages(String imageRequest, String itemName, String nutriScore, List<String> nutrients) async {

    String image = await nextImageNumber();

    return await userImageCollection.doc(uid).set({
      image : {
        "image-request" : imageRequest,
        "name" : itemName,
        "nutriScore" : nutriScore,
        "nutrients" : nutrients
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

  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(uid: uid, name: snapshot.get("name"), age: snapshot.get("age"), height: snapshot.get("weight"), weight: snapshot.get("height"), gender: snapshot.get("gender"), activityLevel: snapshot.get("activity-level"));
  }

  void getScanData() {
    var data = userScanCollection.doc(uid).snapshots().elementAt(0);
    data.then((value) {
      print(value["image-request"]);
    });
  }

  ScanItem _userScanFromSnapshot(DocumentSnapshot snapshot) {
    return ScanItem(imageRequest: snapshot.get("image-request"), itemName: snapshot.get("item-name"), description: snapshot.get("description"), feedback: snapshot.get("feedback"), nutriScore: snapshot.get("nutriScore"), ingredients: snapshot.get("ingredients"), nutrients: snapshot.get("nutrients"));
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