import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/user.dart';
import 'package:flutter_test_app/screens/authenticate/authenticate.dart';
import 'package:flutter_test_app/screens/authenticate/userSetup.dart';
import 'package:flutter_test_app/screens/home/home.dart';
import 'package:flutter_test_app/services/auth.dart';
import 'package:provider/provider.dart';

// class Wrapper extends StatelessWidget {
//   const Wrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     // final UserModel? user = Provider.of<UserModel?>(context);
//     print(user);
//
//     print("CHECKING LOGIN STATUS");
//     // return either Home or sign up
//     if (user == null) {
//       return Authenticate();
//     } else {
//       return Home();
//     }
//   }
// }

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          print("CHECKING LOGIN STATUS");
          if (snapshot.data?.name == "null") {
            print("Register Page");
            return UserInfoSetup();
          } else if (snapshot.hasData) {
            print("Home Page");
            return Home();
          } else {
            print("Auth Page");
            return const Authenticate();
          }
        }
    );
  }
}
