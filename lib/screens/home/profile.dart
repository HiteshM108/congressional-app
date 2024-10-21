import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Nutritrack/models/user.dart';
import 'package:Nutritrack/services/auth.dart';
import 'package:Nutritrack/services/database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        final uid = user?.uid;
        if (user != null) {
          print(user);
          print(uid);

          CollectionReference users = FirebaseFirestore.instance.collection(
              'user-data');

          return FutureBuilder<DocumentSnapshot>(
            future: users.doc(uid).get(),
            builder:
                (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Something went wrong"));
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return Center(child: Text("Please Login again!"));
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                return Container(
                  padding: const EdgeInsets.all(25),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 25,),
                        Text(data['name'], style: Theme.of(context).textTheme.headlineMedium,),
                        Text(user.email.toString(), style: Theme.of(context).textTheme.bodyMedium,),

                        const SizedBox(height: 25),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(color: Colors.grey, width: 2.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(75),
                                  color: Colors.amber
                              ),
                              child: Icon(MdiIcons.fromString("chart-donut")),
                            ),
                            title: Text("Age"),
                            subtitle: Text(data['age'].toString()),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(color: Colors.grey, width: 2.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(75),
                                  color: Colors.amber
                              ),
                              child: Icon(MdiIcons.fromString("weight-pound")),
                            ),
                            title: Text("Weight"),
                            subtitle: Text(data['weight'].toString()),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(color: Colors.grey, width: 2.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(75),
                                  color: Colors.amber
                              ),
                              child: Icon(MdiIcons.fromString("human-male-height")),
                            ),
                            title: Text("Height"),
                            subtitle: Text(data['height'].toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                  // Center(child: Text("Hello, ${data['name']}!"));
              }

              return Center(child: CircularProgressIndicator());
            },
          );
      } else {
        return Center(child: Text("User is not logged in"));
      }
    }),
  );


    // child: StreamBuilder(
    //   stream: FirebaseFirestore.instance.collection("user-data").doc(AuthService.uid).snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.active) {
    //       if (snapshot.hasData) {
    //         return Text(snapshot.data!.data().toString());
    //       } else if (snapshot.hasError) {
    //         return Center(child: Text(snapshot.hasError.toString()));
    //       } else {
    //         return const Center(child: Text("No data found"));
    //       }
    //     } else {
    //       throw Error();
    //     }
    //   }
    // )


    // child: FutureBuilder(
    //   future: _database.getUserData(uid),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       if (snapshot.hasData) {
    //         UserModel userData = snapshot.data as UserModel;
    //         print("ACCESSED NAME");
    //         print(userData.name);
    //       } else if (snapshot.hasError) {
    //         return Center(child: Text(AuthService.getUid()));
    //       } else {
    //         return const Center(child: Text("Something went wrong"));
    //       }
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     throw Error();
    //   }
    // )
    }
  }
