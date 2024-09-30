import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/user.dart';
import 'package:flutter_test_app/services/database.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final _database = DatabaseService(uid: uid)

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream
        builder: builder
    );
  }
}
