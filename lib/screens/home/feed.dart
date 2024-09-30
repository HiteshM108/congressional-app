import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/user.dart';
import 'package:flutter_test_app/services/auth.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  // UserModel user = new UserModel();
  // UserModel data = _auth.getUser();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Container(
      child: Text(userModel.toString()),
    );
  }
}
